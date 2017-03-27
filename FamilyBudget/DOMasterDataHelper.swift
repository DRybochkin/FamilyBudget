//
//  DOMasterDataHelper.swift
//  FamilyBudget
//
//  Created by Dmitry Rybochkin on 06.03.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import Foundation
import SQLite

enum TableTypes: String {
    case
    appOptions = "AppOptions",
    categories = "Categories",
    users = "Users",
    transactions = "Transacions"
    static let allValues = [appOptions, users, categories, transactions]
}

class DOMasterDataHelper {
    static private let tableName = "sqlite_master"
    static private let entityName = Expression<String>("name")
    static private let entityType = Expression<String>("type")
    static private var table = Table(tableName)

    static private let tables: [TableTypes: DataMigration] = [
        TableTypes.appOptions: DataMigration(version: 1, rules: [:]),
        TableTypes.users: DataMigration(version: 1, rules: [:]),
        TableTypes.categories: DataMigration(version: 1, rules: [:]),
        TableTypes.transactions: DataMigration(version: 1, rules: [:])

        //TableTypes.AppOptions: DataMigration(version: 1, rules: [0: ["INSERT INTO '%@' (userId, lastTick, notificationToken) SELECT userId, lastTick, '' as notificationToken FROM '%@'"]]),
        //TableTypes.Users: DataMigration(version: 1, rules: [0: ["INSERT INTO '%@' (userId, userTitle, userPassword, userGroupKeyword) SELECT userId, userTitle, userPassword, userGroupKeyword FROM '%@'"]]),
        //TableTypes.Categories: DataMigration(version: 1, rules: [0: ["INSERT INTO '%@' (categoryId, userId, categoryTitle, categoryType, categoryDeleted, categoryUploaded) SELECT categoryId, userId, categoryTitle, 
        // categoryType, categoryDeleted, categoryUploaded FROM '%@'"]]),
        //TableTypes.Transactions: DataMigration(version: 1, rules: [0: ["INSERT INTO '%@' (transactionId, categoryId, userId, transactionDueDate, transactionMonth, transactionYear,
        // transactionCost, transactionProfit, transactionDescription, transactionDeleted, transactionUploaded) SELECT transactionId, categoryId, userId, transactionDueDate, transactionMonth, transactionYear, 10.1, 1.9, transactionDescription, transactionDeleted, transactionUploaded FROM '%@'"]])
    ]

    static func getTableName(_ tableType: TableTypes) -> String {
        return tableType.rawValue
    }

    static func getTableVersion(_ tableType: TableTypes) -> Int {
        if (tables.keys.contains(tableType)) {
            return tables[tableType]!.version
        }
        return 1
    }

    static func fullTableName(_ tableType: TableTypes, version: Int = -1) -> String {
        if (version > 0) {
            return String(format: "%@.v%d", getTableName(tableType), version)
        }
        return String(format: "%@.v%d", getTableName(tableType), getTableVersion(tableType))
    }

    static private func createTable(_ tableType: TableTypes) -> Bool {
        if (tableType == TableTypes.appOptions) {
            return DOOptionsDataHelper.createTable()
        } else if (tableType == TableTypes.categories) {
            return DOCategoryDataHelper.createTable()
        } else if (tableType == TableTypes.users) {
            return DOUserDataHelper.createTable()
        } else {
            return DOTransactionDataHelper.createTable()
        }
    }

    static private func dropTable(_ tableType: TableTypes) -> Bool {
        if (tableType == TableTypes.transactions) {
            return DOTransactionDataHelper.dropTable()
        } else if (tableType == TableTypes.categories) {
            return DOCategoryDataHelper.dropTable()
        } else if (tableType == TableTypes.users) {
            return DOUserDataHelper.dropTable()
        } else {
            return DOOptionsDataHelper.dropTable()
        }
    }

    static func check(_ tableType: TableTypes) -> Bool {
        do {
            let items = try SQLiteDataStore.sharedInstance.db.prepare(table.filter(entityType == "table").filter(entityName == fullTableName(tableType)).limit(1))
            for _ in items {
                return true
            }
        } catch {
            print("find \(tableName) error: ", error)
        }
        return false
    }

    static func getVersion(_ tableType: TableTypes) -> Int {
        var results: Int = 0
        do {
            let items = try SQLiteDataStore.sharedInstance.db.prepare(table.filter(entityType == "table").filter(entityName.like(getTableName(tableType)+"%")))
            for item in items {
                let ver = Int(("0" + item[entityName]).components(separatedBy: CharacterSet.decimalDigits.inverted).joined())!
                if (ver > results) {
                    results = ver
                }
            }
        } catch {
            print("find \(tableName) error: ", error)
        }
        return results
    }

    static func resolveTable(_ tableType: TableTypes) -> Bool {
        let tableVersion = getTableVersion(tableType)
        let currentTableVersion = getVersion(tableType)

        if (createTable(tableType)) {
            return migration(tableType, fromVersion: currentTableVersion, toVersion: tableVersion)
        }
        return false
    }

    static func migration(_ tableType: TableTypes, fromVersion: Int, toVersion: Int) -> Bool {
        if (toVersion <= fromVersion) {
            return true
        }
        do {
            if (tables.keys.contains(tableType)) {
                let table = tables[tableType]!
                if (table.version == toVersion && table.rules.keys.contains(fromVersion)) {
                    let newTable = fullTableName(tableType)
                    let oldTable = fullTableName(tableType, version: fromVersion)
                    for sql in table.rules[fromVersion]! {
                        _ = try SQLiteDataStore.sharedInstance.db.scalar(String(format: sql, newTable, oldTable))
                        _ = try SQLiteDataStore.sharedInstance.db.scalar(String(format: "drop table '%@'", oldTable))
                    }
                }
            }
            return true
        } catch {
            print("migration \(tableType) \(fromVersion)->\(toVersion) error", error)
        }
        return false
    }

}
