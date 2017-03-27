//
//  DataModels.swift
//  FamilyBudget
//
//  Created by Dmitry Rybochkin on 17.01.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import Foundation
import SwiftyJSON

enum NamePropertyMapRules: Int {
    case
        none = 0,
        ignoringCase = 1,
        firstSymbolToUpper = 2,
        firstSymbolToLower = 3
}

class JSONModel: NSObject, Reflectable {
    var keyMapper: [String: String]! {
        return [:]
    }

    var namePropertyRule: NamePropertyMapRules = NamePropertyMapRules.ignoringCase

    private func valueTo(_ value: Any?, _ property: SerializeProperty) -> Any? {
        if (value is NSNumber) {
            return numberTo(value as? NSNumber, property)
        } else if (value is String) {
            return stringTo(value as? String, property)
        } else if (value is Bool) {
            return boolTo(value as? Bool, property)
        } else if (value is NSNull) {
            return nullTo(value, property)
        } else if (value is [Any]) {
            return arrayTo(value as? [Any], property)
        } else if (value is [AnyHashable: Any]) {
            return dictionaryTo(value as? [AnyHashable: Any], property)
        } else {
        }
        return value
    }

    private func arrayTo(_ value: [Any]?, _ property: SerializeProperty) -> [Any]? {
        let type = property.type
        if (type is Array<Any>.Type) {
            return value
        } else {
            let sel: Selector = Selector(String(format: "arrayTo%@%@", String(describing: type), ":"))
            if (responds(to: sel)) {
                let res = perform(sel, with: value)
                return res?.takeRetainedValue() as? [Any]
            }
        }
        return nil
    }

    private func dictionaryTo(_ value: [AnyHashable: Any]?, _ property: SerializeProperty) -> [AnyHashable: Any]? {
        let type = property.type
        if (type is Dictionary<AnyHashable, Any>.Type) {
            return value
        } else {
            let sel: Selector = Selector(String(format: "dictionaryTo%@%@", String(describing: type), ":"))
            if (responds(to: sel)) {
                let res = perform(sel, with: value)
                return res?.takeRetainedValue() as? [AnyHashable: Any]
            }
        }
        return nil
    }

    private func unknownTo(_ value: Any?, _ property: SerializeProperty) -> Any? {
        let sel: Selector = Selector(String(format: "unknownTo%@%@", String(describing: property.type), ":"))
        if (responds(to: sel)) {
            return perform(sel, with: value)
        }
        return nil
    }

    private func nullTo(_ value: Any?, _ property: SerializeProperty) -> Any? {
        return nil
    }

    private func boolTo(_ value: Bool?, _ property: SerializeProperty) -> Any? {
        let type = property.type
        if (type is Int.Type || type is ImplicitlyUnwrappedOptional<Int>.Type || type is Optional<Int>.Type) {
            return Int(value! ? 1 : 0)
        } else if (type is Int64.Type || type is ImplicitlyUnwrappedOptional<Int64>.Type || type is Optional<Int64>.Type) {
            return Int64(value! ? 1 : 0)
        } else if (type is Int8.Type || type is ImplicitlyUnwrappedOptional<Int8>.Type || type is Optional<Int8>.Type) {
            return Int8(value! ? 1 : 0)
        } else if (type is Int16.Type || type is ImplicitlyUnwrappedOptional<Int16>.Type || type is Optional<Int16>.Type) {
            return Int16(value! ? 1 : 0)
        } else if (type is Int32.Type || type is ImplicitlyUnwrappedOptional<Int32>.Type || type is Optional<Int32>.Type) {
            return Int32(value! ? 1 : 0)
        } else if (type is Double.Type || type is ImplicitlyUnwrappedOptional<Double>.Type || type is Optional<Double>.Type) {
            return Double(value! ? 1 : 0)
        } else if (type is Float.Type || type is ImplicitlyUnwrappedOptional<Float>.Type || type is Optional<Float>.Type) {
            return Float(value! ? 1 : 0)
        } else if (type is Float32.Type || type is ImplicitlyUnwrappedOptional<Float32>.Type || type is Optional<Float32>.Type) {
            return Float32(value! ? 1 : 0)
        } else if (type is Float64.Type || type is ImplicitlyUnwrappedOptional<Float64>.Type || type is Optional<Float64>.Type) {
            return Float64(value! ? 1 : 0)
        } else if (type is Float80.Type || type is ImplicitlyUnwrappedOptional<Float80>.Type || type is Optional<Float80>.Type) {
            return Float80(value! ? 1 : 0)
        } else if (type is NSNumber.Type || type is ImplicitlyUnwrappedOptional<NSNumber>.Type || type is Optional<NSNumber>.Type) {
            return NSNumber(value: value!)
        } else if (type is String.Type || type is ImplicitlyUnwrappedOptional<String>.Type || type is Optional<String>.Type) {
            return value! ? "true" : "false"
        } else if (type is Bool.Type || type is ImplicitlyUnwrappedOptional<Bool>.Type || type is Optional<Bool>.Type) {
            return value
        } else if (type is Date.Type || type is ImplicitlyUnwrappedOptional<Date>.Type || type is Optional<Date>.Type) {
            return nil
        } else {
            let sel: Selector = Selector(String(format: "boolTo%@%@", String(describing: type), ":"))
            if (responds(to: sel)) {
                return perform(sel, with: value)
            }
        }
        return value
    }

    private func numberTo(_ value: NSNumber?, _ property: SerializeProperty) -> Any? {
        let type = property.type
        if (type is Int.Type || type is ImplicitlyUnwrappedOptional<Int>.Type || type is Optional<Int>.Type) {
            return value?.intValue
        } else if (type is Int64.Type || type is ImplicitlyUnwrappedOptional<Int64>.Type || type is Optional<Int64>.Type) {
            return value?.int64Value
        } else if (type is Int8.Type || type is ImplicitlyUnwrappedOptional<Int8>.Type || type is Optional<Int8>.Type) {
            return value?.int8Value
        } else if (type is Int16.Type || type is ImplicitlyUnwrappedOptional<Int16>.Type || type is Optional<Int16>.Type) {
            return value?.int16Value
        } else if (type is Int32.Type || type is ImplicitlyUnwrappedOptional<Int32>.Type || type is Optional<Int32>.Type) {
            return value?.int32Value
        } else if (type is Double.Type || type is ImplicitlyUnwrappedOptional<Double>.Type || type is Optional<Double>.Type) {
            return value?.doubleValue
        } else if (type is Float.Type || type is ImplicitlyUnwrappedOptional<Float>.Type || type is Optional<Float>.Type) {
            return value?.floatValue
        } else if (type is Float32.Type || type is ImplicitlyUnwrappedOptional<Float32>.Type || type is Optional<Float32>.Type) {
            return Float32(value!)
        } else if (type is Float64.Type || type is ImplicitlyUnwrappedOptional<Float64>.Type || type is Optional<Float64>.Type) {
            return Float64(value!)
        } else if (type is Float80.Type || type is ImplicitlyUnwrappedOptional<Float80>.Type || type is Optional<Float80>.Type) {
            return Float80((value?.floatValue)!)
        } else if (type is NSNumber.Type || type is ImplicitlyUnwrappedOptional<NSNumber>.Type || type is Optional<NSNumber>.Type) {
            return value
        } else if (type is String.Type || type is ImplicitlyUnwrappedOptional<String>.Type || type is Optional<String>.Type) {
            return value?.stringValue
        } else if (type is Bool.Type || type is ImplicitlyUnwrappedOptional<Bool>.Type || type is Optional<Bool>.Type) {
            return value?.boolValue
        } else if (type is Date.Type || type is ImplicitlyUnwrappedOptional<Date>.Type || type is Optional<Date>.Type) {
            return Date(timeIntervalSince1970: TimeInterval((value?.intValue)!))
        } else {
            let sel: Selector = Selector(String(format: "numberTo%@%@", String(describing: type), ":"))
            if (responds(to: sel)) {
                return perform(sel, with: value)
            }
        }
        return value
    }

    private func stringTo(_ value: String?, _ property: SerializeProperty) -> Any? {
        let type = property.type
        if (type is Int.Type || type is ImplicitlyUnwrappedOptional<Int>.Type || type is Optional<Int>.Type) {
            return Int(value!)
        } else if (type is Int64.Type || type is ImplicitlyUnwrappedOptional<Int64>.Type || type is Optional<Int64>.Type) {
            return Int64(value!)
        } else if (type is Int8.Type || type is ImplicitlyUnwrappedOptional<Int8>.Type || type is Optional<Int8>.Type) {
            return Int8(value!)
        } else if (type is Int16.Type || type is ImplicitlyUnwrappedOptional<Int16>.Type || type is Optional<Int16>.Type) {
            return Int16(value!)
        } else if (type is Int32.Type || type is ImplicitlyUnwrappedOptional<Int32>.Type || type is Optional<Int32>.Type) {
            return Int32(value!)
        } else if (type is Double.Type || type is ImplicitlyUnwrappedOptional<Double>.Type || type is Optional<Double>.Type) {
            return Double(value!)
        } else if (type is Float.Type || type is ImplicitlyUnwrappedOptional<Float>.Type || type is Optional<Float>.Type) {
            return Float(value!)
        } else if (type is Float32.Type || type is ImplicitlyUnwrappedOptional<Float32>.Type || type is Optional<Float32>.Type) {
            return Float32(value!)
        } else if (type is Float64.Type || type is ImplicitlyUnwrappedOptional<Float64>.Type || type is Optional<Float64>.Type) {
            return Float64(value!)
        } else if (type is Float80.Type || type is ImplicitlyUnwrappedOptional<Float80>.Type || type is Optional<Float80>.Type) {
            return Float80(value!)
        } else if (type is NSNumber.Type || type is ImplicitlyUnwrappedOptional<NSNumber>.Type || type is Optional<NSNumber>.Type) {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            numberFormatter.usesGroupingSeparator = false
            numberFormatter.currencyDecimalSeparator = NSLocale.current.decimalSeparator

            var str = value?.replacingOccurrences(of: ".", with: NSLocale.current.decimalSeparator!)
            str = str?.replacingOccurrences(of: ",", with: NSLocale.current.decimalSeparator!)

            var strArray = str?.components(separatedBy: CharacterSet(charactersIn: "0123456789" + NSLocale.current.decimalSeparator!).inverted)
            if let count: Int = strArray?.count {
                for i in 0 ..< count where strArray?[i] == NSLocale.current.decimalSeparator {
                    strArray?[i] = ""
                    break
                }
            }
            str = strArray?.joined(separator: "")
            return numberFormatter.number(from: str!)
        } else if (type is String.Type || type is ImplicitlyUnwrappedOptional<String>.Type || type is Optional<String>.Type) {
            return value
        } else if (type is Bool.Type || type is ImplicitlyUnwrappedOptional<Bool>.Type || type is Optional<Bool>.Type) {
            return (value == "true" || value == "YES") ? true : false
        } else if (type is Date.Type || type is ImplicitlyUnwrappedOptional<Date>.Type || type is Optional<Date>.Type) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZZZZZZ"
            return dateFormatter.date(from: value!)
        } else {
            let sel: Selector = Selector(String(format: "stringTo%@%@", String(describing: type), ":"))
            if (responds(to: sel)) {
                return perform(sel, with: value)
            }
        }
        return value
    }

    private func capitalizeFirst(_ string: String, upperCase: Bool = true) -> String {
        if (!string.characters.isEmpty) {
            var firstCharacter = String(string.characters.first!)
            if (upperCase) {
                firstCharacter = firstCharacter.uppercased()
            } else {
                firstCharacter = firstCharacter.lowercased()
            }

            return string.replacingCharacters(in: string.startIndex ..< string.index(after: string.startIndex), with: firstCharacter)
        }
        return string
    }

    func willPropertyChanged(_ value: Any, _ property: SerializeProperty) -> Bool {
        return false
    }

    func setCustomValue(_ value: Any, _ property: SerializeProperty) {
        if (!willPropertyChanged(value, property)) {
            super.setValue(value, forKey: property.name)
        }
    }

    init!(json: JSON?) {
        super.init()
        if (json != nil) {
            let map = keyMapper!
            for property in properties() {
                var propertyName = property.name
                var found: Bool = false

                if (namePropertyRule == .ignoringCase) {
                    if (map.keys.contains(property.name)) {
                        propertyName = map[property.name]!
                    }
                    found = (json?.dictionaryObject?.keys.contains { (elem: String) -> Bool in
                        if (elem.lowercased() == propertyName.lowercased()) {
                            propertyName = elem
                            return true
                        }
                        return false
                    })!
                } else if (namePropertyRule == .firstSymbolToUpper) {
                    if (map.keys.contains(property.name)) {
                        propertyName = map[property.name]!
                    }
                    found = (json?.dictionaryObject?.keys.contains { (elem: String) -> Bool in
                        if (elem == capitalizeFirst(propertyName)) {
                            propertyName = elem
                            return true
                        }
                        return false
                    })!
                } else if (namePropertyRule == .firstSymbolToLower) {
                    if (map.keys.contains(property.name)) {
                        propertyName = map[property.name]!
                    }
                    found = (json?.dictionaryObject?.keys.contains { (elem: String) -> Bool in
                        if (elem == capitalizeFirst(propertyName, upperCase: false)) {
                            propertyName = elem
                            return true
                        }
                        return false
                    })!
                } else if (namePropertyRule == .none) {
                    if (map.keys.contains(property.name)) {
                        propertyName = map[property.name]!
                    }
                    found = (json?.dictionaryObject?.keys.contains(propertyName))!
                }
                if (found) {
                    if (json?[propertyName].type == .number) {
                        let convertedValue = valueTo(json?[propertyName].number, property)!
                        setCustomValue(convertedValue, property)
                    } else if (json?[propertyName].type == .string) {
                        let convertedValue = valueTo(json?[propertyName].stringValue, property)!
                        setCustomValue(convertedValue, property)
                    } else if (json?[propertyName].type == .bool) {
                        let convertedValue = valueTo(json?[propertyName].boolValue, property)!
                        setCustomValue(convertedValue, property)
                    } else if (json?[propertyName].type == .array) {
                        let convertedValue = valueTo(json?[propertyName].arrayValue, property)!
                        setCustomValue(convertedValue, property)
                    } else if (json?[propertyName].type == .dictionary) {
                        let convertedValue = valueTo(json?[propertyName].dictionaryValue, property)!
                        setCustomValue(convertedValue, property)
                    } else if (json?[propertyName].type == .null) {
                        let convertedValue = valueTo(json?[propertyName].null, property)!
                        setCustomValue(convertedValue, property)
                    } else if (json?[propertyName].type == .unknown) {
                        let convertedValue = valueTo(json?[propertyName].object, property)!
                        setCustomValue(convertedValue, property)
                    }
                }
            }
        }
    }

    func properties() -> [SerializeProperty] {
        return Mirror(reflecting: self).toArray()
    }

    func NumberToInt64(_ value: NSNumber) -> Int64 { // swiftlint:disable:this identifier_name
        return value.int64Value
    }

    func NumberToInt(_ value: NSNumber) -> Int { // swiftlint:disable:this identifier_name
        return value.intValue
    }

    func StringToInt64(_ value: String) -> Int64 { // swiftlint:disable:this identifier_name
        return Int64(value)!
    }

    func StringToInt(_ value: String) -> Int { // swiftlint:disable:this identifier_name
        return Int(value)!
    }

    func StringToString(_ value: String) -> String { // swiftlint:disable:this identifier_name
        return value
    }
}

protocol Reflectable {
    func properties() -> [SerializeProperty]
}

class SerializeProperty {
    var name: String = ""
    var type: Any.Type = String.Type.self

    init(name: String, type: Any.Type) {
        self.name = name
        self.type = type
    }
}

extension Mirror {
    func toArray() -> [SerializeProperty] {
        var result = [SerializeProperty]()

        // Properties of this instance:
        for property in self.children {
            if let propertyName = property.label {
                result.append(SerializeProperty(name: propertyName, type: type(of: property.value)))
            }
        }

        // Add properties of superclass:
        if let parent = self.superclassMirror {
            for propertyName in parent.toArray() {
                result.append(propertyName)
            }
        }

        return result
    }
}

extension JSONModel {
    open func stringToNamePropertyMapRules(_ value: String) -> Any {
        return NamePropertyMapRules(rawValue: Int(value)!)!
    }

    open func numberToNamePropertyMapRules(_ value: NSNumber) -> Any {
        return NamePropertyMapRules(rawValue: value.intValue)!
    }
}

class TestJsonModel: JSONModel {
    var id: Int = 0
    var optionalId: Int64?
    var optionalDefaultId: Int64!
    var enumVar: NamePropertyMapRules = NamePropertyMapRules.none
    var optionalEnum: NamePropertyMapRules?
    var optionalDefaultEnum: NamePropertyMapRules!

// swiftlint:disable:next force_cast
    override func willPropertyChanged(_ value: Any, _ property: SerializeProperty) -> Bool {
        if (property.name == "optionalId") {
            optionalId = value as? Int64
        } else if (property.name == "optionalDefaultId") {
            optionalDefaultId = value as? Int64
        } else if (property.name == "enumVar") {
            enumVar = value as! NamePropertyMapRules // swiftlint:disable:this force_cast
        } else if (property.name == "optionalEnum") {
            enumVar = value as! NamePropertyMapRules // swiftlint:disable:this force_cast
        } else if (property.name == "optionalDefaultEnum") {
            enumVar = value as! NamePropertyMapRules // swiftlint:disable:this force_cast
        } else {
            return false
        }
        return true
    }
}
