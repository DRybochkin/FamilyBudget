//
//  StatisticHelpers.swift
//  FamilyBudget
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import Foundation

enum SectionsTypes: Int {
    case
    transactions = 0,
    total = 1,
    users = 2,
    categories = 3,
    months = 4,
    pieChartByUsers = 5,
    pieChartByCategories = 6,
    lineChartByMonths = 7,
    barChartByUsers = 8
}

let defaultZeroValue: NSNumber = 0.0001

class Section: NSObject {
    var statistic: DOStatisticData!
    var dataTypes: [StatisticDataTypes]!
    var categoryType: CategoryTypes!
    var data: [DOStatisticData] = [DOStatisticData]()
    var chart: DOChart!
    var sectionType: SectionsTypes
    private var title: String!
    var parsedTitle: String {
        get {
            return String(format: title, statistic.fullTitle)
        }
    }
    
    var count: Int {
        get {
            if chart == nil {
                return data.count
            }
            return data.count + 1
        }
    }
    
    init(sectionType: SectionsTypes, title: String! = nil, dataType: StatisticDataTypes! = nil, statistic: DOStatisticData! = nil, categoryType: CategoryTypes! = nil) {
        self.sectionType = sectionType
        if (title != nil) {
            self.title = title
        }
        if (statistic == nil) {
            if (dataType != nil) {
                self.dataTypes = [dataType]
            }
            self.statistic = DOStatisticData(dataTypes: self.dataTypes, dataCost: 0.0, dataProfit: 0.0)
        } else {
            self.statistic = statistic
            self.dataTypes = statistic.dataTypes
            if (dataType != nil && !statistic.dataTypes.contains(dataType)) {
                self.dataTypes.append(dataType)
            }
        }
        if (categoryType != nil) {
            self.categoryType = categoryType
        }
    }
    
    private func updateTitle() {
        let item = statistic.dataTypes.last
        if (item == StatisticDataTypes.Category && statistic.categoryId != nil) {
            statistic.categoryTitle = DOCategoryDataHelper.find(id: statistic.categoryId!)?.categoryTitle
        } else if (item == StatisticDataTypes.User && statistic.userId != nil) {
            statistic.userTitle = DOUserDataHelper.find(id: statistic.userId!)?.userTitle
        }
    }

    func loadData() {
        updateTitle()
        
        switch (sectionType) {
        case .transactions:
            if (title == nil) {
                title = statistic.date?.toStringWith(format: "MMMM, YYYY")
            }
            data = DOTransactionDataHelper.getTransactions(date: statistic.date, user: statistic.userId, category: statistic.categoryId, type: categoryType)
            break
        case .categories:
            if (title == nil) {
                title = "Категории"
            }
            data = DOTransactionDataHelper.getStatistic(dataTypes: dataTypes, date: statistic.date, user: statistic.userId, category: statistic.categoryId, type: categoryType)
            break
        case .users:
            if (title == nil) {
                title = "Пользователи"
            }
            data = DOTransactionDataHelper.getStatistic(dataTypes: dataTypes, date: statistic.date, user: statistic.userId, category: statistic.categoryId, type: categoryType)
            break
        case .months:
            if (title == nil) {
                title = "Месяца"
            }
            data = DOTransactionDataHelper.getStatistic(dataTypes: dataTypes, date: statistic.date, user: statistic.userId, category: statistic.categoryId, type: categoryType)
            break
        case .total:
            if (title == nil) {
                title = "Итого"
            }
            data = DOTransactionDataHelper.getStatistic(dataTypes: dataTypes, date: statistic.date, user: statistic.userId, category: statistic.categoryId, type: categoryType)
            if (data.count <= 0) {
                data = [DOStatisticData(dataTypes: dataTypes, dataCost: 0.0, dataProfit: 0.0, date: statistic.date)]
            }
            break
        case .pieChartByUsers:
            if (title == nil) {
                title = "По пользователям"
            }
            data = DOTransactionDataHelper.getStatistic(dataTypes: dataTypes, date: statistic.date, category: statistic.categoryId, type: categoryType)
            let zero: NSNumber = (data.count == 0) ? defaultZeroValue : 0.0
            let users = DOUserDataHelper.getAll()
            for user in users! {
                let datas = data.filter { el in el.userId == user.userId }
                if (datas.count == 0) {
                    data.append(DOStatisticData(dataTypes: dataTypes, dataCost: zero, dataProfit: zero, date: statistic.date, userId: user.userId, userTitle: user.userTitle, categoryId: statistic.categoryId, categoryTitle: statistic.categoryTitle, categoryType: statistic.categoryType?.rawValue))
                }
            }
            chart = DOChart(data: data)
            break
        case .pieChartByCategories:
            if (title == nil) {
                title = "По категориям"
            }
            data = DOTransactionDataHelper.getStatistic(dataTypes: dataTypes, date: statistic.date, user: statistic.userId, type: categoryType)
            let zero: NSNumber = (data.count == 0) ? defaultZeroValue : 0.0
            let categories = DOCategoryDataHelper.getAll(type: categoryType)
            for category in categories {
                let datas = data.filter { el in el.categoryId == category.categoryId }
                if (datas.count == 0) {
                    data.append(DOStatisticData(dataTypes: dataTypes, dataCost: zero, dataProfit: zero, date: statistic.date, userId: statistic.userId, userTitle: statistic.userTitle, categoryId: category.categoryId, categoryTitle: category.categoryTitle, categoryType: categoryType.rawValue))
                }
            }
            chart = DOChart(data: data)
            break
        case .lineChartByMonths:
            if (title == nil) {
                title = "По месяцам"
            }
            if (statistic.categoryType == CategoryTypes.Cost || statistic.categoryType == CategoryTypes.Profit) {
                data = DOTransactionDataHelper.getStatistic(dataTypes: dataTypes, user: statistic.userId, category: statistic.categoryId, type: categoryType)
                chart = DOChart(data: data, type: statistic.categoryType!)
            } else {
                data = DOTransactionDataHelper.getStatistic(dataTypes: dataTypes!, user: statistic.userId, category: statistic.categoryId)
                let zero: NSNumber = (data.count == 0) ? defaultZeroValue : 0.0
                if (data.count <= 0) {
                    data = [DOStatisticData(dataTypes: dataTypes, dataCost: zero, dataProfit: zero, date: Date())]
                }
                chart = DOChart(data: data)
            }
            break
        case .barChartByUsers:
            if (title == nil) {
                title = "По пользователям"
            }
            data = DOTransactionDataHelper.getStatistic(dataTypes: dataTypes, date: statistic.date)
            let users = DOUserDataHelper.getAll()
            for user in users! {
                let datas = data.filter { el in el.userId == user.userId }
                if (datas.count == 0) {
                    data.append(DOStatisticData(dataTypes: dataTypes, dataCost: 0.0001, dataProfit: 0.0001, date: statistic.date, userId: user.userId, userTitle: user.userTitle, categoryId: statistic.categoryId, categoryTitle: statistic.categoryTitle, categoryType: statistic.categoryType?.rawValue))
                }
            }
            chart = DOChart(data: data)
            break
        }
    }
}
