//
//  Date+String_Extension.swift
//  CustomerManager
//
//  Created by Wu hung-yi on 2018/7/8.
//  Copyright © 2018 Wu. All rights reserved.
//

import Foundation

extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.string(from: self)
    }
}
