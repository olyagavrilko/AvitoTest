//
//  EmployeeCell.swift
//  AvitoTest
//
//  Created by Olya Ganeva on 30.08.2021.
//

import UIKit

struct EmployeeCellViewModel {
    let name: String
    let phoneNumber: String
    let skills: String
}

final class EmployeeCell: UITableViewCell {

    enum Consts {
        static let horizontalInset: CGFloat = 20
        static let verticalInset: CGFloat = 20
        static let verticalSpacing: CGFloat = 16
    }

    private let nameLabel = UILabel()
    private let phoneNumberLabel = UILabel()
    private let skillsLabel = UILabel()

    var viewModel: EmployeeCellViewModel? {
        didSet {
            nameLabel.text = viewModel?.name
            phoneNumberLabel.text = viewModel?.phoneNumber
            skillsLabel.text = viewModel?.skills
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Consts.verticalSpacing
        contentView.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Consts.verticalInset),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Consts.horizontalInset),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Consts.horizontalInset),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Consts.verticalInset)
        ])

        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(phoneNumberLabel)
        stackView.addArrangedSubview(skillsLabel)
    }
}
