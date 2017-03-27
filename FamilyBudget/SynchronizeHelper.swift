//
//  SynchronizeHelper.swift
//  FamilyBudget
//
//  Created by Dmitry Rybochkin on 13.03.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import Foundation

typealias UploadCallback = () -> Void

class SynchronizeHelper {
    static func synchronizeWithServer(needPost: Bool = true) {
        if (SQLiteDataStore.sharedInstance.currentUser.userGroupKeyword.characters.isEmpty) {
            return
        }

        NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDataWillLoad, object: ["SynchronizeHelper", "synchronizeWithServer", 0.0])

        SQLiteDataStore.sharedInstance.currentUser.isConnected = false
        _ = ServerImplementation.sharedInstance.connectToServer(user: SQLiteDataStore.sharedInstance.currentUser, callback: { (user: DOUser?) -> Void in
            if (user != nil) {
                if (SQLiteDataStore.sharedInstance.currentUser.userId != user?.userId) {
                    if (DOUserDataHelper.update(item: user!, withId: SQLiteDataStore.sharedInstance.currentUser.userId, needPost: false)) {
                        if (DOCategoryDataHelper.updateUserId(SQLiteDataStore.sharedInstance.currentUser.userId, newUserId: (user?.userId)!, needPost: false)) {
                            if (DOTransactionDataHelper.updateUserId(SQLiteDataStore.sharedInstance.currentUser.userId, newUserId: (user?.userId)!, needPost: false)) {
                                if (DOOptionsDataHelper.updateUserId(SQLiteDataStore.sharedInstance.currentUser.userId, newUserId: (user?.userId)!, needPost: false)) {
                                    SQLiteDataStore.sharedInstance.options.userId = (user?.userId)!
                                    SQLiteDataStore.sharedInstance.options.lastTick = 0
                                    SQLiteDataStore.sharedInstance.currentUser = user!
                                    SQLiteDataStore.sharedInstance.currentUser.isConnected = true
                                }
                            }
                        }
                    }
                } else {
                    _ = DOUserDataHelper.resolve(item: user!, needPost: false)
                    SQLiteDataStore.sharedInstance.currentUser = user!
                    SQLiteDataStore.sharedInstance.currentUser.isConnected = true
                }

                let userDefaul = UserDefaults(suiteName: "group.FamilyBudget")
                userDefaul?.set(SQLiteDataStore.sharedInstance.currentUser.userAccessToken, forKey: "accessToken")
                userDefaul?.set(SQLiteDataStore.sharedInstance.currentUser.userId, forKey: "userId")
                userDefaul?.set(SQLiteDataStore.sharedInstance.options.lastTick, forKey: "lastTick")

                NotificationCenter.default.post(name: Notification.Name.FamilyBudgetCurrentUserChanged, object: ["SynchronizeHelper", "synchronizeWithServer", user!])

                upload(needPost: needPost, callback: {
                    download(needPost: needPost)
                })
            }
        })
    }

    static func upload(needPost: Bool = true, callback: UploadCallback?) {
        NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDataWillLoad, object: ["SynchronizeHelper", "upload", 0.0])

        if (SQLiteDataStore.sharedInstance.currentUser.isConnected) {
            let categories = DOCategoryDataHelper.getAllForUpload()
            let categoryGroup = DispatchGroup()
            print("start load categories ")
            var index: Float = 1.0
            for category in categories {
                categoryGroup.enter()
                ServerImplementation.sharedInstance.addCategory(category: category, callback: { (uploadedCategory: DOCategory?) -> Void in
                    if (uploadedCategory != nil) {
                        uploadedCategory?.categoryUploaded = 1
                        if (category.categoryId == uploadedCategory?.categoryId) {
                            _ = DOCategoryDataHelper.update(item: uploadedCategory!, needPost: false)
                        } else {
                            if (DOCategoryDataHelper.updateId(category.categoryId, item: uploadedCategory!, needPost: false)) {
                                _ = DOTransactionDataHelper.updateCategoryId(category.categoryId, newId: (uploadedCategory?.categoryId)!, needPost: false)
                            }
                        }
                    }
                    categoryGroup.leave()
                    NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDataWillLoad, object: ["SynchronizeHelper", "upload", (index * 0.2) / Float(categories.count)])
                    index += 1.0
                })
            }

            categoryGroup.notify(queue: .main, execute: {
                print("categories loaded")

                print("start load transactions ")

                let transactionGroup = DispatchGroup()
                let transactions = DOTransactionDataHelper.getAllForUpload()
                var index: Float = 1.0
                for transaction in transactions {
                    transactionGroup.enter()
                    ServerImplementation.sharedInstance.addTransaction(transaction: transaction, callback: { (uploadedTransaction: DOTransaction?) -> Void in
                        if (uploadedTransaction != nil) {
                            uploadedTransaction?.transactionUploaded = 1
                            if (transaction.transactionId == uploadedTransaction?.transactionId) {
                                _ = DOTransactionDataHelper.update(item: uploadedTransaction!, needPost: false)
                            } else {
                                _ = DOTransactionDataHelper.updateId(transaction.transactionId, item: uploadedTransaction!, needPost: false)
                            }
                        }
                        transactionGroup.leave()
                        NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDataWillLoad, object: ["SynchronizeHelper", "upload", 0.2 + (index * 0.2) / Float(transactions.count)])
                        index += 1.0
                    })
                }

                transactionGroup.notify(queue: .main, execute: {
                    print("transactions loaded")

                    if (needPost && (!transactions.isEmpty || !categories.isEmpty)) {
                        NotificationCenter.default.post(name: Notification.Name.FamilyBudgetNeedReloadData, object: ["SynchronizeHelper", "upload"])
                    }
                    if (callback != nil) {
                        callback!()
                    }
                })
            })
        } else {
            if (needPost) {
                NotificationCenter.default.post(name: Notification.Name.FamilyBudgetNeedReloadData, object: ["SynchronizeHelper", "upload"])
            }
            if (callback != nil) {
                callback!()
            }
        }
    }

    static func download(needPost: Bool = true) {
        if (SQLiteDataStore.sharedInstance.currentUser.isConnected) {
            ServerImplementation.sharedInstance.getTick(callback: { (tick: Int64) -> Void in
                if (tick > SQLiteDataStore.sharedInstance.options.lastTick) {
                    var index: Float = 1.0
                    ServerImplementation.sharedInstance.getUsers(callback: { (users: [DOUser]) -> Void in
                        for user in users {
                            if (user.userId != SQLiteDataStore.sharedInstance.currentUser.userId) {
                                _ = DOUserDataHelper.resolve(item: user, needPost: false)
                            }
                            NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDataWillLoad, object: ["SynchronizeHelper", "download", 0.4 + (index * 0.2) / Float(users.count)])
                            index += 1.0
                        }
                        ServerImplementation.sharedInstance.getCategories(callback: { (categories: [DOCategory] ) -> Void in
                            var index: Float = 1.0
                            for category in categories {
                                _ = DOCategoryDataHelper.resolve(item: category, needPost: false)
                                NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDataWillLoad, object: ["SynchronizeHelper", "download", 0.6 + (index * 0.2) / Float(categories.count)])
                                index += 1.0
                            }
                            ServerImplementation.sharedInstance.getTransactions(callback: { (transactions: [DOTransaction] ) -> Void in
                                var index: Float = 1.0
                                for transaction in transactions {
                                    _ = DOTransactionDataHelper.resolve(item: transaction, needPost: false)
                                    NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDataWillLoad, object: ["SynchronizeHelper", "download", 0.8 + (index * 0.2) / Float(transactions.count)])
                                    index += 1.0
                                }
                                SQLiteDataStore.sharedInstance.options.lastTick = tick
                                _ = DOOptionsDataHelper.update(item: SQLiteDataStore.sharedInstance.options, needPost: false)

                                if (needPost && (!users.isEmpty || !categories.isEmpty || !transactions.isEmpty)) {
                                    NotificationCenter.default.post(name: Notification.Name.FamilyBudgetNeedReloadData, object: ["SynchronizeHelper", "download"])
                                }
                                NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDataDidLoad, object: ["SynchronizeHelper", "download"])
                            })
                        })
                    })

                }
            })
        } else {
            if (needPost) {
                NotificationCenter.default.post(name: Notification.Name.FamilyBudgetNeedReloadData, object: ["SynchronizeHelper", "download"])
                NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDataDidLoad, object: ["SynchronizeHelper", "download"])
            }
        }
    }
}
