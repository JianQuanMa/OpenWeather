//
//  UITableView.swift
//  OpenWeather
//
//  Created by Jian Quan Ma on 1/18/23.
//

import UIKit

extension UITableView {
    func register<T: UITableViewCell>(_ : T.Type) {
        register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
    }
    func dequeue<T: UITableViewCell>(_ : T.Type) -> T {
        dequeueReusableCell(withIdentifier: T.reuseIdentifier) as! T
    }
}

extension UITableViewCell {
    static var reuseIdentifier: String {
            String(describing: self)
    }
}
