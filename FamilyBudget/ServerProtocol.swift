//
//  ServerProtocol.swift
//  FamilyBudget
//
//  Created by Dmitry Rybochkin on 21.11.16.
//  Copyright © 2016 Dmitry Rybochkin. All rights reserved.
//

import Foundation

typealias UserResponseCallback = (_ resolvedUser: DOUser?) -> Void
typealias UsersResponseCallback = (_ users: [DOUser]) -> Void

typealias TickResponseCallback = (_ tick: Int64) -> Void

typealias CategoryResponseCallback = (_ resolvedCategory: DOCategory?) -> Void
typealias CategoriesResponseCallback = (_ categories: [DOCategory]) -> Void

typealias TransactionResponseCallback = (_ resolvedTransaction: DOTransaction?) -> Void
typealias TransactionsResponseCallback = (_ transactions: [DOTransaction]) -> Void

typealias WidgetResponseCallback = (_ widget: DOWidget?) -> Void

typealias FeedbackResponseCallback = (_ resolvedFeedback: DOFeedback?) -> Void

protocol ServerProtocol {
    func connectToServer(user: DOUser, callback: UserResponseCallback?)

    func getTick(callback: TickResponseCallback?) /*userid*/

    func getUsers(callback: UsersResponseCallback?)

    func addCategory(category: DOCategory, callback: CategoryResponseCallback?)
    func changeCategory(category: DOCategory, callback: CategoryResponseCallback?)
    func getCategories(callback: CategoriesResponseCallback?)

    func addTransaction(transaction: DOTransaction, callback: TransactionResponseCallback?)
    func getTransactions(callback: TransactionsResponseCallback?)

    func getWidgetData(callback: WidgetResponseCallback?)

    func sendFeedback(feedback: DOFeedback, callback: FeedbackResponseCallback?)
}
