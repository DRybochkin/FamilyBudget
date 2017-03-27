//
//  DataMigration.swift
//  FamilyBudget
//
//  Created by Dmitry Rybochkin on 06.03.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import UIKit

class DataMigration: NSObject {
    let version: Int
    let rules: [Int:[String]]

    init(version: Int, rules: [Int: [String]]) {
        self.version = version
        self.rules = rules
    }
}
