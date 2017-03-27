//
//  DOUserDataHelper.swift
//  FamilyBudget
//
//  Created by Dmitry Rybochkin on 17.01.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import Foundation
import SQLite

class DOUserDataHelper: DataHelperProtocol {
    static let userId = Expression<Int64>("userId")
    static let userTitle = Expression<String>("userTitle")
    static let userPassword = Expression<String>("userPassword")
    static let userGroupKeyword = Expression<String>("userGroupKeyword")

    static let table = Table(DOMasterDataHelper.fullTableName(TableTypes.users))
    static let tableName = DOMasterDataHelper.getTableName(TableTypes.users)

    typealias T = DOUser

    static func createTable() -> Bool {
        do {
            try SQLiteDataStore.sharedInstance.db.run(table.create(ifNotExists: true) { el in
                el.column(userId, primaryKey: true)
                el.column(userTitle)
                el.column(userPassword)
                el.column(userGroupKeyword)
            })
            return true
        } catch {
            print("create \(tableName) error", error)
        }
        return false
    }

    static func dropTable() -> Bool {
        do {
            try SQLiteDataStore.sharedInstance.db.run(table.drop(ifExists: true))
            return true
        } catch {
            print("create \(tableName) error", error)
        }
        return false
    }

    static func insert(item: T, needPost: Bool = true) -> Int64 {
        do {
            var insert: Insert
            if (item.userId > 0) {
                insert = table.insert(userId <- item.userId, userTitle <- item.userTitle, userPassword <- item.userPassword, userGroupKeyword <- item.userGroupKeyword)
            } else {
                insert = table.insert(userTitle <- item.userTitle, userPassword <- item.userPassword, userGroupKeyword <- item.userGroupKeyword)
            }
            let rowid = try SQLiteDataStore.sharedInstance.db.run(insert)
            if (needPost) {
                NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDidChangeData, object: ["User", "insert", item])
            }
            return rowid
        } catch {
            print("insert \(tableName) error: ", error, item)
        }
        return -1
    }

    static func update(item: T, needPost: Bool = true) -> Int64 {
        do {
            let update = table.filter(userId == item.userId).update(userId <- item.userId, userTitle <- item.userTitle, userPassword <- item.userPassword, userGroupKeyword <- item.userGroupKeyword)
            try SQLiteDataStore.sharedInstance.db.run(update)
            if (needPost) {
                NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDidChangeData, object: ["User", "update", item])
            }
            return item.userId
        } catch {
            print("insert \(tableName) error: ", error, item)
        }
        return -1
    }

    static func update(item: T, withId: Int64, needPost: Bool = true) -> Bool {
        do {
            let update = table.filter(userId == withId).update(userId <- item.userId, userTitle <- item.userTitle, userPassword <- item.userPassword, userGroupKeyword <- item.userGroupKeyword)
            try SQLiteDataStore.sharedInstance.db.run(update)
            if (needPost) {
                NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDidChangeData, object: ["User", "update", item])
            }
            return true
        } catch {
            print("insert \(tableName) error: ", error, item)
        }
        return false
    }

    static func resolve(item: T, needPost: Bool = true) -> T? {

        if (find(id: item.userId) != nil) {
            let userId = update(item: item, needPost: needPost)
            if (userId != -1) {
                return find(id: userId)
            }
        } else {
            let userId = insert(item: item, needPost: needPost)
            if (userId != -1) {
                return find(id: userId)
            }
        }
        return nil
    }

    static func delete (item: T, needPost: Bool = true) -> Bool {
        do {
            let query = table.filter(userId == item.userId)
            try SQLiteDataStore.sharedInstance.db.run(query.delete())
            if (needPost) {
                NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDidChangeData, object: ["User", "delete", item])
            }
            return true
        } catch {
            print("delete \(tableName) error: ", error, item)
        }
        return false
    }

    static func find(id: Int64) -> T? {
        var results: T? = nil
        do {
            let query = table.filter(userId == id).limit(1)
            let items = try SQLiteDataStore.sharedInstance.db.prepare(query)
            for item in items {
                results = DOUser(userId: item[userId], userTitle: item[userTitle], userPassword: item[userPassword], userGroupKeyword: item[userGroupKeyword])
            }
        } catch {
            print("find \(tableName) error: ", error, id)
        }
        return results
    }

    static func getAll() -> [T]? {
        var retArray = [T]()
        do {
            let items = try SQLiteDataStore.sharedInstance.db.prepare(table)
            for item in items {
                retArray.append(DOUser(userId: item[userId], userTitle: item[userTitle], userPassword: item[userPassword], userGroupKeyword: item[userGroupKeyword]))
            }
        } catch {
            print("find \(tableName) error: ", error)
        }
        return retArray
    }

    static func clear(needPost: Bool) -> Bool {
        do {
            try SQLiteDataStore.sharedInstance.db.run(table.delete())
            if (needPost) {
                NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDidChangeData, object: ["User", "clear", nil])
            }
            return true
        } catch {
            print("clear \(tableName) error: ", error)
        }
        return false
    }

    static func deleteOther(needPost: Bool) -> Bool {
        do {
            try SQLiteDataStore.sharedInstance.db.run(table.filter(userId != SQLiteDataStore.sharedInstance.currentUser.userId).delete())
            if (needPost) {
                NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDidChangeData, object: ["User", "deleteOther", nil])
            }
            return true
        } catch {
            print("deleteOther \(tableName) error: ", error)
        }
        return false
    }
}
