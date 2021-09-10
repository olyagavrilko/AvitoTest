//
//  UITableViewExtension.swift
//  AvitoTest
//
//  Created by Olya Ganeva on 10.09.2021.
//

import UIKit

extension UITableView {

    func register(_ cellType: AnyClass) {
        register(cellType, forCellReuseIdentifier: String(describing: cellType))
    }

    func reusableCell<T>(for indexPath: IndexPath) -> T? {
        dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath) as? T
    }
}
