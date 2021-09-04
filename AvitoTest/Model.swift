//
//  Model.swift
//  AvitoTest
//
//  Created by Olya Ganeva on 30.08.2021.
//

import Foundation

struct CompanyResponse: Decodable {
    let company: Company
}

struct Company: Decodable {
    let name: String
    let employees: [Employee]
}

struct Employee: Decodable {
    let name: String
    let phoneNumber: String
    let skills: [String]

    enum CodingKeys: String, CodingKey {
        case name
        case phoneNumber = "phone_number"
        case skills
    }
}
