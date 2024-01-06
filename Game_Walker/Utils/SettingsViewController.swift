//
//  SettingsViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 12/21/23.
//

import Foundation
import UIKit

class SettingsViewController: BaseViewController {
    
    private var white = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
    private var yellow = UIColor(red: 0.94, green: 0.71, blue: 0.11, alpha: 1.00)

    private var usesSound : Bool = UserData.getUserSoundPreference()
    private var usesVibration : Bool = true //TODO: - true for now but needs change
    //private var usesVibration = UserData.getUserVibrationPreference()

    weak var delegate: SettingsDelegate?

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = yellow
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Settings"
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 40, weight: .bold)

        return label
    }()

    private lazy var soundsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "GemunuLibre-SemiBold", size: 30)
        label.textColor = white
        label.text = "Sounds"
        return label
    }()


    private lazy var vibrationsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "GemunuLibre-SemiBold", size: 30)
        label.textColor = white
        label.text = "Vibrations"
        return label
    }()

    private lazy var soundsSwitchButton: SoundsVibrationsCustomButton = {
        let button = SoundsVibrationsCustomButton()
        return button
    }()

    private lazy var vibrationsSwitchButton: SoundsVibrationsCustomButton = {
        let button = SoundsVibrationsCustomButton()
        return button
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 40
        return stackView
    }()
    
    private lazy var confirmButton: UIButton = {
        var button = UIButton()
        button.setTitle("CONFIRM", for: .normal)
        button.titleLabel?.font = UIFont(name: "GemunuLibre-Bold", size: 20)
        button.setTitleColor(yellow, for: .normal)
        button.layer.backgroundColor = white.cgColor
        button.layer.cornerRadius = 10.0
        button.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(stackView)
        containerView.addSubview(confirmButton)
        let soundsStack = UIStackView(arrangedSubviews: [soundsLabel, soundsSwitchButton])
        soundsStack.axis = .horizontal
        let vibrationsStack = UIStackView(arrangedSubviews: [vibrationsLabel, vibrationsSwitchButton])
        vibrationsStack.axis = .horizontal
        stackView.addArrangedSubview(soundsStack)
        stackView.addArrangedSubview(vibrationsStack)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.heightAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 1.01),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 5),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -5),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -16),
            confirmButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.38),
            confirmButton.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.11),
            confirmButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            confirmButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -UIScreen.main.bounds.size.height * 20/812)
        ])
        
        // Tap gesture to dismiss modal when touched around
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        soundsSwitchButton.addTarget(self, action: #selector(soundsSwitchValueChanged(_:)), for: .valueChanged)
        vibrationsSwitchButton.addTarget(self, action: #selector(vibrationsSwitchValueChanged(_:)), for: .valueChanged)
        soundsSwitchButton.delegate = self
        vibrationsSwitchButton.delegate = self
    }
    
    @objc func soundsSwitchValueChanged(_ sender: CustomSwitchButton) {
        print("Sounds Switch Value Changed: \(sender.isOn)")
    }

    @objc func vibrationsSwitchValueChanged(_ sender: CustomSwitchButton) {
        print("Vibrations Switch Value Changed: \(sender.isOn)")
    }
    
    @objc func confirmTapped() {
        //TODO:- save user defaults
        UserData.setUserSoundPreference(usesSound)
        //UserData.setUserVibrationPreference(usesVibration)

        delegate?.didChangeSettings(usesSound, usesVibration)
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: containerView)
        if !containerView.point(inside: location, with: nil) {
            self.presentingViewController?.dismiss(animated: true)
        }
    }
}

extension SettingsViewController: CustomSwitchButtonDelegate {
    func isOnValueChange(_ sender: UIButton, isOn: Bool) {
        //TODO:- change vibrations or sounds accordingly
        usesSound = isOn
        //usesVibration = isOn
        // need to implement if case that the isOn varies by button
    }
    
}
