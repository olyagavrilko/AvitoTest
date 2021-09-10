//
//  NetworkingService.swift
//  AvitoTest
//
//  Created by Olya Ganeva on 10.09.2021.
//

import Foundation
import Network

enum NetworkingError: Error {
    case general
}

final class NetworkingService {

    enum Consts {
        static let urlString = "https://run.mocky.io/v3/1d1cb4ec-73db-4762-8c4b-0b8aa3cecd4c"
    }

    private let session: URLSession = {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 5
        return URLSession(configuration: sessionConfig)
    }()

    func loadEmployees(completion: @escaping (Result<[Employee], NetworkingError>) -> Void) {
        guard let url = URL(string: Consts.urlString) else {
            return
        }

        let task = session.dataTask(with: url) { data, response, error in
            guard let data = data else {
                return completion(.failure(.general))
            }

            let company = try? JSONDecoder().decode(CompanyResponse.self, from: data)

            guard let employees = company?.company.employees else {
                return completion(.failure(.general))
            }

            DispatchQueue.main.async {
                completion(.success(employees))
            }
        }

        task.resume()
    }
}
