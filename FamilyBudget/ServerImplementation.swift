//
//  ServerImplementation.swift
//  FamilyBudget
//
//  Created by Dmitry Rybochkin on 21.11.16.
//  Copyright © 2016 Dmitry Rybochkin. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON

let serverAPIUrl = "http://turing.ru"

class ServerImplementation: NSObject, ServerProtocol {
    var accessTokenWebApi = ""

    static let sharedInstance: ServerImplementation = {
        let instance = ServerImplementation()
        return instance
    }()

    func checkResponse(json: JSON?, checkCount: Bool = true) -> Bool {
        return (json != nil && json!["response"].string == "OK" && (!checkCount || (json!["data"].array != nil && (json!["data"].array?.count)! > 0)) && (json!["data"]["response"] == nil || json!["data"]["response"].string != "ERROR"))
    }

    func connectToServer(user: DOUser, callback: UserResponseCallback?) {
        let params = [ "deviceuid": SQLiteDataStore.deviceUID, "password": user.userPassword, "groupkeyword": user.userGroupKeyword, "title": user.userTitle, "accesstoken": accessTokenWebApi, "usertick": SQLiteDataStore.sharedInstance.options.lastTick, "pushtoken": SQLiteDataStore.sharedInstance.options.notificationToken ] as [String : Any]

        Alamofire.request(serverAPIUrl + "/fb/?method=resolveuser", method: .post, parameters: params).responseJSON { response in
            var resolvedUser: DOUser? = nil
            print(" \(response.request) with \(params) -> \(response.result.value)")

            switch response.result {
            case .success:
                if(response.result.value != nil) {
                    let json = JSON(response.result.value!)
                    if (self.checkResponse(json: json)) {
                        //Now you got your value
                        resolvedUser = DOUser(json: json["data"][0])
                        print(resolvedUser!)
                    } else {
                        print("error \(response.request) with \(params) -> \(json)")
                    }
                }
                break
            case .failure(let error):
                print(error)
                break
            }
            if (callback != nil) {
                callback!(resolvedUser)
            }
        }
    }

    func getTick(callback: TickResponseCallback?) {
        let params = [ "userid": SQLiteDataStore.sharedInstance.currentUser.userId, "accesstoken": SQLiteDataStore.sharedInstance.currentUser.userAccessToken, "usertick": SQLiteDataStore.sharedInstance.options.lastTick ] as [String : Any]

        Alamofire.request(serverAPIUrl + "/fb/?method=getusertick", method: .post, parameters: params).responseJSON { response in
            var tick: Int64 = 0
            print(" \(response.request) with \(params) -> \(response.result.value)")

            switch response.result {
            case .success:
                if(response.result.value != nil) {
                    let json = JSON(response.result.value!)
                    if (self.checkResponse(json: json)) {
                        tick = Int64(json["data"][0]["UserTick"].string!)!
                    }
                }
                break
            case .failure(let error):
                print(error)
                break
            }
            if (callback != nil) {
                callback!(tick)
            }
        }
    }

    func getUsers(callback: UsersResponseCallback?) {
        let params = [ "userid": SQLiteDataStore.sharedInstance.currentUser.userId, "accesstoken": SQLiteDataStore.sharedInstance.currentUser.userAccessToken, "usertick": SQLiteDataStore.sharedInstance.options.lastTick ] as [String : Any]

        Alamofire.request(serverAPIUrl + "/fb/?method=getusers", method: .post, parameters: params).responseJSON { response in
            var users: [DOUser] = []
            print(" \(response.request) with \(params) -> \(response.result.value)")

            switch response.result {
            case .success:
                if(response.result.value != nil) {
                    let json = JSON(response.result.value!)
                    if (self.checkResponse(json: json)) {
                        for item in json["data"].arrayValue {
                            users.append(DOUser(json: item))
                        }
                    }
                }
                break
            case .failure(let error):
                print(error)
                break
            }
            if (callback != nil) {
                callback!(users)
            }
        }
    }

    func addCategory(category: DOCategory, callback: CategoryResponseCallback?) {
        let params = [ "userid": SQLiteDataStore.sharedInstance.currentUser.userId, "accesstoken": SQLiteDataStore.sharedInstance.currentUser.userAccessToken, "usertick": SQLiteDataStore.sharedInstance.options.lastTick, "title": category.categoryTitle, "typecategory": category.categoryType.rawValue, "categoryid": category.categoryId, "deleted": category.categoryDeleted] as [String : Any]

        print("request addcategory sended ")

        Alamofire.request(serverAPIUrl + "/fb/?method=addcategory", method: .post, parameters: params).responseJSON { response in
            var resolvedCategory: DOCategory? = nil
            print(" \(response.request) with \(params) -> \(response.result.value)")

            switch response.result {
            case .success:
                if(response.result.value != nil) {
                    let json = JSON(response.result.value!)
                    if (self.checkResponse(json: json)) {
                        //Now you got your value
                        resolvedCategory = DOCategory(json: json["data"][0])
                        print(resolvedCategory!)
                    } else {
                        print("error \(response.request) with \(params) -> \(json)")
                    }
                }
                break
            case .failure(let error):
                print(error)
                break
            }
            if (callback != nil) {
                callback!(resolvedCategory)
            }
        }
    }

    func changeCategory(category: DOCategory, callback: CategoryResponseCallback?) /*userid, title, categoryid, active="Y"*/{
        let params = [ "userid": SQLiteDataStore.sharedInstance.currentUser.userId, "accesstoken": SQLiteDataStore.sharedInstance.currentUser.userAccessToken, "usertick": SQLiteDataStore.sharedInstance.options.lastTick, "categoryid": category.categoryId, "active": category.categoryDeleted == 0 ? "Y" : "N"] as [String : Any]

        Alamofire.request(serverAPIUrl + "/fb/?method=changecategory", method: .post, parameters: params).responseJSON { response in
            var resolvedCategory: DOCategory? = nil
            print(" \(response.request) with \(params) -> \(response.result.value)")

            switch response.result {
            case .success:
                if(response.result.value != nil) {
                    let json = JSON(response.result.value!)
                    if (self.checkResponse(json: json)) {
                        //Now you got your value
                        resolvedCategory = DOCategory(json: json["data"][0])
                        print(resolvedCategory!)
                    } else {
                        print("error \(response.request) with \(params) -> \(json)")
                    }
                }
                break
            case .failure(let error):
                print(error)
                break
            }
            if (callback != nil) {
                callback!(resolvedCategory)
            }
        }
    }

    func getCategories(callback: CategoriesResponseCallback?) /*userid*/ {
        let params = [ "userid": SQLiteDataStore.sharedInstance.currentUser.userId, "accesstoken": SQLiteDataStore.sharedInstance.currentUser.userAccessToken, "usertick": SQLiteDataStore.sharedInstance.options.lastTick ] as [String : Any]

        Alamofire.request(serverAPIUrl + "/fb/?method=getcategories", method: .post, parameters: params).responseJSON { response in
            var categories: [DOCategory] = []
            print(" \(response.request) with \(params) -> \(response.result.value)")

            switch response.result {
            case .success:
                if(response.result.value != nil) {
                    let json = JSON(response.result.value!)
                    if (self.checkResponse(json: json)) {
                        for item in json["data"].arrayValue {
                            categories.append(DOCategory(json: item))
                        }
                    }
                }
                break
            case .failure(let error):
                print(error)
                break
            }
            if (callback != nil) {
                callback!(categories)
            }
        }
    }

    func addTransaction(transaction: DOTransaction, callback: TransactionResponseCallback?) /*userid, amount, categoryid, duedate, transactionid, deleted,transactiondescription */ {
        let params = [ "userid": SQLiteDataStore.sharedInstance.currentUser.userId, "accesstoken": SQLiteDataStore.sharedInstance.currentUser.userAccessToken, "usertick": SQLiteDataStore.sharedInstance.options.lastTick, "amount": Double(transaction.transactionCost) + Double(transaction.transactionProfit), "transactionid": transaction.transactionId, "transactiondescription": transaction.transactionDescription, "duedate": transaction.transactionDueDate, "categoryid": transaction.categoryId, "deleted": transaction.transactionDeleted] as [String : Any]

        Alamofire.request(serverAPIUrl + "/fb/?method=addtransaction", method: .post, parameters: params).responseJSON { response in
            var resolvedTransaction: DOTransaction? = nil
            print(" \(response.request) with \(params) -> \(response.result.value)")

            switch response.result {
            case .success:
                if(response.result.value != nil) {
                    let json = JSON(response.result.value!)
                    if (self.checkResponse(json: json)) {
                        //Now you got your value
                        resolvedTransaction = DOTransaction(json: json["data"][0])
                        print(resolvedTransaction!)
                    } else {
                        print("error \(response.request) with \(params) -> \(json)")
                    }
                }
                break
            case .failure(let error):
                print(error)
                break
            }
            if (callback != nil) {
                callback!(resolvedTransaction)
            }
        }
    }

    func getTransactions(callback: TransactionsResponseCallback?) /*userid*/ {
        let params = [ "userid": SQLiteDataStore.sharedInstance.currentUser.userId, "accesstoken": SQLiteDataStore.sharedInstance.currentUser.userAccessToken, "usertick": SQLiteDataStore.sharedInstance.options.lastTick ] as [String : Any]

        Alamofire.request(serverAPIUrl + "/fb/?method=gettransactions", method: .post, parameters: params).responseJSON { response in
            var transactions: [DOTransaction] = []
            print(" \(response.request) with \(params) -> \(response.result.value)")

            switch response.result {
            case .success:
                if(response.result.value != nil) {
                    let json = JSON(response.result.value!)
                    if (self.checkResponse(json: json)) {
                        for item in json["data"].arrayValue {
                            transactions.append(DOTransaction(json: item))
                        }
                    }
                }
                break
            case .failure(let error):
                print(error)
                break
            }
            if (callback != nil) {
                callback!(transactions)
            }
        }
    }

    func getWidgetData(callback: WidgetResponseCallback?) {
        let params = [ "userid": SQLiteDataStore.sharedInstance.currentUser.userId, "accesstoken": SQLiteDataStore.sharedInstance.currentUser.userAccessToken, "usertick": SQLiteDataStore.sharedInstance.options.lastTick, "tiletype": "4" ] as [String : Any]

        Alamofire.request(serverAPIUrl + "/fb/?method=gettile", method: .post, parameters: params).responseJSON { response in
            print(" \(response.request) with \(params) -> \(response.result.value)")
            var widget: DOWidget = DOWidget(cost: 0.0, profit: 0.0, balance: 0.0, date: Int64(Date().timeIntervalSince1970), count: 0)
            switch response.result {
            case .success:
                if(response.result.value != nil) {
                    let json = JSON(response.result.value!)
                    if (self.checkResponse(json: json)) {
                        widget = DOWidget(json: json["data"][0])
                    }
                }
                break
            case .failure(let error):
                print(error)
                break
            }
            if (callback != nil) {
                callback!(widget)
            }
        }
    }

    func sendFeedback(feedback: DOFeedback, callback: FeedbackResponseCallback?) /*userid, reviewrating, reviewrecommend, reviewcomment*/ {
        let params = [ "userid": SQLiteDataStore.sharedInstance.currentUser.userId, "accesstoken": SQLiteDataStore.sharedInstance.currentUser.userAccessToken, "usertick": SQLiteDataStore.sharedInstance.options.lastTick, "reviewrating": feedback.reviewRating, "reviewrecommend": feedback.reviewRecommend, "reviewcomment": feedback.reviewComment ] as [String : Any]

        Alamofire.request(serverAPIUrl + "/fb/?method=sendfeedback", method: .post, parameters: params).responseJSON { response in
            print(" \(response.request) with \(params) -> \(response.result.value)")

            switch response.result {
            case .success:
                if(response.result.value != nil) {
                    let json = JSON(response.result.value!)
                    if (self.checkResponse(json: json)) {
                    }
                }
                break
            case .failure(let error):
                print(error)
                break
            }
            if (callback != nil) {
                callback!(feedback)
            }
        }
    }
}
