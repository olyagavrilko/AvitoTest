//
//  ViewController.swift
//  AvitoTest
//
//  Created by Olya Ganeva on 30.08.2021.
//

import UIKit

final class ViewController: UIViewController {

    private let tableView = UITableView()
    var employees = [Employee]()

    typealias Section = (title: String, employees: [Employee])
    var sections: [Section] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadData()

        tableView.register(EmployeeCell.self, forCellReuseIdentifier: "EmployeeCell")
        tableView.delegate = self
        tableView.dataSource = self

//        sections = buildSections(employees: employees)
    }

    private func setupViews() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func buildSections(employees: [Employee]) -> [Section] {

        var dict: [String: [Employee]] = [:]
        var sections: [Section] = []
        for employee in employees {
            let key = String(employee.name.prefix(1))
            if var employeesValue = dict[key] {
                employeesValue.append(employee)
                dict[key] = employeesValue
            } else {
                dict[key] = [employee]
            }
        }

        for (key, value) in dict {
            let employees = value.sorted(by: { $0.name < $1.name })
            let section = (title: key, employees: employees)
            sections.append(section)
        }

        return sections.sorted {
            $0.title < $1.title
        }
    }

//---------------------------------------
    let url = URL(string: "https://run.mocky.io/v3/1d1cb4ec-73db-4762-8c4b-0b8aa3cecd4c")

    func loadData() {
        guard let unwrappedUrl = url else {
            return
        }

        let task = URLSession.shared.dataTask(with: unwrappedUrl) {(data, response, error) in
            guard let data = data else {
                return
            }

            let company = try? JSONDecoder().decode(CompanyResponse.self, from: data)

            guard let employees = company?.company.employees else {
                return
            }
            self.employees = employees
            self.sections = self.buildSections(employees: employees)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }

        task.resume()
    }
//    ------------------------------------------------------
}

extension ViewController: UITableViewDelegate {

}

extension ViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].employees.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sections.map {
            $0.title
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: EmployeeCell = tableView.dequeueReusableCell(withIdentifier: "EmployeeCell", for: indexPath) as? EmployeeCell else {
            return UITableViewCell()
        }

//        cell.nameLabel.text = employees[indexPath.row].name
//        cell.phoneNumberLabel.text = employees[indexPath.row].phoneNumber
//        cell.skillsLabel.text = employees[indexPath.row].skills.joined(separator: ", ")

        cell.nameLabel.text = sections[indexPath.section].employees[indexPath.row].name
        cell.phoneNumberLabel.text = sections[indexPath.section].employees[indexPath.row].phoneNumber
        cell.skillsLabel.text = sections[indexPath.section].employees[indexPath.row].skills.joined(separator: ", ")
        return cell
    }
}
