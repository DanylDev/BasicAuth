//
//  OrderItem.swift
//  Drink App
//
//  Created by Andrew Dunn on 25/02/2019.
//  Copyright © 2019 Denis Yakovenko. All rights reserved.
//

import Foundation
import RealmSwift

class OrderItem: Object {
    @objc dynamic var orderId:Int = 0
    @objc dynamic var itemId:Int = 0
    @objc dynamic var quantity = 0
}
