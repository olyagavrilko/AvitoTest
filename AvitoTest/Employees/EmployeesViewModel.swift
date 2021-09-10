//
//  EmployeesViewModel.swift
//  AvitoTest
//
//  Created by Olya Ganeva on 10.09.2021.
//

import Foundation
import Network

protocol EmployeesViewModelDelegate: AnyObject {
    func update()
}

final class EmployeesViewModel {

    typealias Section = (title: String, viewModels: [EmployeeCellViewModel])

    private let monitor: NWPathMonitor
    private let networkingService: NetworkingService
    private let cache: EmployeesCache

    private let monitorQueue = DispatchQueue(label: "InternetConnectionMonitor")

    private var isNetworkConnectionExist = false
    private var isNetworkConnectionChecked = false

    private(set) var sections: [Section] = []

    weak var delegate: EmployeesViewModelDelegate?

    var sectionTitles: [String] {
        sections.map { $0.title }
    }

    init(monitor: NWPathMonitor, networkingService: NetworkingService, cache: EmployeesCache) {
        self.monitor = monitor
        self.networkingService = networkingService
        self.cache = cache
    }

    func viewDidLoad() {
        startInternetConnectionMonitoring()
    }

    func refreshControlValueChanged() {
        loadData()
    }

    private func startInternetConnectionMonitoring() {
        monitor.pathUpdateHandler = { [weak self] pathUpdateHandler in
            guard let self = self else {
                return
            }
            self.isNetworkConnectionExist = pathUpdateHandler.status == .satisfied
            if !self.isNetworkConnectionChecked {
                self.isNetworkConnectionChecked = true
                self.loadData()
            } else if pathUpdateHandler.status == .satisfied {
                self.loadData()
            }
        }

        monitor.start(queue: monitorQueue)
    }

    private func loadData() {
        if isNetworkConnectionExist {
            loadDataFromServer()
        } else {
            loadDataFromCache()
            // TODO: Сообщить юзеру, когда данные были обновлены последний раз
        }
    }

    private func loadDataFromServer() {
        networkingService.loadEmployees() { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let employees):
                self.sections = self.makeSections(using: employees)
                self.delegate?.update()
                self.saveToCache(employees)
            case .failure:
                self.loadDataFromCache()
            }
        }
    }

    private func loadDataFromCache() {
        cache.load() { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let employees):
                self.sections = self.makeSections(using: employees)
                self.delegate?.update()
            case .failure:
                // TODO: Отоборазить alert для юзера
                print("Не удалось загрузить данные")
            }
        }
    }

    private func saveToCache(_ employees: [Employee]) {
        cache.save(employees)
    }

    private func makeSections(using employees: [Employee]) -> [Section] {

        var dict: [String: [EmployeeCellViewModel]] = [:]
        var sections: [Section] = []

        for employee in employees {
            let key = String(employee.name.prefix(1))
            let viewModel = EmployeeCellViewModel(
                name: employee.name,
                phoneNumber: employee.phoneNumber,
                skills: employee.skills.joined(separator: ", "))
            if var employeesValue = dict[key] {
                employeesValue.append(viewModel)
                dict[key] = employeesValue
            } else {
                dict[key] = [viewModel]
            }
        }

        for (key, value) in dict {
            let viewModels = value.sorted(by: { $0.name < $1.name })
            let section = (title: key, viewModels: viewModels)
            sections.append(section)
        }

        return sections.sorted {
            $0.title < $1.title
        }
    }
}
