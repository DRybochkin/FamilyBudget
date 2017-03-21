//
//  DOOptionsDataHelper.swift
//  FamilyBudget
//
//  Created by Dmitry Rybochkin on 17.01.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import Foundation
import SQLite
import UserNotifications

class DOOptionsDataHelper: DataHelperProtocol {
    static let userId = Expression<Int64>("userId")
    static let lastTick = Expression<Int64>("lastTick")
    static let notificationToken = Expression<String>("notificationToken")
    
    static let table = Table(DOMasterDataHelper.fullTableName(TableTypes.AppOptions))
    static let tableName = DOMasterDataHelper.getTableName(TableTypes.AppOptions)
    
    typealias T = DOOptions
    
    static func createTable() -> Bool {
        do {
            try SQLiteDataStore.sharedInstance.db.run(table.create(ifNotExists: true) { t in
                t.column(userId, primaryKey: true)
                t.column(lastTick)
                t.column(notificationToken)
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
    
    static func insert(item: T, needPost: Bool = false) -> Int64 {
        do {
            let insert = table.insert(userId <- item.userId, lastTick <- item.lastTick, notificationToken <- item.notificationToken)
            let rowid = try SQLiteDataStore.sharedInstance.db.run(insert)
            if (needPost) {
                NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDidChangeOptions, object: ["insert", item])
            }
            return rowid
        } catch {
            print("insert \(tableName) error: ", error, item)
        }
        return -1
    }

    static func update(item: T, needPost: Bool = false) -> Int64 {
        do {
            let update = table.filter(userId == item.userId).update(lastTick <- item.lastTick, notificationToken <- item.notificationToken)
            try SQLiteDataStore.sharedInstance.db.run(update)
            if (needPost) {
                NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDidChangeOptions, object: ["update", item])
            }
            return item.userId
        } catch {
            print("update \(tableName) error: ", error, item)
        }
        return -1
    }

    static func updateUserId(_ oldUserId: Int64, newUserId: Int64, needPost: Bool = false) -> Bool {
        do {
            let update = table.filter(userId == oldUserId).update(userId <- newUserId, lastTick <- 0)
            try SQLiteDataStore.sharedInstance.db.run(update)
            if (needPost) {
                NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDidChangeOptions, object: ["updateUserId", ["oldUserId": oldUserId, "newUserId": newUserId]])
            }
            return true
        } catch {
            print("updateUserId \(tableName) error: ", error, oldUserId, newUserId)
        }
        return false
    }

    static func resolve(item: T, needPost: Bool = false) -> T? {
        
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
    
    static func delete (item: T, needPost: Bool = false) -> Bool {
        do {
            let query = table.filter(userId == item.userId)
            try SQLiteDataStore.sharedInstance.db.run(query.delete())
            if (needPost) {
                NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDidChangeOptions, object: ["AppOptions", "update", item])
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
                results = DOOptions(userId: item[userId], lastTick: item[lastTick], notificationToken: item[notificationToken])
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
                retArray.append(DOOptions(userId: item[userId], lastTick: item[lastTick], notificationToken: item[notificationToken]))
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
                NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDidChangeOptions, object: ["AppOptions", "clear", nil])
            }
           return true
        } catch {
            print("clear \(tableName) error: ", error)
        }
        return false
    }
}
