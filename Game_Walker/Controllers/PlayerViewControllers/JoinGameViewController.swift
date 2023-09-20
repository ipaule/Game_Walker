//
//  PlayerFrame1.swift
//  Game_Walker
//
//  Created by Paul on 6/7/22.
//

import Foundation
import UIKit

class JoinGameViewController: BaseViewController {
    
    @IBOutlet weak var gamecodeTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    private let audioPlayerManager = AudioPlayerManager()
    
    private var storedGameCode = UserData.readGamecode("gamecode") ?? ""
    private var storedUsername = UserData.readUsername("username") ?? ""
    private var storedPlayer = UserData.readPlayer("player") ?? nil
    private var storedTeamName = UserData.readTeam("team")?.name ?? ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        setUpTextFields()
        configureNavItem()
        configureJoinBtn()
    }
    
    private func configureJoinBtn(){
        nextButton.backgroundColor = UIColor(red: 0.21, green: 0.67, blue: 0.95, alpha: 1)
        nextButton.layer.cornerRadius = 8
    }
    
    private func setDelegates() {
        H.delegates.append(self)
        T.delegates.append(self)
    }
    
    private func setUpTextFields() {
        gamecodeTextField.delegate = self
        usernameTextField.delegate = self
        gamecodeTextField.translatesAutoresizingMaskIntoConstraints = false
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        gamecodeTextField.keyboardType = .asciiCapableNumberPad
        gamecodeTextField.placeholder = storedGameCode != "" ? storedGameCode : "gamecode"
        usernameTextField.placeholder = storedUsername != "" ? storedUsername : "username"
        gamecodeTextField.layer.borderWidth = 3
        gamecodeTextField.layer.borderColor = UIColor.black.cgColor
        gamecodeTextField.layer.cornerRadius = 10
        usernameTextField.layer.borderWidth = 3
        usernameTextField.layer.borderColor = UIColor.black.cgColor
        usernameTextField.layer.cornerRadius = 10
    }
    
    private func configureNavItem() {
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(image: UIImage(named: "back button 1"), style: .plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    @objc func back(sender: UIBarButtonItem) {
        performSegue(withIdentifier: "ToMainVC", sender: self)
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        self.audioPlayerManager.playAudioFile(named: "blue", withExtension: "wav")
        
        let savedGameCode = UserData.readGamecode("gamecode") ?? ""
        let savedUserName = UserData.readUsername("username") ?? ""
        var player = UserData.readPlayer("player") ?? Player(gamecode: "", name: "")
        
        guard let gamecode = gamecodeTextField.text else { return }
        guard let username = usernameTextField.text else { return }
        guard let uuid = UserData.readUUID() else { return }
        
        if gamecode.isEmpty && username.isEmpty {
            if !savedGameCode.isEmpty && !savedUserName.isEmpty {
                if (UserData.readTeam("team") != nil) {
                    // User wants to join the game with the stored game code, username, and player object
                    performSegue(withIdentifier: "ResumeGameSegue", sender: self)
                } else {
                    // User chooses between creating or joining a team
                    performSegue(withIdentifier: "goToPF2VC", sender: self)
                }
            } else {
                alert(title: "", message: "Please enter gamecode and username")
                return
            }
        } else if gamecode == savedGameCode && username == savedUserName {
            if (UserData.readTeam("team") != nil) {
                // User wants to join the game with the stored game code, username, and player object
                performSegue(withIdentifier: "ResumeGameSegue", sender: self)
            } else {
                // User chooses between creating or joining a team
                performSegue(withIdentifier: "goToPF2VC", sender: self)
            }
        } else if savedGameCode.isEmpty && savedUserName.isEmpty {
            
            // User is joining a new game
            if !gamecode.isEmpty && !username.isEmpty {
                // Create a new player object for the new game
                player = Player(gamecode: gamecode, name: username)
                
                // Join the game
                Task { @MainActor in
                    // Try await P.addPlayer(gamecode, player, uuid)
                    do {
                        try await P.addPlayer(gamecode, player, uuid)
                        UserData.writeGamecode(gamecode, "gamecode")
                        UserData.writeUsername(username, "username")
                        UserData.writePlayer(player, "player")
                        performSegue(withIdentifier: "goToPF2VC", sender: self)
                    } catch GamecodeError.invalidGamecode(let text) {
                        print(text)
                        alert(title: "Invalid Gamecode", message: text)
                        return
                    }
                }
            } else {
                // Invalid input
                alert(title: "", message: "Please enter both game code and username.")
                return
            }
            
        } else if (gamecode != savedGameCode) && (username.isEmpty || username == savedUserName) {
            Task { @MainActor in
                if (UserData.readTeam("team") != nil) {
                    do {
                        try await T.leaveTeam(savedGameCode, savedUserName, player)
                    } catch ServerError.serverError(let text){
                        print(text)
                        serverAlert(text)
                        return
                    }
                }
                P.removePlayer(savedGameCode, uuid)
                player = Player(gamecode: gamecode, name: savedUserName)
                do{
                    try await P.addPlayer(gamecode, player, uuid)
                    UserData.writeGamecode(gamecode, "gamecode")
                    UserData.writePlayer(player, "player")
                    self.performSegue(withIdentifier: "goToPF2VC", sender: self)
                } catch GamecodeError.invalidGamecode(let text){
                    print(text)
                    alert(title: "Invalid Gamecode", message: text)
                    return
                }
            }
        } else if (gamecode.isEmpty || gamecode == savedGameCode) && username != savedUserName {
            Task { @MainActor in
                do {
                    try await P.modifyName(savedGameCode, uuid, username)
                    player = Player(gamecode: gamecode, name: username)
                    UserData.writePlayer(player, "player")
                    UserData.writeUsername(username, "username")
                } catch GamecodeError.invalidGamecode(let text){
                    print(text)
                    alert(title: "Invalid Gamecode", message: text)
                    return
                }
                if (UserData.readTeam("team") != nil) {
                    self.performSegue(withIdentifier: "ResumeGameSegue", sender: self)
                } else {
                    self.performSegue(withIdentifier: "goToPF2VC", sender: self)
                }
            }
        } else if gamecode != savedGameCode && username != savedUserName {
            Task {@MainActor in
                if UserData.readTeam("team") != nil {
                    do {
                        try await T.leaveTeam(savedGameCode, savedUserName, player)
                    } catch ServerError.serverError(let text){
                        print(text)
                        serverAlert(text)
                        return
                    }
                }
                P.removePlayer(savedGameCode, uuid)
                player = Player(gamecode: gamecode, name: username)
                do {
                    try await P.addPlayer(gamecode, player, uuid)
                    UserData.writeGamecode(gamecode, "gamecode")
                    UserData.writeUsername(username, "username")
                    UserData.writePlayer(player, "player")
                    self.performSegue(withIdentifier: "goToPF2VC", sender: self)
                } catch GamecodeError.invalidGamecode(let text) {
                    print(text)
                    alert(title: "Invalid Gamecode", message: text)
                    return
                }
            }
        } else {
            alert(title: "", message: "Invalid Input!")
            return
        }
    }
    
    func listen(_ _ : [String : Any]){
    }
}

// MARK: - UITextFieldDelegate
extension JoinGameViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == gamecodeTextField {
            usernameTextField.becomeFirstResponder()
        } else if textField == usernameTextField {
            nextButtonPressed(nextButton)
        }
        return true
    }
}

// MARK: - listener
extension JoinGameViewController: HostUpdateListener, TeamUpdateListener {
    func updateTeams(_ teams: [Team]) {
        
    }
    
    func updateHost(_ host: Host) {
        
    }
}
