//
//  EmployeeCell.swift
//  AvitoTest
//
//  Created by Olya Ganeva on 30.08.2021.
//

import UIKit

final class EmployeeCell: UITableViewCell {

    let nameLabel = UILabel()
    let phoneNumberLabel = UILabel()
    let skillsLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {

        addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])

        addSubview(phoneNumberLabel)
        phoneNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            phoneNumberLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            phoneNumberLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            phoneNumberLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])

        addSubview(skillsLabel)
        skillsLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            skillsLabel.topAnchor.constraint(equalTo: phoneNumberLabel.bottomAnchor, constant: 20),
            skillsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            skillsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            skillsLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
}
