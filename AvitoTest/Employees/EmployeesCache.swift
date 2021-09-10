//
//  EmployeesCache.swift
//  AvitoTest
//
//  Created by Olya Ganeva on 10.09.2021.
//

import Foundation

enum CacheError: Error {
    case general
}

final class EmployeesCache {

    enum Consts {
        static let fileName = "employeesCache.txt"
        static let lastSaveTimeKey = "lastSaveTime"
        static let secondsInHour: Double = 3600
    }

    private let userDefaults = UserDefaults.standard
    private let queue = DispatchQueue(label: "EmployeesCacheQueue")

    private var fileURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent(Consts.fileName)
    }

    private var isExpired: Bool {
        let currentTime = NSDate().timeIntervalSince1970
        let lastSaveTime = userDefaults.double(forKey: Consts.lastSaveTimeKey)
        return currentTime - lastSaveTime > Consts.secondsInHour
    }

    func load(completion: @escaping (Result<[Employee], CacheError>) -> Void) {
        queue.async {
            let result = self.load()
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    func save(_ employees: [Employee]) {
        queue.async {
            let data = try? JSONEncoder().encode(employees)

            guard let unwrappedData = data else {
                return
            }

            self.writeToFile(url: self.fileURL, data: unwrappedData)
            let timestamp = NSDate().timeIntervalSince1970
            self.userDefaults.set(timestamp, forKey: Consts.lastSaveTimeKey)
        }
    }

    private func load() -> Result<[Employee], CacheError> {
        guard !isExpired else {
            // TODO: Сообщить юзеру, что не получилось получить данные
            return .failure(.general)
        }

        guard let data = readFromFile(url: fileURL) else {
            return .failure(.general)
        }

        guard let employees = try? JSONDecoder().decode([Employee].self, from: data) else {
            return .failure(.general)
        }

        return .success(employees)
    }

    private func writeToFile(url: URL, data: Data) {
        do {
            try data.write(to: url)
        } catch let error as NSError {
            print("Failed to write to file: \(error.localizedDescription)")
        }
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
