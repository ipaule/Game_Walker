//
//  RefereeTeamTableViewCell.swift
//  Game_Walker
//
//  Created by 김현식 on 1/30/23.
//

import Foundation
import UIKit

class RefereeTableViewCell: UITableViewCell {
    
    static let identifier = "RefereeTableViewCell"
     
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private var teamIconImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let teamNumLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-Bold", size: 20)
        label.numberOfLines = 1
        return label
    }()
    
    private var teamNameLabel: UILabel = {
       let label = UILabel()
        label.clipsToBounds = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-Regular", size: 15)
        label.numberOfLines = 0
        return label
    }()
    
    private var scoreLabel: UILabel = {
        let label = UILabel()
        label.clipsToBounds = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-Bold", size: 25)
        label.numberOfLines = 0
        return label
    }()

    private let borderView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 85, width: 330, height: 2))
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 1).cgColor
        return view
    }()
    
    private lazy var labelView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setLabelConstraints() {
        labelView.addSubview(teamNumLabel)
        labelView.addSubview(teamNameLabel)
        
        NSLayoutConstraint.activate([
            teamNumLabel.centerXAnchor.constraint(equalTo: labelView.centerXAnchor),
            teamNumLabel.widthAnchor.constraint(equalTo: labelView.widthAnchor),
            teamNumLabel.heightAnchor.constraint(equalTo: labelView.heightAnchor, multiplier: 0.45),
            teamNumLabel.centerYAnchor.constraint(equalTo: labelView.centerYAnchor, constant: -13),
            
            teamNameLabel.centerXAnchor.constraint(equalTo: labelView.centerXAnchor),
            teamNameLabel.widthAnchor.constraint(equalTo: labelView.widthAnchor),
            teamNameLabel.heightAnchor.constraint(equalTo: labelView.heightAnchor, multiplier: 0.45),
            teamNameLabel.centerYAnchor.constraint(equalTo: labelView.centerYAnchor, constant: 13)
        ])
    }
    
    func configureRankTableViewCellWithScore(imageName: String, teamNum: String, teamName: String, points: String) {
        contentView.addSubview(containerView)
        contentView.addSubview(borderView)
        containerView.addSubview(teamIconImage)
        containerView.addSubview(scoreLabel)
        containerView.addSubview(labelView)
        setLabelConstraints()

            NSLayoutConstraint.activate([
                containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
                containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
                
                teamIconImage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0),
                teamIconImage.topAnchor.constraint(equalTo: containerView.topAnchor),
                teamIconImage.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                teamIconImage.widthAnchor.constraint(equalTo: teamIconImage.heightAnchor),
                teamIconImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                
            
                labelView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                labelView.heightAnchor.constraint(equalTo: containerView.heightAnchor),
                labelView.widthAnchor.constraint(equalToConstant: 120),
                labelView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                
                NSLayoutConstraint(item: scoreLabel, attribute: .right, relatedBy: .equal, toItem: containerView, attribute: .right, multiplier: 1, constant: 0),
                scoreLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                scoreLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1),
                scoreLabel.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.8),
                
                borderView.widthAnchor.constraint(equalTo: contentView.layoutMarginsGuide.widthAnchor),
                borderView.heightAnchor.constraint(equalToConstant: 2.0),
                borderView.centerXAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerXAnchor),
                borderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
            teamIconImage.image = UIImage(named: imageName)
            teamNameLabel.text = teamName
            teamNumLabel.text = teamNum
            scoreLabel.text = points
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
}

