//
//  DataProcessor.swift
//  FamilyBudget
//
//  Created by Dmitry Rybochkin on 17.01.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import Foundation
import SQLite

class SQLiteDataStore {
    static let deviceUID: String = UIDevice.current.identifierForVendor!.uuidString
    static let defaultUserTitle: String = "Me"
    static let defaultUserId: Int64 = 1
    var currentUser: DOUser
    var options: DOOptions

    static let sharedInstance: SQLiteDataStore = {
        let instance = SQLiteDataStore()
        return instance
    }()

    private init () {
        options = DOOptions(userId: SQLiteDataStore.defaultUserId, lastTick: 0, notificationToken: "")
        currentUser = DOUser(userId: SQLiteDataStore.defaultUserId, userTitle: SQLiteDataStore.defaultUserTitle, userPassword: "", userGroupKeyword: "")
    }

    let db: Connection = try! Connection(Connection.storeURL(dbName: "FamilyBudget.sqlite3")) // swiftlint:disable:this force_try
    func initDatabase() -> Bool {
        do {
            var res: Bool = false
            try db.transaction {
                res = self.createTables()
                res = res && self.initData()
                //self.addTestTransactions()
            }
            return res
        } catch {
            print("init database with error ", error)
        }
        return false
    }

    private func initData() -> Bool {
        let allOptions = DOOptionsDataHelper.getAll()

        if (allOptions == nil || (allOptions?.isEmpty)!) {
            let firstOptions = DOOptionsDataHelper.resolve(item: options)
            if (firstOptions != nil) {
                options = firstOptions!
                currentUser.userId = options.userId
                if let resolvedUser = DOUserDataHelper.resolve(item: currentUser) {
                    currentUser = resolvedUser
                    return createDefaultCategories()
                }
            }
        } else {
            let firstOptions = allOptions?.first
            if (firstOptions != nil) {
                options = firstOptions!
                let user = DOUserDataHelper.find(id: options.userId)
                if (user != nil) {
                    currentUser = user!
                    return true
                } else {
                    currentUser.userId = options.userId
                    if let resolvedUser = DOUserDataHelper.resolve(item: currentUser) {
                        currentUser = resolvedUser
                        return true
                    }
                }
            }
        }
        return false
    }

    private func addTestTransactions() {
        _ = DOTransactionDataHelper.resolve(item: DOTransaction(transactionId: 1, userId: currentUser.userId, categoryId: 1, transactionDueDate: Int64(Date().timeIntervalSince1970), transactionCost: 1.01, transactionProfit: 0.0, transactionDescription: "desc 1", transactionUploaded: 0, transactionDeleted: 0))
        _ = DOTransactionDataHelper.resolve(item: DOTransaction(transactionId: 2, userId: currentUser.userId, categoryId: 2, transactionDueDate: Int64(Date().timeIntervalSince1970), transactionCost: 2.02, transactionProfit: 0.0, transactionDescription: "desc 2", transactionUploaded: 0, transactionDeleted: 0))
        _ = DOTransactionDataHelper.resolve(item: DOTransaction(transactionId: 3, userId: currentUser.userId, categoryId: 3, transactionDueDate: Int64(Date().timeIntervalSince1970), transactionCost: 3.03, transactionProfit: 0.0, transactionDescription: "desc 3", transactionUploaded: 0, transactionDeleted: 0))
        _ = DOTransactionDataHelper.resolve(item: DOTransaction(transactionId: 4, userId: currentUser.userId, categoryId: 4, transactionDueDate: Int64(Date().timeIntervalSince1970), transactionCost: 5.05, transactionProfit: 0.0, transactionDescription: "desc 4", transactionUploaded: 0, transactionDeleted: 0))
        _ = DOTransactionDataHelper.resolve(item: DOTransaction(transactionId: 5, userId: currentUser.userId, categoryId: 5, transactionDueDate: Int64(Date().timeIntervalSince1970), transactionCost: 7.07, transactionProfit: 0.0, transactionDescription: "desc 5", transactionUploaded: 0, transactionDeleted: 0))

        _ = DOTransactionDataHelper.resolve(item: DOTransaction(transactionId: 6, userId: currentUser.userId, categoryId: 6, transactionDueDate: Int64(Date().timeIntervalSince1970), transactionCost: 0.0, transactionProfit: 9.09, transactionDescription: "desc 6", transactionUploaded: 0, transactionDeleted: 0))
        _ = DOTransactionDataHelper.resolve(item: DOTransaction(transactionId: 7, userId: currentUser.userId, categoryId: 7, transactionDueDate: Int64(Date().timeIntervalSince1970), transactionCost: 0.0, transactionProfit: 11.11, transactionDescription: "desc 7", transactionUploaded: 0, transactionDeleted: 0))
        _ = DOTransactionDataHelper.resolve(item: DOTransaction(transactionId: 8, userId: currentUser.userId, categoryId: 8, transactionDueDate: Int64(Date().timeIntervalSince1970), transactionCost: 0.0, transactionProfit: 13.13, transactionDescription: "desc 8", transactionUploaded: 0, transactionDeleted: 0))
        _ = DOTransactionDataHelper.resolve(item: DOTransaction(transactionId: 9, userId: currentUser.userId, categoryId: 9, transactionDueDate: Int64(Date().timeIntervalSince1970), transactionCost: 0.0, transactionProfit: 17.17, transactionDescription: "desc 9", transactionUploaded: 0, transactionDeleted: 0))
        _ = DOTransactionDataHelper.resolve(item: DOTransaction(transactionId: 10, userId: currentUser.userId, categoryId: 10, transactionDueDate: Int64(Date().timeIntervalSince1970), transactionCost: 0.0, transactionProfit: 23.23, transactionDescription: "desc 10", transactionUploaded: 0, transactionDeleted: 0))

        _ = DOTransactionDataHelper.resolve(item: DOTransaction(transactionId: 11, userId: currentUser.userId, categoryId: 1, transactionDueDate: Int64(Date().startOfNextMonth().timeIntervalSince1970), transactionCost: 11.01, transactionProfit: 0.0, transactionDescription: "desc 11", transactionUploaded: 0, transactionDeleted: 0))
        _ = DOTransactionDataHelper.resolve(item: DOTransaction(transactionId: 12, userId: currentUser.userId, categoryId: 2, transactionDueDate: Int64(Date().startOfNextMonth().timeIntervalSince1970), transactionCost: 12.02, transactionProfit: 0.0, transactionDescription: "desc 12", transactionUploaded: 0, transactionDeleted: 0))
        _ = DOTransactionDataHelper.resolve(item: DOTransaction(transactionId: 13, userId: currentUser.userId, categoryId: 3, transactionDueDate: Int64(Date().startOfNextMonth().timeIntervalSince1970), transactionCost: 13.03, transactionProfit: 0.0, transactionDescription: "desc 13", transactionUploaded: 0, transactionDeleted: 0))
        _ = DOTransactionDataHelper.resolve(item: DOTransaction(transactionId: 14, userId: currentUser.userId, categoryId: 4, transactionDueDate: Int64(Date().startOfNextMonth().timeIntervalSince1970), transactionCost: 15.05, transactionProfit: 0.0, transactionDescription: "desc 14", transactionUploaded: 0, transactionDeleted: 0))
        _ = DOTransactionDataHelper.resolve(item: DOTransaction(transactionId: 15, userId: currentUser.userId, categoryId: 5, transactionDueDate: Int64(Date().startOfNextMonth().timeIntervalSince1970), transactionCost: 17.07, transactionProfit: 0.0, transactionDescription: "desc 15", transactionUploaded: 0, transactionDeleted: 0))

        _ = DOTransactionDataHelper.resolve(item: DOTransaction(transactionId: 16, userId: currentUser.userId, categoryId: 6, transactionDueDate: Int64(Date().startOfNextMonth().timeIntervalSince1970), transactionCost: 0.0, transactionProfit: 19.09, transactionDescription: "desc 16", transactionUploaded: 0, transactionDeleted: 0))
        _ = DOTransactionDataHelper.resolve(item: DOTransaction(transactionId: 17, userId: currentUser.userId, categoryId: 7, transactionDueDate: Int64(Date().startOfNextMonth().timeIntervalSince1970), transactionCost: 0.0, transactionProfit: 21.11, transactionDescription: "desc 17", transactionUploaded: 0, transactionDeleted: 0))
        _ = DOTransactionDataHelper.resolve(item: DOTransaction(transactionId: 18, userId: currentUser.userId, categoryId: 8, transactionDueDate: Int64(Date().startOfNextMonth().timeIntervalSince1970), transactionCost: 0.0, transactionProfit: 33.13, transactionDescription: "desc 18", transactionUploaded: 0, transactionDeleted: 0))
        _ = DOTransactionDataHelper.resolve(item: DOTransaction(transactionId: 19, userId: currentUser.userId, categoryId: 9, transactionDueDate: Int64(Date().startOfNextMonth().timeIntervalSince1970), transactionCost: 0.0, transactionProfit: 37.17, transactionDescription: "desc 19", transactionUploaded: 0, transactionDeleted: 0))
        _ = DOTransactionDataHelper.resolve(item: DOTransaction(transactionId: 20, userId: currentUser.userId, categoryId: 10, transactionDueDate: Int64(Date().startOfNextMonth().timeIntervalSince1970), transactionCost: 0.0, transactionProfit: 33.23, transactionDescription: "desc 20", transactionUploaded: 0, transactionDeleted: 0))
    }

    func createDefaultCategories(needPost: Bool = false) -> Bool {
        var res = true
        var cat = DOCategoryDataHelper.insert(item: DOCategory(categoryId: 1, userId: currentUser.userId, categoryTitle: "Cat1Cost", categoryType: CategoryTypes.cost, categoryUploaded: 0, categoryDeleted: 0), needPost: needPost)
        res = res && (cat > 0)
        cat = DOCategoryDataHelper.insert(item: DOCategory(categoryId: 2, userId: currentUser.userId, categoryTitle: "Cat2Cost", categoryType: CategoryTypes.cost, categoryUploaded: 0, categoryDeleted: 0), needPost: needPost)
        res = res && (cat > 0)
        cat = DOCategoryDataHelper.insert(item: DOCategory(categoryId: 3, userId: currentUser.userId, categoryTitle: "Cat3Cost", categoryType: CategoryTypes.cost, categoryUploaded: 0, categoryDeleted: 0), needPost: needPost)
        res = res && (cat > 0)
        cat = DOCategoryDataHelper.insert(item: DOCategory(categoryId: 4, userId: currentUser.userId, categoryTitle: "Cat4Cost", categoryType: CategoryTypes.cost, categoryUploaded: 0, categoryDeleted: 0), needPost: needPost)
        res = res && (cat > 0)
        cat = DOCategoryDataHelper.insert(item: DOCategory(categoryId: 5, userId: currentUser.userId, categoryTitle: "Cat5Cost", categoryType: CategoryTypes.cost, categoryUploaded: 0, categoryDeleted: 0), needPost: needPost)
        res = res && (cat > 0)
        cat = DOCategoryDataHelper.insert(item: DOCategory(categoryId: 6, userId: currentUser.userId, categoryTitle: "Cat1Profit", categoryType: CategoryTypes.profit, categoryUploaded: 0, categoryDeleted: 0))
        res = res && (cat > 0)
        cat = DOCategoryDataHelper.insert(item: DOCategory(categoryId: 7, userId: currentUser.userId, categoryTitle: "Cat2Profit", categoryType: CategoryTypes.profit, categoryUploaded: 0, categoryDeleted: 0), needPost: needPost)
        res = res && (cat > 0)
        cat = DOCategoryDataHelper.insert(item: DOCategory(categoryId: 8, userId: currentUser.userId, categoryTitle: "Cat3Profit", categoryType: CategoryTypes.profit, categoryUploaded: 0, categoryDeleted: 0), needPost: needPost)
        res = res && (cat > 0)
        cat = DOCategoryDataHelper.insert(item: DOCategory(categoryId: 9, userId: currentUser.userId, categoryTitle: "Cat4Profit", categoryType: CategoryTypes.profit, categoryUploaded: 0, categoryDeleted: 0), needPost: needPost)
        res = res && (cat > 0)
        cat = DOCategoryDataHelper.insert(item: DOCategory(categoryId: 10, userId: currentUser.userId, categoryTitle: "Cat5Profit", categoryType: CategoryTypes.profit, categoryUploaded: 0, categoryDeleted: 0), needPost: needPost)
        res = res && (cat > 0)
        return res
    }

    private func createTables() -> Bool {
        var res: Bool = true
        for tableType in TableTypes.allValues {
            res = DOMasterDataHelper.resolveTable(tableType) && res
        }
        return res
    }
}
