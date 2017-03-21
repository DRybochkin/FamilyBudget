//
//  DOTransactionDataHelper.swift
//  FamilyBudget
//
//  Created by Dmitry Rybochkin on 17.01.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import Foundation
import SQLite

class DOTransactionDataHelper: DataHelperProtocol {
    static let transactionId = Expression<Int64>("transactionId")
    static let categoryId = Expression<Int64>("categoryId")
    static let userId = Expression<Int64>("userId")
    static let transactionDueDate = Expression<Int64>("transactionDueDate")
    static let transactionMonth = Expression<Int>("transactionMonth")
    static let transactionYear = Expression<Int>("transactionYear")
    static let transactionCost = Expression<Double>("transactionCost")
    static let transactionProfit = Expression<Double>("transactionProfit")
    static let transactionDescription = Expression<String>("transactionDescription")
    static let transactionDeleted = Expression<Int>("transactionDeleted")
    static let transactionUploaded = Expression<Int>("transactionUploaded")

    static let table = Table(DOMasterDataHelper.fullTableName(TableTypes.Transactions))
    static let tableName = DOMasterDataHelper.getTableName(TableTypes.Transactions)

    typealias T = DOTransaction
    
    static func createTable() -> Bool {
        do {
            try SQLiteDataStore.sharedInstance.db.run(table.create(ifNotExists: true) { t in
                t.column(transactionId, primaryKey: .autoincrement)
                t.column(categoryId)
                t.column(userId)
                t.column(transactionDueDate)
                t.column(transactionMonth)
                t.column(transactionYear)
                t.column(transactionCost)
                t.column(transactionProfit)
                t.column(transactionDescription)
                t.column(transactionDeleted)
                t.column(transactionUploaded)
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
            if (item.transactionId > 0) {
                insert = table.insert(transactionId <- item.transactionId, categoryId <- item.categoryId, userId <- item.userId, transactionDueDate <- item.transactionDueDate, transactionCost <- item.transactionCost.doubleValue, transactionProfit <- item.transactionProfit.doubleValue, transactionDescription <- item.transactionDescription, transactionDeleted <- item.transactionDeleted, transactionUploaded <- item.transactionUploaded, transactionMonth <- item.transactionMonth, transactionYear <- item.transactionYear)
            } else {
                insert = table.insert(categoryId <- item.categoryId, userId <- item.userId, transactionDueDate <- item.transactionDueDate, transactionCost <- item.transactionCost.doubleValue, transactionProfit <- item.transactionProfit.doubleValue, transactionDescription <- item.transactionDescription, transactionDeleted <- item.transactionDeleted, transactionUploaded <- item.transactionUploaded, transactionMonth <- item.transactionMonth, transactionYear <- item.transactionYear)
            }
            let rowid = try SQLiteDataStore.sharedInstance.db.run(insert)
            if (needPost) {
                NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDidChangeData, object: ["Transaction", "insert", item])
            }
            return rowid
        } catch {
            print("insert \(tableName) error: ", error, item)
        }
        return -1
    }
    
    static func update(item: T, needPost: Bool = true) -> Int64 {
        do {
            let update = table.filter(transactionId == item.transactionId).update(categoryId <- item.categoryId, userId <- item.userId, transactionDueDate <- item.transactionDueDate, transactionCost <- item.transactionCost.doubleValue, transactionProfit <- item.transactionProfit.doubleValue, transactionDescription <- item.transactionDescription, transactionDeleted <- item.transactionDeleted, transactionUploaded <- item.transactionUploaded, transactionMonth <- item.transactionMonth, transactionYear <- item.transactionYear)
            try SQLiteDataStore.sharedInstance.db.run(update)
            if (needPost) {
               NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDidChangeData, object: ["Transaction", "update", item])
            }
            return item.transactionId
        } catch {
            print("update \(tableName) error: ", error, item)
        }
        return -1
    }

    static func updateId(_ oldId: Int64, item: T, needPost: Bool = true) -> Int64 {
        do {
            let update = table.filter(transactionId == oldId).update(transactionId <- item.transactionId, categoryId <- item.categoryId, userId <- item.userId, transactionDueDate <- item.transactionDueDate, transactionCost <- item.transactionCost.doubleValue, transactionProfit <- item.transactionProfit.doubleValue, transactionDescription <- item.transactionDescription, transactionDeleted <- item.transactionDeleted, transactionUploaded <- item.transactionUploaded, transactionMonth <- item.transactionMonth, transactionYear <- item.transactionYear)
            try SQLiteDataStore.sharedInstance.db.run(update)
            if (needPost) {
                NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDidChangeData, object: ["Transaction", "updateId", ["oldId": oldId, "transaction": item]])
            }
            return item.categoryId
        } catch {
            print("updateId \(tableName) error: ", error, item, oldId)
        }
        return -1
    }

    static func updateCategoryId(_ oldId: Int64, newId: Int64, needPost: Bool = true) -> Bool {
        do {
            let update = table.filter(categoryId == oldId).update(categoryId <- newId)
            try SQLiteDataStore.sharedInstance.db.run(update)
            if (needPost) {
                NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDidChangeData, object: ["Transaction", "updateCategoryId", ["oldId": oldId, "newId": newId]])
            }
            return true
        } catch {
            print("updateCategoryId \(tableName) error: ", error, newId, oldId)
        }
        return false
    }

    static func resolve(item: T, needPost: Bool = true) -> T? {
        if (find(id: item.transactionId) != nil) {
            let transactionId = update(item: item, needPost: needPost)
            if (transactionId != -1) {
                return find(id: transactionId)
            }
        } else {
            let transactionId = insert(item: item, needPost: needPost)
            if (transactionId != -1) {
                return find(id: transactionId)
            }
        }
        return nil
    }

    static func markDelete(id: Int64, needPost: Bool = true) -> Bool {
        do {
            let query = table.filter(transactionId == id).update(transactionDeleted <- 1, transactionUploaded <- 2)
            try SQLiteDataStore.sharedInstance.db.run(query)
            if (needPost) {
                NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDidChangeData, object: ["Transaction", "mark", id])
            }
            return true
        } catch {
            print("delete \(tableName) error: ", error, id)
        }
        return false
    }

    static func markDelete(categoryId: Int64, needPost: Bool = true) -> Bool {
        do {
            let query = table.filter(self.categoryId == categoryId).update(transactionDeleted <- 1, transactionUploaded <- 2)
            try SQLiteDataStore.sharedInstance.db.run(query)
            if (needPost) {
                NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDidChangeData, object: ["TransactionCategory", "mark", categoryId])
            }
            return true
        } catch {
            print("delete \(tableName) error: ", error, categoryId)
        }
        return false
    }

    static func delete (item: T, needPost: Bool = true) -> Bool {
        do {
            let query = table.filter(transactionId == item.transactionId)
            try SQLiteDataStore.sharedInstance.db.run(query.delete())
            if (needPost) {
                NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDidChangeData, object: ["Transaction", "delete", item])
            }
            return true
        } catch {
            print("delete \(tableName) error: ", error, item)
        }
        return false
    }

    static func delete (categoryId: Int64, needPost: Bool = true) -> Bool {
        do {
            let query = table.filter(self.categoryId == categoryId)
            try SQLiteDataStore.sharedInstance.db.run(query.delete())
            if (needPost) {
                NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDidChangeData, object: ["TransactionCategory", "delete", categoryId])
            }
            return true
        } catch {
            print("delete \(tableName) error: ", error, categoryId)
        }
        return false
    }

    static func find(id: Int64) -> T? {
        var results: T? = nil
        do {
            let query = table.filter(transactionId == id).limit(1)
            let items = try SQLiteDataStore.sharedInstance.db.prepare(query)
            for item in items {
                results = DOTransaction(transactionId: item[transactionId], userId: item[userId], categoryId: item[categoryId], transactionDueDate: item[transactionDueDate], transactionCost: NSNumber(value: item[transactionCost]), transactionProfit: NSNumber(value: item[transactionProfit]), transactionDescription: item[transactionDescription], transactionUploaded: item[transactionUploaded], transactionDeleted: item[transactionDeleted])
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
                retArray.append(DOTransaction(transactionId: item[transactionId], userId: item[userId], categoryId: item[categoryId], transactionDueDate: item[transactionDueDate], transactionCost: NSNumber(value: item[transactionCost]), transactionProfit: NSNumber(value: item[transactionProfit]), transactionDescription: item[transactionDescription], transactionUploaded: item[transactionUploaded], transactionDeleted: item[transactionDeleted]))
            }
        } catch {
            print("getAll \(tableName) error: ", error)
        }
        return retArray
    }
    
    static func getAllForUpload() -> [T] {
        var results: [T] = []
        do {
            let query = table.filter((userId == SQLiteDataStore.sharedInstance.currentUser.userId && transactionUploaded == 0) || transactionUploaded == 2)
            let items = try SQLiteDataStore.sharedInstance.db.prepare(query)
            for item in items {
                results.append(DOTransaction(transactionId: item[transactionId], userId: item[userId], categoryId: item[categoryId], transactionDueDate: item[transactionDueDate], transactionCost: NSNumber(value: item[transactionCost]), transactionProfit: NSNumber(value: item[transactionProfit]), transactionDescription: item[transactionDescription], transactionUploaded: item[transactionUploaded], transactionDeleted: item[transactionDeleted]))
            }
        } catch {
            print("getAllForUpload \(tableName) error: ", error)
        }
        return results
    }

    static func clear(needPost: Bool) -> Bool {
        do {
            try SQLiteDataStore.sharedInstance.db.run(table.delete())
            if (needPost) {
                NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDidChangeData, object: ["Transaction", "clear", nil])
            }
            return true
        } catch {
            print("clear \(tableName) error: ", error)
        }
        return false
    }

    static func updateUserId(_ oldUserId: Int64, newUserId: Int64, needPost: Bool = true) -> Bool {
        let update = table.filter(userId == oldUserId).update(userId <- newUserId, transactionUploaded <- 2)
        do {
            try SQLiteDataStore.sharedInstance.db.run(update)
            if (needPost) {
                NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDidChangeData, object: ["Transaction", "updateUserId", ["oldUserId": oldUserId, "newUserId": newUserId]])
            }
            return true
        } catch {
            print("updateUserId \(tableName) error: ", error, oldUserId, newUserId)
        }
        return false
    }

    static func deleteOther(needPost: Bool) -> Bool {
        do {
            try SQLiteDataStore.sharedInstance.db.run(table.filter(userId != SQLiteDataStore.sharedInstance.currentUser.userId).delete())
            if (needPost) {
                NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDidChangeData, object: ["Transaction", "deleteOther", nil])
            }
            return true
        } catch {
            print("deleteOther \(tableName) error: ", error)
        }
        return false
    }

    /*Statistics*/
    static func getStatistic(dataTypes: [StatisticDataTypes], date: Date? = nil, user: Int64? = nil, category: Int64? = nil, type: CategoryTypes? = nil) -> [DOStatisticData] {
        var results: [DOStatisticData] = [DOStatisticData]()

        let categories:Table = DOCategoryDataHelper.table
        let users:Table = DOUserDataHelper.table
        
        let catId = DOCategoryDataHelper.categoryId
        let categoryType = DOCategoryDataHelper.categoryType
        let categoryTitle = DOCategoryDataHelper.categoryTitle
        let categoryDeleted = DOCategoryDataHelper.categoryDeleted
        var catType:String = ""

        if (type != nil) {
            catType = type!.rawValue
        }

        let usrId = DOUserDataHelper.userId
        let userTitle = DOUserDataHelper.userTitle

        let costSum = table[transactionCost].sum
        let profitSum = table[transactionProfit].sum

        var query = table.select(table[userId], users[userTitle], table[categoryId], categories[categoryTitle], categories[categoryType], table[transactionMonth], table[transactionYear], costSum, profitSum).join(categories, on: table[categoryId] == categories[catId]).join(users, on: table[userId] == users[usrId]).filter(transactionDeleted == 0 && categoryDeleted == 0 && DOUserDataHelper.userGroupKeyword == SQLiteDataStore.sharedInstance.currentUser.userGroupKeyword)
        
        if (date != nil) {
            query = query.filter(transactionDueDate>=Int64((date?.startOfMonth().timeIntervalSince1970)!) && transactionDueDate<Int64((date?.startOfNextMonth().timeIntervalSince1970)!))
        }
        if (user != nil) {
            query = query.filter(table[userId] == user!)
        }
        if (category != nil) {
            query = query.filter(table[categoryId] == category!)
        }
        if (type != nil) {
            query = query.filter(categories[categoryType] == catType)
        }
        if (dataTypes == [StatisticDataTypes.Month]) {
            query = query.group(table[transactionMonth], table[transactionYear]).order(table[transactionYear].desc, table[transactionMonth].desc)
        } else if (dataTypes == [StatisticDataTypes.Category]) {
            query = query.group(table[categoryId]).order(costSum.desc, profitSum.desc)
        } else if (dataTypes == [StatisticDataTypes.User]) {
            query = query.group(table[userId]).order(costSum.desc, profitSum.desc)
        } else if (dataTypes.contains(StatisticDataTypes.Category) && dataTypes.contains(StatisticDataTypes.Month) && dataTypes.contains(StatisticDataTypes.User)) {
            query = query.group(table[transactionMonth], table[transactionYear], table[userId], table[categoryId]).order(costSum.desc, profitSum.desc)
        } else if (dataTypes.contains(StatisticDataTypes.Category) && dataTypes.contains(StatisticDataTypes.Month)) {
            query = query.group(table[transactionMonth], table[transactionYear], table[categoryId]).order(costSum.desc, profitSum.desc)
        } else if (dataTypes.contains(StatisticDataTypes.Category) && dataTypes.contains(StatisticDataTypes.User)) {
            query = query.group(table[userId], table[categoryId]).order(costSum.desc, profitSum.desc)
        } else if (dataTypes.contains(StatisticDataTypes.User) && dataTypes.contains(StatisticDataTypes.Month)) {
            query = query.group(table[transactionMonth], table[transactionYear], table[userId]).order(costSum.desc, profitSum.desc)
        } else {
            query = query.group(table[transactionMonth], table[transactionYear], table[userId], table[categoryId]).order(costSum.desc, profitSum.desc)
        }
        do {
            let items = try SQLiteDataStore.sharedInstance.db.prepare(query)
            for item in items {
                if (dataTypes == [StatisticDataTypes.Month]) {
                    results.append(DOStatisticData(dataTypes: dataTypes, dataCost: NSNumber(value: item[costSum]!), dataProfit: NSNumber(value: item[profitSum]!), date: Date.from(month: item[transactionMonth], year: item[transactionYear]), categoryType: type?.rawValue))
                } else if (dataTypes == [StatisticDataTypes.Category]) {
                    results.append(DOStatisticData(dataTypes: dataTypes, dataCost: NSNumber(value: item[costSum]!), dataProfit: NSNumber(value: item[profitSum]!), categoryId: item[categoryId], categoryTitle: item[categoryTitle], categoryType: item[categoryType]))
                } else if (dataTypes == [StatisticDataTypes.User]) {
                    results.append(DOStatisticData(dataTypes: dataTypes, dataCost: NSNumber(value: item[costSum]!), dataProfit: NSNumber(value: item[profitSum]!), userId: item[userId], userTitle: item[userTitle], categoryType: type?.rawValue))
                } else if (dataTypes.contains(StatisticDataTypes.Category) && dataTypes.contains(StatisticDataTypes.Month) && dataTypes.contains(StatisticDataTypes.User)) {
                    results.append(DOStatisticData(dataTypes: dataTypes, dataCost: NSNumber(value: item[costSum]!), dataProfit: NSNumber(value: item[profitSum]!), date: Date.from(month: item[transactionMonth], year: item[transactionYear]), userId: item[userId], userTitle: item[userTitle], categoryId: item[categoryId], categoryTitle: item[categoryTitle], categoryType: item[categoryType]))
                } else if (dataTypes.contains(StatisticDataTypes.Category) && dataTypes.contains(StatisticDataTypes.Month)) {
                    results.append(DOStatisticData(dataTypes: dataTypes, dataCost: NSNumber(value: item[costSum]!), dataProfit: NSNumber(value: item[profitSum]!), date: Date.from(month: item[transactionMonth], year: item[transactionYear]), categoryId: item[categoryId], categoryTitle: item[categoryTitle], categoryType: item[categoryType]))
                } else if (dataTypes.contains(StatisticDataTypes.Category) && dataTypes.contains(StatisticDataTypes.User)) {
                    results.append(DOStatisticData(dataTypes: dataTypes, dataCost: NSNumber(value: item[costSum]!), dataProfit: NSNumber(value: item[profitSum]!), userId: item[userId], userTitle: item[userTitle], categoryId: item[categoryId], categoryTitle: item[categoryTitle], categoryType: item[categoryType]))
                } else if (dataTypes.contains(StatisticDataTypes.User) && dataTypes.contains(StatisticDataTypes.Month)) {
                    results.append(DOStatisticData(dataTypes: dataTypes, dataCost: NSNumber(value: item[costSum]!), dataProfit: NSNumber(value: item[profitSum]!), date: Date.from(month: item[transactionMonth], year: item[transactionYear]), userId: item[userId], userTitle: item[userTitle], categoryType: type?.rawValue))
                } else {
                    results.append(DOStatisticData(dataTypes: dataTypes, dataCost: NSNumber(value: item[costSum]!), dataProfit: NSNumber(value: item[profitSum]!), date: Date.from(month: item[transactionMonth], year: item[transactionYear]), userId: item[userId], userTitle: item[userTitle], categoryId: item[categoryId], categoryTitle: item[categoryTitle], categoryType: item[categoryType]))
                }
            }
        } catch {
            print("getStatistic \(tableName) error: ", error, dataTypes, date as Any, user as Any, category as Any, type as Any)
        }
        return results
    }
    
    /*Statistic transactions */
    static func getTransactions(date: Date? = nil, user: Int64? = nil, category: Int64? = nil, type: CategoryTypes? = nil) -> [DOStatisticData] {
        var results: [DOStatisticData] = [DOStatisticData]()
        
        let categories:Table = DOCategoryDataHelper.table
        let users:Table = DOUserDataHelper.table
        
        let catId = DOCategoryDataHelper.categoryId
        let categoryType = DOCategoryDataHelper.categoryType
        let categoryTitle = DOCategoryDataHelper.categoryTitle
        var catType:String = ""
        
        if (type != nil) {
            catType = type!.rawValue
        }
        
        let usrId = DOUserDataHelper.userId
        let userTitle = DOUserDataHelper.userTitle
        
        //let costSum = table[transactionCost].sum
        //let profitSum = table[transactionProfit].sum
        
        var query = table.select(table[transactionId], table[transactionDueDate], table[transactionDescription], table[userId], users[userTitle], table[categoryId], categories[categoryTitle], categories[categoryType], table[transactionMonth], table[transactionYear], table[transactionCost], table[transactionProfit]).join(categories, on: table[categoryId] == categories[catId]).join(users, on: table[userId] == users[usrId]).filter(transactionDeleted == 0 && DOCategoryDataHelper.categoryDeleted == 0 && DOUserDataHelper.userGroupKeyword == SQLiteDataStore.sharedInstance.currentUser.userGroupKeyword)
        
        if (date != nil) {
            query = query.filter(transactionDueDate>=Int64((date?.startOfMonth().timeIntervalSince1970)!) && transactionDueDate<Int64((date?.startOfNextMonth().timeIntervalSince1970)!))
        }
        if (user != nil) {
            query = query.filter(table[userId] == user!)
        }
        if (category != nil) {
            query = query.filter(table[categoryId] == category!)
        }
        if (type != nil) {
            query = query.filter(categories[categoryType] == catType)
        }
        query = query.order(table[transactionDueDate].desc)
        do {
            let items = try SQLiteDataStore.sharedInstance.db.prepare(query)
            for item in items {
                results.append(DOStatisticData(dataTypes: [StatisticDataTypes.Transaction], dataCost: NSNumber(value: item[transactionCost]), dataProfit: NSNumber(value: item[transactionProfit]), date: Date.from(month: item[transactionMonth], year: item[transactionYear]), userId: item[userId], userTitle: item[userTitle], categoryId: item[categoryId], categoryTitle: item[categoryTitle], categoryType: item[categoryType], transactionId: item[transactionId], transactionDueDate: item[transactionDueDate], transactionDescription: item[transactionDescription]))
            }
        } catch {
            print("getTransactions \(tableName) error: ", error, date as Any, user as Any, category as Any, type as Any)
        }
        
        return results
    }
}
 
