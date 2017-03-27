//
//  Extensions.swift
//  FamilyBudget
//
//  Created by Dmitry Rybochkin on 16.01.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import Foundation
import SQLite

extension Date {
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }

    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }

    func startOfNextMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: 0), to: self.endOfMonth())!
    }

    func toStringWith(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format

        //dateFormatter.dateFormat = "yyyy MMM EEEE HH:mm"
        //dateFormatter.timeZone = NSTimeZone(name: "UTC")
        return dateFormatter.string(from: self)
    }
    static func from(month: Int, year: Int) -> Date {
        return Calendar.current.date(from: DateComponents(year: year, month: month, day: 1, hour: 0, minute: 0, second: Calendar.current.timeZone.secondsFromGMT()))!
    }
    func dateId() -> Int64 {
        return Int64(self.timeIntervalSince1970).dateId()
    }
    func month() -> Int {
        let components = Calendar.current.dateComponents([.day, .month, .year], from: self)
        return components.month!
    }
    func year() -> Int {
        let components = Calendar.current.dateComponents([.day, .month, .year], from: self)
        return components.year!
    }
    func dateDouble() -> Double {
        let components = Calendar.current.dateComponents([.day, .month, .year], from: self)
        return Double(components.year!) + Double(components.month!) / 12.0
    }
}

extension Double {
    func toDateStringWith(format: String) -> String {
        let year: Int = Int(self)
        let month: Int = Int(((self - trunc(self)) * 12.0).rounded())

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format

        //dateFormatter.dateFormat = "yyyy MMM EEEE HH:mm"
        //dateFormatter.timeZone = NSTimeZone(name: "UTC")
        return dateFormatter.string(from: Date.from(month: month, year: year))
    }
}

extension Int64 {
    func startOfMonth() -> Int64 {
        let year: Int = Int(trunc(Double(self / 100)))
        let month: Int = Int(self - year * 100)
        let date: Date = Calendar.current.date(from: DateComponents(year: year, month: month, day: 1, hour: 0, minute: 0, second: Calendar.current.timeZone.secondsFromGMT()))!
        return Int64(date.startOfMonth().timeIntervalSince1970)
    }
    func startOfNextMonth() -> Int64 {
        let year: Int = Int(trunc(Double(self / 100)))
        let month: Int = Int(self - year * 100)
        var date: Date = Calendar.current.date(from: DateComponents(year: year, month: month, day: 1, hour: 0, minute: 0, second: Calendar.current.timeZone.secondsFromGMT()))!
        date = date.startOfNextMonth()
        return Int64(date.timeIntervalSince1970)
    }
    func toStringWith(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let year: Int = Int(trunc(Double(self / 100)))
        let month: Int = Int(self - year * 100)
        let date: Date = Calendar.current.date(from: DateComponents(year: year, month: month, day: 1, hour: 0, minute: 0, second: Calendar.current.timeZone.secondsFromGMT()))!
        return dateFormatter.string(from: date)
    }
    func dateId() -> Int64 {
        let date: Date = Date(timeIntervalSince1970: TimeInterval(self))
        let components = Calendar.current.dateComponents([.day, .month, .year], from: date)
        return Int64(components.month!+components.year!*100)
    }
    func month() -> Int {
        let date: Date = Date(timeIntervalSince1970: TimeInterval(self))
        let components = Calendar.current.dateComponents([.day, .month, .year], from: date)
        return components.month!
    }
    func year() -> Int {
        let date: Date = Date(timeIntervalSince1970: TimeInterval(self))
        let components = Calendar.current.dateComponents([.day, .month, .year], from: date)
        return components.year!
    }
    func date() -> Date {
        return Date(timeIntervalSince1970: TimeInterval(self))
    }
}

extension NSNumber {
    func toStringWith(locale: String, andPrefix: String? = nil) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currencyAccounting

        numberFormatter.locale = Locale(identifier: locale)
        if (self.doubleValue < 0) {
            return numberFormatter.string(from: self)!
        } else if (andPrefix != nil && self.doubleValue != 0) {
            return andPrefix! + numberFormatter.string(from: self)!
        } else {
            return numberFormatter.string(from: self)!
        }
    }
    func toString(locale: String) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal

        numberFormatter.locale = Locale(identifier: locale)
        return numberFormatter.string(from: self)!
    }
}

extension Connection {
    static func storeURL(dbName: String) -> String {
        guard let documentsURL = URL(string: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]) else {
            fatalError("could not get user documents directory URL")
        }

        return documentsURL.appendingPathComponent(dbName).absoluteString
    }
}

extension UIColor {
    static func getRandom() -> UIColor {
        let red = Double(arc4random_uniform(256))
        let green = Double(arc4random_uniform(256))
        let blue = Double(arc4random_uniform(256))

        return UIColor(red: CGFloat(red / 255), green: CGFloat(green / 255), blue: CGFloat(blue / 255), alpha: 1)
    }
}

extension String {
    func toNumber() -> NSNumber? {

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.usesGroupingSeparator = false
        numberFormatter.currencyDecimalSeparator = NSLocale.current.decimalSeparator

        var str = self.replacingOccurrences(of: ".", with: NSLocale.current.decimalSeparator!)
        str = str.replacingOccurrences(of: ",", with: NSLocale.current.decimalSeparator!)

        var strArray = str.components(separatedBy: CharacterSet(charactersIn: "0123456789" + NSLocale.current.decimalSeparator!).inverted)
        for i in 0 ..< strArray.count where strArray[i] == NSLocale.current.decimalSeparator {
            strArray[i] = ""
            break
        }
        str = strArray.joined(separator: "")
        return numberFormatter.number(from: str)
    }
}

extension NSNotification.Name {
    public static var FamilyBudgetDidChangeData: NSNotification.Name = NSNotification.Name("FamilyBudgetDidChangeDataNotification")
    public static var FamilyBudgetNeedReloadData: NSNotification.Name = NSNotification.Name("FamilyBudgetNeedReloadDataNotification")
    public static var FamilyBudgetDidChangeOptions: NSNotification.Name = NSNotification.Name("FamilyBudgetDidChangeOptionsNotification")
    public static var FamilyBudgetCurrentUserChanged: NSNotification.Name = NSNotification.Name("FamilyBudgetCurrentUserChangedNotification")

    public static var FamilyBudgetDataWillLoad: NSNotification.Name = NSNotification.Name("FamilyBudgetDataWillLoad")
    public static var FamilyBudgetDataDidLoad: NSNotification.Name = NSNotification.Name("FamilyBudgetDataDidLoad")
}
