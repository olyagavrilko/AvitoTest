//
//  EmployeesAssembly.swift
//  AvitoTest
//
//  Created by Olya Ganeva on 10.09.2021.
//

import Foundation
import Network

final class EmployeesAssembly {

    func assembleViewController() -> EmployeesViewController {
        let monitor = NWPathMonitor()
        let networkingService = NetworkingService()
        let cache = EmployeesCache()
        let viewModel = EmployeesViewModel(
            monitor: monitor,
            networkingService: networkingService,
            cache: cache)
        let viewController = EmployeesViewController(viewModel: viewModel)
        viewModel.delegate = viewController
        return viewController
    }
}
