//
//  Location.swift
//  Drink App
//
//  Created by Andrew Dunn on 14/02/2019.
//  Copyright © 2019 Denis Yakovenko. All rights reserved.
//

import Foundation
import RealmSwift
import MapKit

class Location: Object {
    @objc dynamic var locationId = 0
    @objc dynamic var userId = 0
    @objc dynamic var name = ""
    @objc dynamic var locationDescription = ""
    @objc dynamic var phone = ""
    @objc dynamic var country = ""
    @objc dynamic var state = ""
    @objc dynamic var city = ""
    @objc dynamic var address = ""
    @objc dynamic var latitude = ""
    @objc dynamic var longitude = ""
    
//    var categories = List<Category>()
//    let items = List<Item>()
}
