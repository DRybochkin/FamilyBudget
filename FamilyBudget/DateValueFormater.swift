//
//  DateValueFormater.swift
//  FamilyBudget
//
//  Created by Dmitry Rybochkin on 02.02.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import Foundation
import Charts

class DateValueFormater: NSObject, IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return value.toDateStringWith(format: "MMMM, YYYY")
    }
}

class AmountValueFormater: NSObject, IValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return NSNumber(value: value).toStringWith(locale: "ru_RU")
    }
}

