//
//  HostTimerViewController.swift
//  Game_Walker
//
//  Created by Noah Kim on 2/1/23.
//

import Foundation
import UIKit
import AVFoundation

class HostTimerViewController: UIViewController {
    
    @IBOutlet weak var pauseOrPlayButton: UIButton!
    @IBOutlet weak var announcementBtn: UIButton!
    @IBOutlet weak var settingBtn: UIButton!
    private var messages: [String] = []
    
    private var startTime : Int = 0
    private var pauseTime : Int = 0
    private var pausedTime : Int = 0
    private var timer = Timer()
    private var totalTime: Int = 0
    private var time: Int?
    private var seconds: Int = 0
    private var moveSeconds: Int = 0
    private var moving: Bool = true
    private var tapped: Bool = false
    private var round: Int = 1
    private var rounds: Int?
    private var isPaused = true
    private var t : Int = 0
    
    private let play = UIImage(named: "Polygon 1")
    private let pause = UIImage(named: "Group 359")
    private let end = UIImage(named: "Game End Button")
    
    private var gameCode: String = UserData.readGamecode("gamecode") ?? ""
    private var gameStart : Bool = false
    private var gameOver : Bool = false
    private var segueCalled : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        H.delegate_getHost = self
        H.getHost(gameCode)
        H.delegates.append(self)
        H.listenHost(gameCode, onListenerUpdate: listen(_:))
    }
    
    @IBAction func announcementBtnPressed(_ sender: UIButton) {
        showHostMessagePopUp(messages: messages)
    }

    @IBAction func settingBtnPressed(_ sender: UIButton) {
    }
    
    @IBAction func pauseOrPlayButtonPressed(_ sender: UIButton) {
        if sender.image(for: .normal) != end {
            if !gameStart {
                Task { @MainActor in
                    await H.startGame(gameCode)
                    sender.setImage(pause, for: .normal)
                    await H.pause_resume_game(gameCode)
                }
            }
            else {
                if isPaused {
                    sender.setImage(pause, for: .normal)
                }
                else {
                    sender.setImage(play, for: .normal)
                }
                isPaused = !isPaused
                Task { @MainActor in
                    await H.pause_resume_game(gameCode)
                }
            }
        }
        else {
            self.pauseOrPlayButton.isHidden = true
            configureEndButton()
        }
    }
    //MARK: - Music
    var audioPlayer: AVAudioPlayer?

    func playMusic() {
        guard let soundURL = Bundle.main.url(forResource: "timer_end", withExtension: "wav") else {
            print("Music file not found.")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.numberOfLoops = 2
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Failed to play music: \(error.localizedDescription)")
        }
    }
    
    func stopMusic() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
    //MARK: - UI Timer Elements
    private let timerCircle: UILabel = {
        var view = UILabel()
        view.clipsToBounds = true
        view.frame = CGRect(x: 0, y: 0, width: 256, height: 256)
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0.6
        view.layer.borderWidth = 15
        view.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        view.layer.cornerRadius = view.frame.width / 2.0
        return view
    }()
    
    @objc func buttonTapped(_ gesture: UITapGestureRecognizer) {
        if !tapped {
            timerCircle.layer.borderColor = UIColor(red: 0.843, green: 0.502, blue: 0.976, alpha: 1).cgColor
            timerLabel.alpha = 0.0
            timeTypeLabel.alpha = 0.0
            roundLabel.alpha = 1.0
            totalTimeLabel.alpha = 1.0
            tapped = true
        } else {
            timerCircle.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
            timerLabel.alpha = 1.0
            timeTypeLabel.alpha = 1.0
            roundLabel.alpha = 0.0
            totalTimeLabel.alpha = 0.0
            tapped = false
        }
    }
    
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-Regular", size: 55)
        label.numberOfLines = 0
        return label
    }()
    
    private let timeTypeLabel: UILabel = {
        let label = UILabel()
        label.text = "Moving Time"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-Regular", size: 35)
        label.numberOfLines = 1
        return label
    }()
    
    private let roundLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-Regular", size: 35)
        label.numberOfLines = 1
        label.alpha = 0.0
        return label
    }()
    
    private let totalTimeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor(red: 0.843, green: 0.502, blue: 0.976, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.alpha = 0.0
        return label
    }()
    
    func configureTimerLabel(){
        self.view.addSubview(timerCircle)
        self.view.addSubview(timerLabel)
        self.view.addSubview(timeTypeLabel)
        self.view.addSubview(roundLabel)
        self.view.addSubview(totalTimeLabel)
        NSLayoutConstraint.activate([
            timerCircle.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            timerCircle.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height * 0.27),
            timerCircle.widthAnchor.constraint(equalTo: timerCircle.heightAnchor),
            timerCircle.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.68),
            
            timerLabel.centerXAnchor.constraint(equalTo: self.timerCircle.layoutMarginsGuide.centerXAnchor),
            timerLabel.topAnchor.constraint(equalTo: self.timerCircle.layoutMarginsGuide.topAnchor, constant: self.timerCircle.bounds.height * 0.39),
            timerLabel.widthAnchor.constraint(equalTo: self.timerCircle.widthAnchor, multiplier: 0.70),
            timerLabel.heightAnchor.constraint(equalTo: self.timerCircle.heightAnchor, multiplier: 0.36),
            
            timeTypeLabel.centerXAnchor.constraint(equalTo: self.timerCircle.layoutMarginsGuide.centerXAnchor),
            timeTypeLabel.topAnchor.constraint(equalTo: self.timerCircle.layoutMarginsGuide.topAnchor, constant: self.timerCircle.bounds.height * 0.29),
            timeTypeLabel.widthAnchor.constraint(equalTo: self.timerCircle.widthAnchor, multiplier: 0.656),
            timeTypeLabel.heightAnchor.constraint(equalTo: self.timerCircle.heightAnchor, multiplier: 0.17),
            
            roundLabel.centerXAnchor.constraint(equalTo: self.timerCircle.layoutMarginsGuide.centerXAnchor),
            roundLabel.topAnchor.constraint(equalTo: self.timerCircle.layoutMarginsGuide.topAnchor, constant: self.timerCircle.bounds.height * 0.32),
            roundLabel.widthAnchor.constraint(equalTo: self.timerCircle.widthAnchor, multiplier: 0.605),
            roundLabel.heightAnchor.constraint(equalTo: self.timerCircle.heightAnchor, multiplier: 0.17),
            
            totalTimeLabel.centerXAnchor.constraint(equalTo: self.timerCircle.layoutMarginsGuide.centerXAnchor),
            totalTimeLabel.topAnchor.constraint(equalTo: self.timerCircle.layoutMarginsGuide.topAnchor, constant: self.timerCircle.bounds.height * 0.547),
            totalTimeLabel.widthAnchor.constraint(equalTo: self.timerCircle.widthAnchor, multiplier: 0.38),
            totalTimeLabel.heightAnchor.constraint(equalTo: self.timerCircle.heightAnchor, multiplier: 0.19)
        ])
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonTapped))
        timerCircle.addGestureRecognizer(tapGesture)
        timerCircle.isUserInteractionEnabled = true
        calculateTime()
        runTimer()
    }
    
    //MARK: - UI Button Elements
    private lazy var cancelImg: UIImageView = {
        var imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: 63, height: 31)
        imageView.image = UIImage(named: "slider button")
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 63, height: 31))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "END GAME"
        label.textColor = UIColor(red: 1.0, green: 0.047, blue: 0.047, alpha: 1)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        imageView.addSubview(label)
        label.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 5).isActive = true
        label.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -5).isActive = true
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(touched(_:)))
        imageView.addGestureRecognizer(gestureRecognizer)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    @objc private func touched(_ gestureRecognizer: UIGestureRecognizer) {
        guard let touchedView = gestureRecognizer.view else { return }
            switch gestureRecognizer.state {
            case .changed:
                let locationInView = gestureRecognizer.location(in: touchedView)
                var newPos = touchedView.frame.origin.x + locationInView.x
                newPos = max(self.view.bounds.width * 0.293, newPos)
                newPos = min(self.view.bounds.width * 0.54, newPos)
                touchedView.frame.origin.x = newPos
                if touchedView.frame.origin.x >= self.view.bounds.width * 0.54 {
                    if !segueCalled {
                        segueCalled = true
                        Task {
                            await H.endGame(gameCode)
                            performSegue(withIdentifier: "toEnd", sender: self)
                        }
                    }
                } else {
                    segueCalled = false
                }
            case .ended:
                touchedView.frame.origin.x = self.view.bounds.width * 0.293
            default:
                break
            }
            UIView.animate(withDuration: 0.05, delay: 0.0, options: .curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
      }
    
    private lazy var scrollLabel: UIView  = {
        var view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 176, height: 58)
        view.layer.cornerRadius = 15
        view.layer.backgroundColor = UIColor(red: 1.0, green: 0.047, blue: 0.047, alpha: 1).cgColor
        return view
    }()
    
    private lazy var scrollTxt: UILabel  = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        let image0 = UIImage(named: "slider image")
        let imageView = UIImageView(image: image0)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        label.addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: label.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: label.trailingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: label.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
        return label
    }()
    
    func configureEndButton() {
        self.view.addSubview(scrollLabel)
        self.view.addSubview(scrollTxt)
        self.view.bringSubviewToFront(scrollTxt)
        self.view.addSubview(cancelImg)
        
        scrollLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.469).isActive = true
        scrollLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.071).isActive = true
        scrollLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        scrollLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height * 0.698).isActive = true
        
        cancelImg.translatesAutoresizingMaskIntoConstraints = false
        cancelImg.widthAnchor.constraint(equalTo: scrollLabel.widthAnchor, multiplier: 0.358).isActive = true
        cancelImg.heightAnchor.constraint(equalTo: scrollLabel.heightAnchor, multiplier: 0.534).isActive = true
        cancelImg.leadingAnchor.constraint(equalTo: scrollLabel.leadingAnchor, constant: self.view.bounds.width * 0.0266).isActive = true
        cancelImg.topAnchor.constraint(equalTo: scrollLabel.topAnchor, constant: self.view.bounds.height * 0.016).isActive = true
        
        scrollTxt.translatesAutoresizingMaskIntoConstraints = false
        scrollTxt.widthAnchor.constraint(equalTo: scrollLabel.widthAnchor, multiplier: 0.496).isActive = true
        scrollTxt.heightAnchor.constraint(equalTo: scrollLabel.heightAnchor, multiplier: 0.448).isActive = true
        scrollTxt.leadingAnchor.constraint(equalTo: scrollLabel.leadingAnchor, constant: self.view.bounds.width * 0.208).isActive = true
        scrollTxt.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height * 0.718).isActive = true
    }
    //MARK: - Timer Algorithm
    func runTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let strongSelf = self else {
                return
            }
            if !strongSelf.isPaused {
                if strongSelf.rounds! < 1 {
                    strongSelf.playMusic()
                    strongSelf.pauseOrPlayButton.setImage(strongSelf.end, for: .normal)
                    timer.invalidate()
                }
                if strongSelf.time! < 1 {
                    if strongSelf.moving {
                        strongSelf.time = strongSelf.seconds
                        strongSelf.moving = false
                        strongSelf.timeTypeLabel.text = "Game Time"
                        strongSelf.timerLabel.text = String(format:"%02i : %02i", strongSelf.time!/60, strongSelf.time! % 60)
                    } else {
                        strongSelf.time = strongSelf.moveSeconds
                        strongSelf.moving = true
                        strongSelf.timeTypeLabel.text = "Moving Time"
                        strongSelf.timerLabel.text = String(format:"%02i : %02i", strongSelf.time!/60, strongSelf.time! % 60)
                        strongSelf.round += 1
                        Task {
                            await H.updateCurrentRound(strongSelf.gameCode, strongSelf.round)
                        }
                        strongSelf.roundLabel.text = "Round \(strongSelf.round)"
                        strongSelf.rounds! -= 1
                    }
                }
                strongSelf.time! -= 1
                let minute = strongSelf.time!/60
                let second = strongSelf.time! % 60
                strongSelf.timerLabel.text = String(format:"%02i : %02i", minute, second)
                strongSelf.totalTime += 1
                let totalMinute = strongSelf.totalTime/60
                let totalSecond = strongSelf.totalTime % 60
                let attributedString = NSMutableAttributedString(string: "Total time\n", attributes: [NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: 20) ?? UIFont(name: "Dosis-Regular", size: 20)!])
                attributedString.append(NSAttributedString(string: String(format:"%02i : %02i", totalMinute, totalSecond), attributes: [NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: 15) ?? UIFont(name: "Dosis-Regular", size: 15)!]))
                strongSelf.totalTimeLabel.attributedText = attributedString
            }
        }
        
    }
    
    func calculateTime() {
        if isPaused {
            t = pauseTime - startTime - pausedTime
        }
        else {
            if pausedTime != 0 {
                t = Int(Date().timeIntervalSince1970) - startTime - pausedTime
            }
            else {
                t = 0
            }
        }
        let quotient = t/(moveSeconds + seconds)
        let remainder = t%(moveSeconds + seconds)
        if (remainder/moveSeconds) == 0 {
            self.timeTypeLabel.text = "Moving Time"
            self.time = (moveSeconds - remainder)
            self.moving = true
            let minute = (moveSeconds - remainder)/60
            let second = (moveSeconds - remainder) % 60
            self.timerLabel.text = String(format:"%02i : %02i", minute, second)
        }
        else {
            self.timeTypeLabel.text = "Game Time"
            self.time = (seconds - remainder)
            self.moving = false
            let minute = (seconds - remainder)/60
            let second = (seconds - remainder) % 60
            self.timerLabel.text = String(format:"%02i : %02i", minute, second)
        }
        self.totalTime = t
        let totalMinute = t/60
        let totalSecond = t % 60
        let attributedString = NSMutableAttributedString(string: "Total time\n", attributes: [NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: 20) ?? UIFont(name: "Dosis-Regular", size: 20)!])
        attributedString.append(NSAttributedString(string: String(format:"%02i : %02i", totalMinute, totalSecond), attributes: [NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: 15) ?? UIFont(name: "Dosis-Regular", size: 15)!]))
        self.totalTimeLabel.attributedText = attributedString
        self.round = quotient + 1
        Task {
            await H.updateCurrentRound(gameCode, self.round)
        }
        self.rounds! = self.rounds! - self.round
        self.roundLabel.text = "Round \(quotient + 1)"
    }
    
}
//MARK: - Protocol
extension HostTimerViewController: GetHost, HostUpdateListener {
    func getHost(_ host: Host) {
        self.seconds = host.gameTime
        self.moveSeconds = host.movingTime
        self.startTime = host.startTimestamp
        self.isPaused = host.paused
        self.pauseTime = host.pauseTimestamp
        self.pausedTime = host.pausedTime
        self.rounds = host.rounds
        self.messages = host.announcements
        self.gameStart = host.gameStart
        self.gameOver = host.gameover
        configureTimerLabel()
    }
    
    func updateHost(_ host: Host) {
        self.pauseTime = host.pauseTimestamp
        self.pausedTime = host.pausedTime
        self.messages = host.announcements
        self.gameStart = host.gameStart
    }
    
    func listen(_ _ : [String : Any]){
    }
}
