//
//  ViewController.swift
//  Game_Walker
//
//  Created by Paul on 6/7/22.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift
import AVFoundation
import SwiftUI

class MainViewController: UIViewController {

    @IBOutlet weak var gameWalkerImage: UIImageView!
    @IBOutlet weak var playerButton: UIButton!
    @IBOutlet weak var refereeButton: UIButton!
    @IBOutlet weak var hostButton: UIButton!
    @IBOutlet weak var testBtn: UIButton!
    
    private let audioPlayerManager = AudioPlayerManager()

    private var soundEnabled: Bool = true
    private var vibrationEnabled: Bool = true

    override func viewDidLoad() {
        if UserData.readUUID() == nil {
            UserData.writeUUID(UUID().uuidString)
        }
        if UserData.isHostConfirmed() == nil || UserData.isHostConfirmed() == false {
            UserData.confirmHost(false)
        }
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        configureNavBarItems()
        configureButtons()
        setDefaultSoundVibrationPreference()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if soundEnabled {
            print("View will appear and sound is enabled.")
            self.audioPlayerManager.playAudioFile(named: "bgm", withExtension: "wav")
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        if self.audioPlayerManager.isPlaying() {
            self.audioPlayerManager.stop()
        }
    }

    private func configureSettings() {
            NotificationCenter.default.addObserver(self, selector: #selector(applyChangedSettings), name: Notification.Name("SettingsChanged"), object: nil)
    }
    
    @objc private func applyChangedSettings(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let settingsData = userInfo["settingsData"] as? (Bool, Bool) {
                soundEnabled = settingsData.0
                vibrationEnabled = settingsData.1
            }
            if !soundEnabled {
                // Stop background music if sound is no longer enabled
                self.audioPlayerManager.stop()
            }
            if soundEnabled && !audioPlayerManager.isPlaying() {
                // Check if the current view controller is MainViewController
                if let viewControllers = navigationController?.viewControllers {
                    for viewController in viewControllers {
                        print("View Controller: \(type(of: viewController))")
                    }
                }
                print("Current View Controller: \(type(of: self))")
                if let lastViewController = navigationController?.viewControllers.last, lastViewController is MainViewController {
                    self.audioPlayerManager.playAudioFile(named: "bgm", withExtension: "wav")
                }
            }
        }
    }

    private func setDefaultSoundVibrationPreference() {
        if let userSoundPreference = UserData.getUserSoundPreference()  {
            soundEnabled = userSoundPreference
        } else {
            // Set default if user preference is nil (initial)
            UserData.setUserSoundPreference(true)
        }
        if let userVibrationPreference = UserData.getUserVibrationPreference() {
            vibrationEnabled = userVibrationPreference
        } else {
            // Set default if user preference is nil (initial)
            UserData.setUserVibrationPreference(true)
        }
    }

    private func configureButtons(){
        playerButton.layer.cornerRadius = 10
        playerButton.layer.borderWidth = 3
        playerButton.layer.borderColor = UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1).cgColor
        refereeButton.layer.cornerRadius = 10
        refereeButton.layer.borderWidth = 3
        refereeButton.layer.borderColor = UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 1).cgColor
        hostButton.layer.cornerRadius = 10
        hostButton.layer.borderWidth = 3
        hostButton.layer.borderColor = UIColor(red: 0.843, green: 0.502, blue: 0.976, alpha: 1).cgColor
        testBtn.layer.cornerRadius = 10
        testBtn.layer.borderWidth = 3
        testBtn.layer.borderColor = UIColor.systemBlue.cgColor
    }
    
    @IBAction func playerBtnPressed(_ sender: Any) {
        if soundEnabled {
            self.audioPlayerManager.playAudioFile(named: "blue", withExtension: "wav")
        }
        performSegue(withIdentifier: "goToPlayer", sender: self)
    }
    
    @IBAction func refereeBtnPressed(_ sender: Any) {
        if soundEnabled {
            self.audioPlayerManager.playAudioFile(named: "green", withExtension: "wav")
        }
        performSegue(withIdentifier: "goToReferee", sender: self)
    }
    
    @IBAction func hostBtnPressed(_ sender: Any) {
        if soundEnabled {
            self.audioPlayerManager.playAudioFile(named: "purple", withExtension: "wav")
        }
        performSegue(withIdentifier: "goToHost", sender: self)
    }
    
    @IBAction func testBtnPressed(_ sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: "gamecode")
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "referee")
        UserDefaults.standard.removeObject(forKey: "player")
        UserDefaults.standard.removeObject(forKey: "team")
        UserDefaults.standard.removeObject(forKey: "standardstyle")
        UserData.writeUUID(UUID().uuidString)
    }
    
    private func configureNavBarItems() {
        print("configuring nav bar items")
        let infoImage = UIImage(named: "infoIcon")
        let infoBtn = UIButton()
        infoBtn.setImage(infoImage, for: .normal)
        infoBtn.addTarget(self, action: #selector(guide), for: .touchUpInside)
        let info = UIBarButtonItem(customView: infoBtn)

        self.navigationItem.rightBarButtonItems = [info]

        configureSettings()
    }
    
    @objc func guide() {
        let componentPositions: [CGRect] = [playerButton.frame, refereeButton.frame, hostButton.frame, gameWalkerImage.frame]
        let layerList: [CALayer] = [playerButton.layer, refereeButton.layer, hostButton.layer]
        let explanationTexts = [
            NSLocalizedString("Join as a Team Member", comment: ""),
            NSLocalizedString("Allocate points and manage individual Stations", comment: ""),
            NSLocalizedString("Organize and oversee the entire Game Event", comment: "")
        ]

        let overlayViewController = MainOverlayViewController()
        overlayViewController.modalPresentationStyle = .overFullScreen // Present it as overlay
        overlayViewController.configureGuide(componentPositions, layerList, explanationTexts)
        
        present(overlayViewController, animated: true, completion: nil)
    }
}
