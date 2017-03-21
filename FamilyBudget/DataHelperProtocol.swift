//
//  DataHelperProtocol.swift
//  FamilyBudget
//
//  Created by Dmitry Rybochkin on 17.01.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import Foundation

protocol DataHelperProtocol {
    associatedtype T

    static func createTable() -> Bool
    static func dropTable() -> Bool
    static func insert(item: T, needPost: Bool) -> Int64
    static func update(item: T, needPost: Bool) -> Int64
    static func resolve(item: T, needPost: Bool) -> T?
    static func delete(item: T, needPost: Bool) -> Bool
    static func clear(needPost: Bool) -> Bool
    static func find(id: Int64) -> T?
    static func getAll() -> [T]?

    //TODO
    //static func updateId(_: Int64, toId: Int64)
    //static func insertAll(items: [T]) -> Bool
    //static func updateAll(items: [T]) -> Bool
    //static func resolveAll(items: [T]) -> Bool
    //static func fromJson(json: String) -> T?
    //static func allFromJson(json: String) -> [T]?
}

