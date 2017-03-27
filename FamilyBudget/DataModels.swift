//
//  DataModels.swift
//  FamilyBudget
//
//  Created by Dmitry Rybochkin on 17.01.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import Foundation
import SwiftyJSON

enum CategoryTypes: String {
    case
        cost = "COST",
        profit = "PROFIT",
        all = "ALL"
    static let allValues = [cost, profit]
}

enum StatisticDataTypes: Int, Comparable {
    case
        none = 0,
        category = 1,
        user = 3,
        month = 5,
        transaction = 10

    public static func < (lhs: StatisticDataTypes, rhs: StatisticDataTypes) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    public static func <= (lhs: StatisticDataTypes, rhs: StatisticDataTypes) -> Bool {
        return lhs.rawValue <= rhs.rawValue
    }
    public static func >= (lhs: StatisticDataTypes, rhs: StatisticDataTypes) -> Bool {
        return lhs.rawValue >= rhs.rawValue
    }
    public static func > (lhs: StatisticDataTypes, rhs: StatisticDataTypes) -> Bool {
        return lhs.rawValue > rhs.rawValue
    }
}

//Widget
class DOWidget: NSObject {
    var cost: NSNumber
    var profit: NSNumber
    var balance: NSNumber
    var date: Int64
    var count: Int
    private var testPrivate: String?
    var methods: [String] = [String]()

    init(cost: NSNumber, profit: NSNumber, balance: NSNumber, date: Int64, count: Int) {
        self.cost = cost
        self.profit = profit
        self.balance = balance
        self.date = date
        self.count = count
    }

    init(json: JSON) {
        self.count = Int(json["NewCount"].string!)!
        self.date = Int64(json["DataDate"].string!)!
        self.cost = (json["Cost"].string?.toNumber())!
        self.profit = (json["Profit"].string?.toNumber())!
        self.balance = (json["Balance"].string?.toNumber())!
    }
}

//Feedback
class DOFeedback: DOWidget {
    var reviewRating: Int
    var reviewRecommend: Int
    var reviewComment: String
    var testEnum: CategoryTypes?
    private var _testGetter: String?
    var testGetter: String? {
        didSet {
            reviewComment = testGetter!
        }
    }
    var testClass: DOUser?
    var users: [DOUser]?

    init(reviewRating: Int, reviewRecommend: Int, reviewComment: String) {
        self.reviewRating = reviewRating
        self.reviewComment = reviewComment
        self.reviewRecommend = reviewRecommend

        super.init(cost: 0, profit: 0, balance: 0, date: 0, count: 0)
    }
}

// AppOptions model
class DOOptions: NSObject {
    var userId: Int64 = 0
    var lastTick: Int64 = 0
    var notificationToken: String = ""

    init(userId: Int64, lastTick: Int64, notificationToken: String) {
        self.userId = userId
        self.lastTick = lastTick
        self.notificationToken = notificationToken
    }
}

// User model
class DOUser: NSObject {
    var userId: Int64 = 0
    var userTitle: String = ""
    var userPassword: String = ""
    var userGroupKeyword: String = ""
    var userDeviceUID: String = ""
    var userAccessToken: String = ""
    var isConnected: Bool = false

    init(userId: Int64, userTitle: String, userPassword: String, userGroupKeyword: String) {
        self.userId = userId
        self.userTitle = userTitle
        self.userPassword = userPassword
        self.userGroupKeyword = userGroupKeyword
        self.userDeviceUID = ""
        self.userAccessToken = ""
        self.isConnected = false
    }

    init(json: JSON) {
        self.userId = Int64(json["UserId"].string!)!
        self.userTitle = json["UserTitle"].string!
        if (json["UserPassword"] != nil) {
            self.userPassword = json["UserPassword"].string!
        }
        if (json["UserGroupKeyword"] != nil) {
            self.userGroupKeyword = json["UserGroupKeyword"].string!
        }
        if (json["UserDeviceUID"] != nil) {
            self.userDeviceUID = json["UserDeviceUID"].string!
        }
        if (json["UserAccessToken"] != nil) {
            self.userAccessToken = json["UserAccessToken"].string!
        }
        self.isConnected = false
    }

    public func deepCopy() -> DOUser {
        let newUser = DOUser(userId: userId, userTitle: userTitle, userPassword: userPassword, userGroupKeyword: userGroupKeyword)
        newUser.userAccessToken = userAccessToken
        newUser.userDeviceUID = userDeviceUID
        return newUser
    }

}

// TransactionCategory model
class DOCategory: NSObject {
    var userId: Int64 = 0
    var categoryId: Int64 = 0
    var categoryTitle: String = ""
    var categoryType: CategoryTypes = CategoryTypes.cost
    var categoryUploaded: Int = 0
    var categoryDeleted: Int = 0

    init(categoryId: Int64, userId: Int64, categoryTitle: String, categoryType: CategoryTypes, categoryUploaded: Int, categoryDeleted: Int) {
        self.categoryId = categoryId
        self.userId = userId
        self.categoryTitle = categoryTitle
        self.categoryType = categoryType
        self.categoryUploaded = categoryUploaded
        self.categoryDeleted = categoryDeleted
    }

    init(json: JSON) {
        self.userId = Int64(json["UserId"].string!)!
        self.categoryId = Int64(json["CategoryId"].string!)!
        self.categoryTitle = json["CategoryTitle"].string!
        self.categoryType = CategoryTypes(rawValue: json["CategoryType"].string!)!
        self.categoryUploaded = Int(json["Uploaded"].string!)!
        if (json["Deleted"] != nil) {
            self.categoryDeleted = Int(json["Deleted"].string!)!
        }
    }
}

// Transaction model
class DOTransaction: NSObject {
    var transactionId: Int64 = 0
    var userId: Int64 = 0
    var categoryId: Int64 = 0
    var transactionDueDate: Int64 = 0
    var transactionCost: NSNumber = 0.0
    var transactionProfit: NSNumber = 0.0
    var transactionDescription: String = ""
    var transactionUploaded: Int = 0
    var transactionDeleted: Int = 0

    var transactionMonth: Int {
        return transactionDueDate.month()
    }
    var transactionYear: Int {
        return transactionDueDate.year()
    }

    init(transactionId: Int64, userId: Int64, categoryId: Int64, transactionDueDate: Int64, transactionCost: NSNumber, transactionProfit: NSNumber, transactionDescription: String, transactionUploaded: Int, transactionDeleted: Int) {
        self.transactionId = transactionId
        self.userId = userId
        self.categoryId = categoryId
        self.transactionDueDate = transactionDueDate
        self.transactionCost = transactionCost
        self.transactionProfit = transactionProfit
        self.transactionDescription = transactionDescription
        self.transactionUploaded = transactionUploaded
        self.transactionDeleted = transactionDeleted
    }

    init(json: JSON) {
        self.transactionId = Int64(json["TransactionId"].string!)!
        self.userId = Int64(json["UserId"].string!)!
        self.categoryId = Int64(json["CategoryId"].string!)!
        self.transactionDueDate = Int64(json["TransactionDueDate"].string!)!
        self.transactionCost = json["TransactionCost"].string!.toNumber()!
        self.transactionProfit = json["TransactionProfit"].string!.toNumber()!
        self.transactionDescription = json["TransactionDescription"].string!
        if (json["Uploaded"] != nil) {
            self.transactionUploaded = Int(json["Uploaded"].string!)!
        }
        if (json["Deleted"] != nil) {
            self.transactionDeleted = Int(json["Deleted"].string!)!
        }
    }
}

class DOStatisticData: NSObject {
    var dataTypes: [StatisticDataTypes]
    var date: Date?
    var userId: Int64?
    var userTitle: String?
    var categoryId: Int64?
    var categoryTitle: String?
    var categoryType: CategoryTypes?
    var dataCost: NSNumber
    var dataProfit: NSNumber
    var transactionId: Int64?
    var transactionDueDate: Int64?
    var transactionDescription: String?
    var color: UIColor?

    init(dataTypes: [StatisticDataTypes], dataCost: NSNumber, dataProfit: NSNumber, date: Date! = nil, userId: Int64! = nil, userTitle: String! = nil, categoryId: Int64! = nil, categoryTitle: String! = nil, categoryType: String! = nil, transactionId: Int64! = nil, transactionDueDate: Int64! = nil, transactionDescription: String! = nil) {

        self.dataTypes = dataTypes
        self.dataCost = dataCost
        self.dataProfit = dataProfit

        if (date != nil) { self.date = date }
        if (userId != nil) { self.userId = userId }
        if (userTitle != nil) { self.userTitle = userTitle }
        if (categoryId != nil) { self.categoryId = categoryId }
        if (categoryTitle != nil) { self.categoryTitle = categoryTitle }
        if (categoryType != nil) { self.categoryType = CategoryTypes(rawValue: categoryType!) }
        if (transactionId != nil) { self.transactionId = transactionId }
        if (transactionDueDate != nil) { self.transactionDueDate = transactionDueDate }
        if (transactionDescription != nil) { self.transactionDescription = transactionDescription }
        self.color = UIColor.getRandom()
    }
    var fullTitle: String {
        var array: [String] = []
        for item in dataTypes {
            if (item == StatisticDataTypes.category) {
                array.append(categoryTitle != nil ? categoryTitle! : "")
            } else if (item == StatisticDataTypes.user) {
                array.append(userTitle != nil ? userTitle! : "")
            } else if (item == StatisticDataTypes.month) {
                array.append(date != nil ? (date?.toStringWith(format: "MMMM, YYYY"))! : "")
            } else {
                array.append("Unknown")
            }
        }
        return "'"+array.joined(separator: "/")+"'"
    }
    var title: String {
        let item = dataTypes.last
        if (item == StatisticDataTypes.category) {
            return categoryTitle != nil ? categoryTitle! : ""
        } else if (item == StatisticDataTypes.user) {
            return userTitle != nil ? userTitle! : ""
        } else if (item == StatisticDataTypes.month) {
            return date != nil ? (date?.toStringWith(format: "MMMM, YYYY"))! : ""
        } else {
            return "Unknown"
        }
    }

    var isEmpty: Bool {
        if (categoryType == CategoryTypes.cost) {
            return dataCost.doubleValue < 0.001
        } else if (categoryType == CategoryTypes.profit) {
            return dataProfit.doubleValue < 0.001
        } else {
            return dataCost.doubleValue < 0.001 && dataProfit.doubleValue < 0.001
        }
    }
}

class DOChart: NSObject {
    var data: [DOStatisticData]
    var colors: [UIColor]!
    var circleColors: [UIColor]!
    var categoryType: CategoryTypes = CategoryTypes.all

    var color: UIColor {
        return colors![0]
    }
    var circleColor: UIColor {
        return circleColors![0]
    }

    init (data: [DOStatisticData], colors: [UIColor]? = nil, circeColors: [UIColor]? = nil, type: CategoryTypes = CategoryTypes.all) {
        self.data = data
        if (colors != nil) {
            self.colors = colors
        } else {
            self.colors = [UIColor.getRandom(), UIColor.getRandom()]
        }
        if (circeColors != nil) {
            self.circleColors = circeColors
        } else {
            self.circleColors = [UIColor.getRandom(), UIColor.getRandom()]
        }
        self.categoryType = type
    }
    lazy var count: Int = {
        return self.data.count + 1
    }()
}
