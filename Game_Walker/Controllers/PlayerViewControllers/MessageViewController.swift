//
//  MessageViewController.swift
//  Game_Walker
//
//  Created by Noah Kim on 1/25/23.
//

import Foundation
import UIKit

class MessageViewController: UIViewController {
    
    private let fontColor: UIColor = UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1)
    private var messages: [String]?
    private let cellSpacingHeight: CGFloat = 3

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        setUpViews()
        makeConstraints()
    }
    
    convenience init(messages: [String]) {
        self.init()
        /// present 시 fullScreen (화면을 덮도록 설정) -> 설정 안하면 pageSheet 형태 (위가 좀 남아서 밑에 깔린 뷰가 보이는 형태)
        self.messages = messages
        self.modalPresentationStyle = .overFullScreen
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // curveEaseOut: 시작은 천천히, 끝날 땐 빠르게
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut) { [weak self] in
            self?.containerView.transform = .identity
            self?.containerView.isHidden = false
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // curveEaseIn: 시작은 빠르게, 끝날 땐 천천히
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn) { [weak self] in
            self?.containerView.transform = .identity
            self?.containerView.isHidden = true
        }
    }
    
    private func configureTableView() {
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTableView.register(MessageTableViewCell.self, forCellReuseIdentifier: MessageTableViewCell.identifier)
        messageTableView.backgroundColor = .clear
        messageTableView.allowsSelection = false
        messageTableView.separatorStyle = .none
    }
    
    private func setUpViews() {
        self.view.addSubview(containerView)
        containerView.addSubview(messageLabel)
        containerView.addSubview(messageTableView)
        containerView.addSubview(buttonView)
    }
    
    private func makeConstraints() {
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageTableView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 210),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -210),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            messageLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 60),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -60),
            messageLabel.bottomAnchor.constraint(equalTo: messageTableView.topAnchor, constant: 8),
            messageLabel.heightAnchor.constraint(equalTo: messageLabel.widthAnchor, multiplier: 0.23),
            messageLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            messageTableView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 10),
            messageTableView.bottomAnchor.constraint(equalTo: buttonView.topAnchor, constant: 8),
            messageTableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 25),
            messageTableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -25),
            messageTableView.heightAnchor.constraint(equalTo: messageTableView.widthAnchor, multiplier: 0.536),
            messageTableView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            buttonView.topAnchor.constraint(equalTo: messageTableView.bottomAnchor, constant: 8),
            buttonView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 1),
            buttonView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -1),
            buttonView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -1),
            buttonView.heightAnchor.constraint(equalTo: buttonView.widthAnchor, multiplier: 0.27),
            buttonView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
    }
    
    private let messageTableView: UITableView = {
        let tableview = UITableView()
        return tableview
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(cgColor: .init(red: 0.208, green: 0.671, blue: 0.953, alpha: 1))
        view.layer.cornerRadius = 13
        
        ///for animation effect
        view.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        
        return view
    }()
    
    private lazy var  messageLabel: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "message 1")
        return imageView
    }()
    
    private lazy var buttonView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    public func addActionToButton(title: String? = nil, titleColor: UIColor, backgroundColor: UIColor = .white, completion: (() -> Void)? = nil) {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont(name: "Dosis-Regular", size: 17)

        // enable
        button.setTitle(title, for: .normal)
        button.setTitleColor(fontColor, for: .normal)
        button.setBackgroundImage(UIColor.white.image(), for: .normal)

        // disable
        button.setTitleColor(.gray, for: .disabled)
        button.setBackgroundImage(UIColor.gray.image(), for: .disabled)

        // layer
        button.layer.cornerRadius = 10.0
        button.layer.masksToBounds = true

        button.addAction(for: .touchUpInside) { _ in
            completion?()
        }
        buttonView.addSubview(button)
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor, constant: 80),
            button.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor, constant: -80),
            button.heightAnchor.constraint(equalTo: button.widthAnchor, multiplier: 0.3),
            button.centerXAnchor.constraint(equalTo: buttonView.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: buttonView.centerYAnchor)
        ])
    }
}

// MARK: - TableView
extension MessageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messageTableView.dequeueReusableCell(withIdentifier: MessageTableViewCell.identifier, for: indexPath) as! MessageTableViewCell
        cell.configureTableViewCell(name: "Announcement\(indexPath)")
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        guard let messages = messages else {
            return 0
        }
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return 1
     }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
}