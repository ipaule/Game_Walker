//
//  HostCreateOrJoinViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 7/22/22.
//

import UIKit

class HostCreateOrJoinViewController: BaseViewController {

    @IBOutlet weak var joinButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        T.delegates.append(self)
    }

    @IBAction func createButtonPressed(_ sender: UIButton) {
        let gc = String(Int.random(in: 100000 ... 999999))
//        let host = Host(gamecode: "705154")
        let host = Host(gamecode: gc)
        H.createGame(gc, host)
        UserData.writeGamecode("705154", "gamecodestring")
//        UserData.writeGamecode(gc, "gamecodestring")
        T.listenTeams("705154", onListenerUpdate: listen(_:))
//        T.listenTeams(gc, onListenerUpdate: listen(_:))
        performSegue(withIdentifier: "CreateGameSegue", sender: self)
    }
    
    @IBAction func joinButtonPressed(_ sender: UIButton) {
        if UserData.readGamecode("gamecodestring") != nil {
            performSegue(withIdentifier: "HostGamecodeSegue", sender: self)
        } else {
            alert(title: "", message: "No game exists")
        }
    }
    
    func listen(_ _ : [String : Any]){
    }
}
// MARK: - TeamListner
extension HostCreateOrJoinViewController: TeamUpdateListener {
    func updateTeams(_ teams: [Team]) {
        
    }
}
