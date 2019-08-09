//
//  Item.swift
//  Drink App
//
//  Created by Andrew Dunn on 19/02/2019.
//  Copyright © 2019 Denis Yakovenko. All rights reserved.
//

import Foundation
import RealmSwift
import MapKit

class Item: Object {
    @objc dynamic var userId = 0
    
    @objc dynamic var itemId = 0
    @objc dynamic var categoryId = 0
    @objc dynamic var locationId = 0
    
    @objc dynamic var name = ""
    @objc dynamic var itemDescription = ""
    @objc dynamic var itemPrice = 0.0
    @objc dynamic var imageUrl = ""
}
