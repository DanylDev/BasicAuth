//
//  Category.swift
//  Drink App
//
//  Created by Andrew Dunn on 19/02/2019.
//  Copyright © 2019 Denis Yakovenko. All rights reserved.
//

import Foundation
import RealmSwift
import MapKit

class Category: Object {
    @objc dynamic var location:Location!
    @objc dynamic var locationId = 0
    @objc dynamic var categoryId = 0
    @objc dynamic var name = ""
    @objc dynamic var categoryDescription = ""
    
    var items = List<Item>()
}
