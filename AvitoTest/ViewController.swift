//
//  ViewController.swift
//  AvitoTest
//
//  Created by Olya Ganeva on 30.08.2021.
//

import UIKit
import Network

final class ViewController: UIViewController {

    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "InternetConnectionMonitor")

    let defaults = UserDefaults.standard

    private let tableView = UITableView()
    var employees = [Employee]()

    typealias Section = (title: String, employees: [Employee])
    var sections: [Section] = []

    private var isConnected = true
    private var isTimeOut = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
//        loadData()

        tableView.register(EmployeeCell.self, forCellReuseIdentifier: "EmployeeCell")
        tableView.delegate = self
        tableView.dataSource = self

//        sections = buildSections(employees: employees)

        monitor.pathUpdateHandler = { pathUpdateHandler in
            if pathUpdateHandler.status == .satisfied {
                self.loadDataFromServer()
                print("Internet connection is on.")
                let currentTime = NSDate().timeIntervalSince1970
                print("time", currentTime)
            } else {
                self.loadFromFile()
                print("There's no internet connection.")
            }
        }

        monitor.start(queue: queue)
    }

    private func loadFromFile() {
        let currentTime = NSDate().timeIntervalSince1970

        if currentTime - self.defaults.double(forKey: "LastSaveTime") < 3600 {
            let employees = self.loadEmploeesFromFile()
            self.sections = self.buildSections(employees: employees)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } else {
            print("Error")
        }
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

// MARK: - Network

    let url = URL(string: "https://run.mocky.io/v3/1d1cb4ec-73db-4762-8c4b-0b8aa3cecd4c")

    func loadData() {

        if isConnected {
            loadDataFromServer()
        } else {
            let employees = loadEmploeesFromFile()
            sections = buildSections(employees: employees)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    func loadDataFromServer() {
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
            self.saveData()

        }
        task.resume()
    }

    // MARK: - Cache

    private var fileURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("cache.txt")
    }

    private func saveData() {
        let data = try? JSONEncoder().encode(employees)

        guard let unwrappedData = data else {
            return
        }

        writeToFile(url: fileURL, data: unwrappedData)
    }

    private func loadEmploeesFromFile() -> [Employee] {

        if isTimeOut {
            return []
        } else {
            guard let data = readFromFile(url: fileURL) else {
                return []
            }

            guard let employees = try? JSONDecoder().decode([Employee].self, from: data) else {
                return []
            }

            return employees
        }
    }

    private func writeToFile(url: URL, data: Data) {
        do {
            try data.write(to: url)
        } catch let error as NSError {
            print("Failed to write to file: \(error.localizedDescription)")
        }
        let timestamp = NSDate().timeIntervalSince1970
        defaults.set(timestamp, forKey: "LastSaveTime")
    }

    private func readFromFile(url: URL) -> Data? {
        do {
            return try String(contentsOfFile: url.path).data(using: .utf8)
        } catch let error as NSError {
            print("Failed to read from file: \(error.localizedDescription)")
            return nil
        }
    }

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

// MARK: - Don't pay attention

class Server {

    static var shared = Server()

    func loadData(with url: URL, completionHandler: (Data?, URLResponse?, Error?) -> Void) {
        let data = readFromFile(url: fileURL)
        completionHandler(data, nil, nil)
    }

    func readFromFile(url: URL) -> Data? {
        do {
            return try String(contentsOfFile: url.path).data(using: .utf8)
        } catch let error as NSError {
            print("Failed to read from file: \(error.localizedDescription)")
            return nil
        }
    }

    var fileURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("backend.txt")
    }
}
