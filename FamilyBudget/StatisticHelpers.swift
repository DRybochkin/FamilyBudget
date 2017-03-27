//
//  StatisticHelpers.swift
//  FamilyBudget
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import Foundation
import UIKit

class StatisticHelpers {

    private static func createViewController(_ sections: [Section], _ pageController: StatisticPageViewController) -> StatisticTableViewController {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StatisticTableViewController") as? StatisticTableViewController else {
            return StatisticTableViewController(sections, pageController)
        }
        vc.sections = sections
        vc.pageViewController = pageController
        return vc
    }

    private static func createViewController(_ section: Section, _ pageControleler: StatisticPageViewController) -> StatisticTableViewController {
        return createViewController([section], pageControleler)
    }

    private static func mainViewControllers(_ pageController: StatisticPageViewController!) -> [StatisticTableViewController] {
        let statistic = DOStatisticData(dataTypes: [], dataCost: 0.0, dataProfit: 0.0, date: Date())
        let vc1 = createViewController([Section(sectionType: SectionsTypes.lineChartByMonths, title: "Текущий месяц", dataType: StatisticDataTypes.month, statistic: statistic), Section(sectionType: SectionsTypes.transactions, title: "Последние операции", statistic: statistic)], pageController)

        vc1.barButtons = [vc1.addCostTransactionButton, vc1.addProfitTransactionButton, vc1.editButton]

        let vc2 = createViewController(Section(sectionType: SectionsTypes.lineChartByMonths, title: "По месяцам", dataType: StatisticDataTypes.month), pageController)

        let vc3 = createViewController(Section(sectionType: SectionsTypes.pieChartByCategories, title: "Категории расходов", dataType: StatisticDataTypes.category, categoryType: CategoryTypes.cost), pageController)
        vc3.barButtons = [vc3.addCostCategoryButton, vc3.editButton]

        let vc4 = createViewController(Section(sectionType: SectionsTypes.pieChartByCategories, title: "Категории доходов", dataType: StatisticDataTypes.category, categoryType: CategoryTypes.profit), pageController)
        vc4.barButtons = [vc4.addProfitCategoryButton, vc4.editButton]

        let vc5 = createViewController(Section(sectionType: SectionsTypes.barChartByUsers, title: "Пользователи", dataType: StatisticDataTypes.user), pageController)

        return [vc1, vc2, vc3, vc4, vc5]
    }

    private static func monthViewControllers(_ statistic: DOStatisticData!, _ pageController: StatisticPageViewController!) -> [StatisticTableViewController] {
        let vc1 = createViewController([Section(sectionType: SectionsTypes.total, title: "Итого за %@", statistic: statistic), Section(sectionType: SectionsTypes.transactions, title: "Операции за %@", statistic: statistic)], pageController)
        vc1.barButtons = [vc1.addCostTransactionButton, vc1.addProfitTransactionButton, vc1.editButton]

        let vc2 = createViewController(Section(sectionType: SectionsTypes.pieChartByCategories, title: "Расходы за %@ по категориям", dataType: StatisticDataTypes.category, statistic: statistic, categoryType: CategoryTypes.cost), pageController)
        vc2.barButtons = [vc2.addCostCategoryButton, vc2.editButton]

        let vc3 = createViewController(Section(sectionType: SectionsTypes.pieChartByCategories, title: "Доходы за %@ по категориям", dataType: StatisticDataTypes.category, statistic: statistic, categoryType: CategoryTypes.profit), pageController)
        vc3.barButtons = [vc3.addProfitCategoryButton, vc3.editButton]

        let vc4 = createViewController(Section(sectionType: SectionsTypes.barChartByUsers, title: "%@ по пользователям", dataType: StatisticDataTypes.user, statistic: statistic), pageController)

        return [vc1, vc2, vc3, vc4]
    }

    private static func categoryViewControllers(_ statistic: DOStatisticData!, _ pageController: StatisticPageViewController!) -> [StatisticTableViewController] {
        let vc1 = createViewController([Section(sectionType: SectionsTypes.total, title: "Итого по %@", statistic: statistic), Section(sectionType: SectionsTypes.transactions, title: "Операции по %@", statistic: statistic)], pageController)
        if (statistic.categoryType == nil) {
            vc1.barButtons = [vc1.addCostTransactionButton, vc1.addProfitTransactionButton, vc1.editButton]
        } else if (statistic.categoryType == CategoryTypes.cost) {
            vc1.barButtons = [vc1.addCostTransactionButton, vc1.editButton]
        } else {
            vc1.barButtons = [vc1.addProfitTransactionButton, vc1.editButton]
        }

        let vc2 = createViewController(Section(sectionType: SectionsTypes.lineChartByMonths, title: "%@ по месяцам", dataType: StatisticDataTypes.month, statistic: statistic), pageController)
        let vc3 = createViewController(Section(sectionType: SectionsTypes.pieChartByUsers, title: "%@ по пользователям", dataType: StatisticDataTypes.user, statistic: statistic), pageController)
        return [vc1, vc2, vc3]
    }

    private static func userViewControllers(_ statistic: DOStatisticData!, _ pageController: StatisticPageViewController!) -> [StatisticTableViewController] {
        let vc1 = createViewController([Section(sectionType: SectionsTypes.total, title: "Итого по %@", statistic: statistic), Section(sectionType: SectionsTypes.transactions, title: "Операции %@", statistic: statistic)], pageController)
        vc1.barButtons = [vc1.addCostTransactionButton, vc1.addProfitTransactionButton, vc1.editButton]

        let vc2 = createViewController(Section(sectionType: SectionsTypes.lineChartByMonths, title: "%@ по месяцам", dataType: StatisticDataTypes.month, statistic: statistic), pageController)

        let vc3 = createViewController(Section(sectionType: SectionsTypes.pieChartByCategories, title: "Расходы за %@ по категориям", dataType: StatisticDataTypes.category, statistic: statistic, categoryType: CategoryTypes.cost), pageController)
        vc3.barButtons = [vc3.addCostCategoryButton, vc3.editButton]

        let vc4 = createViewController(Section(sectionType: SectionsTypes.pieChartByCategories, title: "Доходы за %@ по категориям", dataType: StatisticDataTypes.category, statistic: statistic, categoryType: CategoryTypes.profit), pageController)
        vc4.barButtons = [vc4.addProfitCategoryButton, vc4.editButton]

        return [vc1, vc2, vc3, vc4]
    }

    private static func monthUserViewControllers(_ statistic: DOStatisticData!, _ pageController: StatisticPageViewController!) -> [StatisticTableViewController] {
        let vc1 = createViewController([Section(sectionType: SectionsTypes.barChartByUsers, title: "Итого за %@", statistic: statistic), Section(sectionType: SectionsTypes.transactions, title: "Операции за %@", statistic: statistic)], pageController)
        vc1.barButtons = [vc1.addCostTransactionButton, vc1.addProfitTransactionButton, vc1.editButton]

        let vc2 = createViewController(Section(sectionType: SectionsTypes.pieChartByCategories, title: "Расходы за %@ по категориям", dataType: StatisticDataTypes.category, statistic: statistic, categoryType: CategoryTypes.cost), pageController)
        vc2.barButtons = [vc2.addCostCategoryButton, vc2.editButton]

        let vc3 = createViewController(Section(sectionType: SectionsTypes.pieChartByCategories, title: "Доходы за %@ по категориям", dataType: StatisticDataTypes.category, statistic: statistic, categoryType: CategoryTypes.profit), pageController)
        vc3.barButtons = [vc3.addProfitCategoryButton, vc3.editButton]
        return [vc1, vc2, vc3]
    }

    private static func monthCategoryViewControllers(_ statistic: DOStatisticData!, _ pageController: StatisticPageViewController!) -> [StatisticTableViewController] {
        let vc1 = createViewController([Section(sectionType: SectionsTypes.total, title: "Итого за %@", statistic: statistic), Section(sectionType: SectionsTypes.transactions, title: "Операции за %@", statistic: statistic)], pageController)

        if (statistic.categoryType == nil) {
            vc1.barButtons = [vc1.addCostTransactionButton, vc1.addProfitTransactionButton, vc1.editButton]
        } else if (statistic.categoryType == CategoryTypes.cost) {
            vc1.barButtons = [vc1.addCostTransactionButton, vc1.editButton]
        } else {
            vc1.barButtons = [vc1.addProfitTransactionButton, vc1.editButton]
        }

        let vc2 = createViewController(Section(sectionType: SectionsTypes.pieChartByUsers, title: "%@ по пользователям", dataType: StatisticDataTypes.user, statistic: statistic), pageController)
        return [vc1, vc2]
    }

    private static func userCategoryViewControllers(_ statistic: DOStatisticData!, _ pageController: StatisticPageViewController!) -> [StatisticTableViewController] {
        let vc1 = createViewController([Section(sectionType: SectionsTypes.total, title: "Итого по %@", statistic: statistic), Section(sectionType: SectionsTypes.transactions, title: "Операции %@", statistic: statistic)], pageController)

        if (statistic.categoryType == nil) {
            vc1.barButtons = [vc1.addCostTransactionButton, vc1.addProfitTransactionButton, vc1.editButton]
        } else if (statistic.categoryType == CategoryTypes.cost) {
            vc1.barButtons = [vc1.addCostTransactionButton, vc1.editButton]
        } else {
            vc1.barButtons = [vc1.addProfitTransactionButton, vc1.editButton]
        }

        let vc2 = createViewController(Section(sectionType: SectionsTypes.lineChartByMonths, title: "%@ по месяцам", dataType: StatisticDataTypes.month, statistic: statistic), pageController)
        return [vc1, vc2]
    }

    private static func userMonthCategoryViewControllers(_ statistic: DOStatisticData, _ pageController: StatisticPageViewController) -> [StatisticTableViewController] {
        let sect1 = Section(sectionType: SectionsTypes.total, title: "Итого по %@", statistic: statistic)
        let sect2 = Section(sectionType: SectionsTypes.transactions, title: "Операции %@", statistic: statistic)
        let vc1 = createViewController([sect1, sect2], pageController)

        if (statistic.categoryType == nil) {
            vc1.barButtons = [vc1.addCostTransactionButton, vc1.addProfitTransactionButton, vc1.editButton]
        } else if (statistic.categoryType == CategoryTypes.cost) {
            vc1.barButtons = [vc1.addCostTransactionButton, vc1.editButton]
        } else {
            vc1.barButtons = [vc1.addProfitTransactionButton, vc1.editButton]
        }

        return [vc1]
    }

    static func createControllers(_ statistic: DOStatisticData!, pageController: StatisticPageViewController!) -> [StatisticTableViewController] {
        if (statistic == nil || statistic.dataTypes.isEmpty) {
            return mainViewControllers(pageController)
        } else {
            if (statistic.dataTypes == [StatisticDataTypes.month]) {
                return monthViewControllers(statistic, pageController)
            } else if (statistic.dataTypes == [StatisticDataTypes.category]) {
                return categoryViewControllers(statistic, pageController)
            } else if (statistic.dataTypes == [StatisticDataTypes.user]) {
                return userViewControllers(statistic, pageController)
            } else if (statistic.dataTypes.contains(StatisticDataTypes.category) && statistic.dataTypes.contains(StatisticDataTypes.month) && statistic.dataTypes.contains(StatisticDataTypes.user)) {
                return userMonthCategoryViewControllers(statistic, pageController)
            } else if (statistic.dataTypes.contains(StatisticDataTypes.category) && statistic.dataTypes.contains(StatisticDataTypes.month)) {
                return monthCategoryViewControllers(statistic, pageController)
            } else if (statistic.dataTypes.contains(StatisticDataTypes.category) && statistic.dataTypes.contains(StatisticDataTypes.user)) {
                return userCategoryViewControllers(statistic, pageController)
            } else if (statistic.dataTypes.contains(StatisticDataTypes.user) && statistic.dataTypes.contains(StatisticDataTypes.month)) {
                return monthUserViewControllers(statistic, pageController)
            } else if (statistic.dataTypes.contains(StatisticDataTypes.category) && statistic.dataTypes.contains(StatisticDataTypes.month) && statistic.dataTypes.contains(StatisticDataTypes.user)) {
                return userMonthCategoryViewControllers(statistic, pageController)
            }
        }
        return []
    }
}
