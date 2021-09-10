//
//  EmployeesViewController.swift
//  AvitoTest
//
//  Created by Olya Ganeva on 30.08.2021.
//

import UIKit

final class EmployeesViewController: UIViewController {

    private let viewModel: EmployeesViewModel
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let refreshControl = UIRefreshControl()

    init(viewModel: EmployeesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()

        viewModel.viewDidLoad()
    }

    private func setupViews() {
        refreshControl.addTarget(self, action: #selector(refreshControlValueChanged), for: .valueChanged)
        tableView.refreshControl = refreshControl
        refreshControl.beginRefreshing()

        tableView.register(EmployeeCell.self)
        tableView.dataSource = self
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func refreshControlValueChanged() {
        viewModel.refreshControlValueChanged()
    }
}

extension EmployeesViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].viewModels.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sections[section].title
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return viewModel.sectionTitles
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: EmployeeCell = tableView.reusableCell(for: indexPath) else {
            return UITableViewCell()
        }

        cell.viewModel = viewModel.sections[indexPath.section].viewModels[indexPath.row]
        return cell
    }
}

extension EmployeesViewController: EmployeesViewModelDelegate {

    func update() {
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
}
