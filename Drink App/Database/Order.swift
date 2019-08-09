//
//  Order.swift
//  Drink App
//
//  Created by Andrew Dunn on 25/02/2019.
//  Copyright © 2019 Denis Yakovenko. All rights reserved.
//

import Foundation
import RealmSwift

class Order: Object {
    
    @objc dynamic var orderId:Int = 0
    @objc dynamic var orderNumber:Int = 0
    @objc dynamic var email:String = ""
    @objc dynamic var dateTime = Date()
    
    @objc dynamic var status: OrderStatus = .pending
    @objc enum OrderStatus: Int {
        case pending
        case failed
        case readyForCollection
        case readyForDelivery
        case completed
    }
    
    @objc dynamic var locationId = 0
    @objc dynamic var location:Location?
    
    @objc dynamic var totalCost = 0.0
    @objc dynamic var totalFee = 0.0
    @objc dynamic var overallTotal = 0.0
    
    @objc dynamic var isCurrent = true
    @objc dynamic var isDeliver = false
    @objc dynamic var deliverTable = ""
    
    var orderitems = List<OrderItem>()
}
