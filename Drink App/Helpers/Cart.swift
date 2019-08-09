//
//  Cart.swift
//  Drink App
//
//  Created by Andrew Dunn on 26/02/2019.
//  Copyright © 2019 Denis Yakovenko. All rights reserved.
//

import Foundation
import RealmSwift

class Cart : NSObject {
    
    var baseUrl = ""
    
    class var sharedInstance: Cart {
        struct Singleton {
            static let instance = Cart()
        }
        return Singleton.instance
    }
    
    func listAllOrders() -> Results<Order> {
        let realm = try! Realm()
        var email = ""
        if let _ = UserDefaults.standard.value(forKey: "token") as? String {
            email = UserDefaults.standard.value(forKey: "email") as! String
        }
        return realm.objects(Order.self).filter("email == %@ && isCurrent == NO", email)
    }

    func setCurrentLocation(_ location:Location) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(location.locationId, forKey: "currentLocation")
        userDefaults.synchronize()
    }
        
    func currentLocation() -> Location? {
        
        let userDefaults = UserDefaults.standard
        if userDefaults.object(forKey: "currentLocation") != nil {
            
            let locationId = userDefaults.object(forKey: "currentLocation") as! Int
            let realm = try! Realm()
            let location = realm.objects(Location.self).filter("locationId == %@", locationId).first            
            return location
        }
        else {
            return nil
        }
    }
    
    // get current order
    func currentOrder() -> Order {
        
        let realm = try! Realm()
        
        // get users current email address
        var email = ""
        if let _ = UserDefaults.standard.value(forKey: "token") as? String {
            email = UserDefaults.standard.value(forKey: "email") as! String
        }
        
        // get current order
        var order = realm.objects(Order.self).filter("isCurrent == YES && email == %@ && locationId == %@", email, self.currentLocation()!.locationId).first
        if ((order) == nil) {
            order = Order()
            order!.email = email
            order!.dateTime = Date()
            order!.totalCost = 0.0
            order!.totalFee = 0.0
            order!.isCurrent = true
            order!.locationId = self.currentLocation()!.locationId
            order!.location = self.currentLocation()!
            try! realm.write {
                realm.add(order!)
            }
        }
        return order!
    }
    
    // add item to order
    func addItemToOrder(item:Item) {
        
        let realm = try! Realm()
        let order = self.currentOrder()
        
        let orderItem = OrderItem()
        orderItem.itemId = item.itemId
        orderItem.quantity = 1
        
        try! realm.write {
            order.orderitems.append(orderItem)
        }
        
        self.recalculateOrder()
        
        print("items: \(String(describing: order.orderitems))")
    }

    // add item to order
    func removeItemFromOrder(itemId:Int) {
        
        let realm = try! Realm()
        let order = self.currentOrder()
        
        var count = 0; var indexToRemove = -1
        for orderItem in order.orderitems {
            if (itemId == orderItem.itemId) {
                indexToRemove = count
            }
            count = count + 1
        }
        
        try! realm.write {
            order.orderitems.remove(at: indexToRemove)
        }
        
        self.recalculateOrder()

        print("items: \(String(describing: order.orderitems))")
    }
    
    func recalculateOrder() {
        
        let realm = try! Realm()
        let order = self.currentOrder()

        // get all items
        var totalCost = 0.0
        for orderItem in order.orderitems {
            let item = Database.sharedInstance.getItemById(itemId: orderItem.itemId)
            let cost = (item!.itemPrice) * Double(orderItem.quantity)
            totalCost = totalCost + cost
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        try! realm.write {
            order.totalCost = totalCost
            order.totalFee = round((totalCost * Double(appDelegate.transactionFee)/Double(100)) * 100) / 100
            order.overallTotal = order.totalCost + order.totalFee
        }
    }
    
    // see if the menu item is part of the current order
    func isCurrentOrderItem(item:Item) -> Int {
        
        let order = self.currentOrder()
        for orderItem in order.orderitems {
            if (item.itemId == orderItem.itemId) {
                return orderItem.quantity
            }
        }
        
        return 0
    }
    
    // calculate single order row value
    func orderItemTotalCost(_ item:Item, _ quantity:Double) -> Double {
        
        let cost = item.itemPrice
        return quantity * cost
    }

    func currentOrderItemTotalCost(_ index:Int) -> Double {
        
        var count = 0
        let order = self.currentOrder()
        for orderItem in order.orderitems {
            if (count == index) {
                let quantity = Double(orderItem.quantity)
                let item = Database.sharedInstance.getItemById(itemId: orderItem.itemId)
                let cost = item!.itemPrice
                return quantity * cost
            }
            count = count + 1
        }
        return 0
    }

    // update quantity
    func updateQuantity(_ index:Int, _ quantity: Int) {
        
        let realm = try! Realm()
        var count = 0
        let order = self.currentOrder()
        for orderItem in order.orderitems {
            if (count == index) {
                try! realm.write {
                    orderItem.quantity = quantity
                }
            }
            count = count + 1
        }
        return
    }
}
