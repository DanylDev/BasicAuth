//
//  Database.swift
//  Drink App
//
//  Created by Andrew Dunn on 14/03/2019.
//  Copyright © 2019 Denis Yakovenko. All rights reserved.
//

import Foundation
import RealmSwift

class Database:NSObject {
    
    class var sharedInstance: Database {
        struct Singleton {
            static let instance = Database()
        }
        return Singleton.instance
    }

    func getLocationCategories(location:Location) -> Results<Category>? {
        
        let realm = try! Realm()
        let categories = realm.objects(Category.self).filter("locationId = \(location.locationId)")
        return categories
    }

    func getItemsInCategory(category:Category, location:Location) -> Results<Item>? {
        
        let realm = try! Realm()
        let items = realm.objects(Item.self).filter("categoryId = \(category.categoryId) && locationId = \(location.locationId)")
        return items
    }

    func getItemById(itemId:Int) -> Item? {
        
        let realm = try! Realm()
        let item = realm.objects(Item.self).filter("itemId = \(itemId)").first
        return item
    }

}
