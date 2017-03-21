//
//  DOCategoryDataHelper.swift
//  FamilyBudget
//
//  Created by Dmitry Rybochkin on 17.01.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import Foundation
import SQLite

class DOCategoryDataHelper: DataHelperProtocol {
    static let categoryId = Expression<Int64>("categoryId")
    static let userId = Expression<Int64>("userId")
    static let categoryTitle = Expression<String>("categoryTitle")
    static let categoryType = Expression<String>("categoryType")
    static let categoryDeleted = Expression<Int>("categoryDeleted")
    static let categoryUploaded = Expression<Int>("categoryUploaded")
    
    static let table = Table(DOMasterDataHelper.fullTableName(TableTypes.Categories))
    static let tableName = DOMasterDataHelper.getTableName(TableTypes.Categories)
    
    typealias T = DOCategory
    
    static func createTable() -> Bool {
        do {
            try SQLiteDataStore.sharedInstance.db.run(table.create(ifNotExists: true) { t in
                t.column(categoryId, primaryKey: .autoincrement)
                t.column(userId)
                t.column(categoryTitle)
                t.column(categoryType)
                t.column(categoryDeleted)
                t.column(categoryUploaded)
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
            if (item.categoryId > 0) {
                insert = table.insert(categoryId <- item.categoryId, userId <- item.userId, categoryTitle <- item.categoryTitle, categoryType <- item.categoryType.rawValue, categoryDeleted <- item.categoryDeleted, categoryUploaded <- item.categoryUploaded)
            } else {
                insert = table.insert(categoryTitle <- item.categoryTitle, userId <- item.userId, categoryType <- item.categoryType.rawValue, categoryDeleted <- item.categoryDeleted, categoryUploaded <- item.categoryUploaded)
            }
            let rowid = try SQLiteDataStore.sharedInstance.db.run(insert)
            if (needPost) {
                NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDidChangeData, object: ["Category", "insert", item])
            }
            return rowid
        } catch {
            print("insert \(tableName) error: ", error, item)
        }
        return -1
    }
    
    static func update(item: T, needPost: Bool = true) -> Int64 {
        do {
            let update = table.filter(categoryId == item.categoryId).update(userId <- item.userId, categoryTitle <- item.categoryTitle, categoryType <- item.categoryType.rawValue, categoryDeleted <- item.categoryDeleted, categoryUploaded <- item.categoryUploaded)
            try SQLiteDataStore.sharedInstance.db.run(update)
            if (needPost) {
                NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDidChangeData, object: ["Category", "update", item])
            }
            return item.categoryId
        } catch {
            print("update \(tableName) error: ", error, item)
        }
        return -1
    }

    static func updateId(_ oldId: Int64, item: T, needPost: Bool = true) -> Bool {
        do {
            let update = table.filter(categoryId == oldId).update(categoryId <- item.categoryId, userId <- item.userId, categoryTitle <- item.categoryTitle, categoryType <- item.categoryType.rawValue, categoryDeleted <- item.categoryDeleted, categoryUploaded <- item.categoryUploaded)
            try SQLiteDataStore.sharedInstance.db.run(update)
            if (needPost) {
                NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDidChangeData, object: ["Category", "updateId", ["oldId": oldId, "category": item]])
            }
            return true
        } catch {
            print("updateId \(tableName) error: ", error, item, oldId)
        }
        return false
    }
    
    static func resolve(item: T, needPost: Bool = true) -> T? {
        
        if (find(id: item.categoryId) != nil) {
            let categoryId = update(item: item, needPost: needPost)
            if (categoryId != -1) {
                return find(id: categoryId)
            }
        } else {
            let categoryId = insert(item: item, needPost: needPost)
            if (categoryId != -1) {
                return find(id: categoryId)
            }
        }
        return nil
    }

    static func markDelete(id: Int64, needPost: Bool = true) -> Bool {
        do {
            if (DOTransactionDataHelper.markDelete(categoryId: id, needPost: needPost)) {
                let query = table.filter(categoryId == id).update(categoryDeleted <- 1, categoryUploaded <- 2)
                try SQLiteDataStore.sharedInstance.db.run(query)
                if (needPost) {
                    NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDidChangeData, object: ["Category", "mark", id])
                }
                return true
            }
            return false
        } catch {
            print("delete \(tableName) error: ", error, id)
        }
        return false
    }

    static func delete(item: T, needPost: Bool = true) -> Bool {
        do {
            if (DOTransactionDataHelper.delete(categoryId: item.categoryId, needPost: needPost)) {
                let query = table.filter(categoryId == item.categoryId)
                try SQLiteDataStore.sharedInstance.db.run(query.delete())
                if (needPost) {
                    NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDidChangeData, object: ["Category", "delete", item])
                }
                return true
            }
            return false
        } catch {
            print("delete \(tableName) error: ", error, item)
        }
        return false
    }
    
    static func find(id: Int64) -> T? {
        var results: T? = nil
        do {
            let query = table.filter(categoryId == id).limit(1)
            let items = try SQLiteDataStore.sharedInstance.db.prepare(query)
            for item in items {
                results = DOCategory(categoryId: item[categoryId], userId: item[userId], categoryTitle: item[categoryTitle], categoryType: CategoryTypes(rawValue: item[categoryType])!, categoryUploaded: item[categoryUploaded], categoryDeleted: item[categoryDeleted])
            }
        } catch {
            print("find \(tableName) error: ", error, id)
        }
        return results
    }
    
    static func getAll(type: CategoryTypes = CategoryTypes.All) -> [T] {
        var results: [T] = []
        do {
            var query = table
            if (type != CategoryTypes.All) {
                query = query.filter(categoryType == type.rawValue && categoryDeleted == 0)
            }
            let items = try SQLiteDataStore.sharedInstance.db.prepare(query)
            for item in items {
                results.append(DOCategory(categoryId: item[categoryId], userId: item[userId], categoryTitle: item[categoryTitle], categoryType: CategoryTypes(rawValue: item[categoryType])!, categoryUploaded: item[categoryUploaded], categoryDeleted: item[categoryDeleted]))
            }
        } catch {
            print("find \(tableName) error: ", error, type)
        }
        return results
    }

    static func getAllForUpload() -> [T] {
        var results: [T] = []
        do {
            let query = table.filter((userId == SQLiteDataStore.sharedInstance.currentUser.userId && categoryUploaded == 0) || categoryUploaded == 2)
            let items = try SQLiteDataStore.sharedInstance.db.prepare(query)
            for item in items {
                results.append(DOCategory(categoryId: item[categoryId], userId: item[userId], categoryTitle: item[categoryTitle], categoryType: CategoryTypes(rawValue: item[categoryType])!, categoryUploaded: item[categoryUploaded], categoryDeleted: item[categoryDeleted]))
            }
        } catch {
            print("getAllForUpload \(tableName) error: ", error)
        }
        return results
    }
    
    internal static func getAll() -> [DOCategory]? {
        var retArray = [T]()
        do {
            let items = try SQLiteDataStore.sharedInstance.db.prepare(table)
            for item in items {
                retArray.append(DOCategory(categoryId: item[categoryId], userId: item[userId], categoryTitle: item[categoryTitle], categoryType: CategoryTypes(rawValue: item[categoryType])!, categoryUploaded: item[categoryUploaded], categoryDeleted: item[categoryDeleted]))
            }
        } catch {
            print("find \(tableName) error: ", error)
        }
        return retArray
    }

    static func updateAll(items: [T], needPost: Bool = true) {
        for item in items {
            _ = update(item: item, needPost: false)
        }
        
        if (needPost) {
            NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDidChangeData, object: ["Category", "updateAll", items])
        }
    }
    
    static func updateUserId(_ oldUserId: Int64, newUserId: Int64, needPost: Bool = true) -> Bool {
        let update = table.filter(userId == oldUserId).update(userId <- newUserId, categoryUploaded <- 2)
        do {
            try SQLiteDataStore.sharedInstance.db.run(update)
            if (needPost) {
                NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDidChangeData, object: ["Category", "updateUserId", ["oldUserId": oldUserId, "newUserId": newUserId]])
            }
            return true
        } catch {
            print("updateUserId \(tableName) error: ", error, oldUserId, newUserId)
        }
        return false
    }
    
    static func insertAll(items: [T], needPost: Bool = true) {
        for item in items {
            _ = insert(item: item, needPost: false)
        }
        
        if (needPost) {
            NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDidChangeData, object: ["Category", "insertAll", items])
        }
    }
    
    static func resolveAll(items: [T], needPost: Bool = true) {
        for item in items {
            _ = resolve(item: item, needPost: false)
        }
        
        if (needPost) {
            NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDidChangeData, object: ["Category", "resolveAll", items])
        }
    }

    static func deleteAll(items: [T], needPost: Bool = true) {
        for item in items {
            _ = delete(item: item, needPost: false)
        }
        
        if (needPost) {
            NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDidChangeData, object: ["Category", "deleteAll", items])
        }
    }

    static func markDeleteAll(items: [T], needPost: Bool = true) {
        for item in items {
            _ = markDelete(id: item.categoryId, needPost: false)
        }
        
        if (needPost) {
            NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDidChangeData, object: ["Category", "markDeleteAll", items])
        }
    }

    static func clear(needPost: Bool) -> Bool {
        do {
            try SQLiteDataStore.sharedInstance.db.run(table.delete())
            if (needPost) {
                NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDidChangeData, object: ["Category", "clear", nil])
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
                NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDidChangeData, object: ["Category", "deleteOther", nil])
            }
            return true
        } catch {
            print("deleteOther \(tableName) error: ", error)
        }
        return false
    }
}
