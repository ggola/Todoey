//
//  Category.swift
//  Todoey
//
//  Created by Giulio Gola on 06/06/2019.
//  Copyright © 2019 Giulio Gola. All rights reserved.
//

import Foundation
import RealmSwift

// Subclass: Object to persist with Realm.
class Category: Object {
    // dynamic: runtime monitoring by Realm
    @objc dynamic var name : String = ""
    @objc dynamic var backgroundColor : String?
    // List: container type to create to-many relationships
    let items = List<Item>()
}
