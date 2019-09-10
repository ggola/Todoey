//
//  Item.swift
//  Todoey
//
//  Created by Giulio Gola on 06/06/2019.
//  Copyright © 2019 Giulio Gola. All rights reserved.
//

import Foundation
import RealmSwift

// Subclass: Object to persist with Realm.
class Item : Object {
    // dynamic: runtime monitoring by Realm
    @objc dynamic var title : String = ""
    @objc dynamic var done : Bool = false
    @objc dynamic var dateCreated : Date?
    // LinkingObjects: defines the inverse relationship
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
