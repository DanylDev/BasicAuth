//
//  Networking.swift
//  Drink App
//
//  Created by Denis Yakovenko on 2/4/19.
//  Copyright © 2019 Denis Yakovenko. All rights reserved.
//

import Foundation
import Alamofire
import MobileCoreServices
import MapKit
import RealmSwift

class Networking : NSObject {
    
    var baseUrl = ""
    
    class var sharedInstance: Networking {
        struct Singleton {
            static let instance = Networking()
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        Singleton.instance.baseUrl = appDelegate.baseUrl
        return Singleton.instance
    }
    
    // MARK:- Users
    
    func userRegister(name: String, email: String, password: String,  completion:@escaping (_ success: Bool, _ error: String) -> Void) {
        let url = "\(baseUrl)api/v1/register"
        let parameters = ["name":name,
                          "email":email,
                          "password":password,
                          "password_confirmation":password] as [String : Any]
        Alamofire.request(url, method: .post, parameters: parameters)
            .responseJSON { response in
                if (response.response?.statusCode == 400) {
                    completion(false, "Please check the email address you entered.")
                }
                else {
                    if let JSON = response.result.value as? [String:Any] {
                        if JSON["result"] as? String == "success" {
                            
                            let token = JSON["token"] as! String
                            
                            let userDefaults = UserDefaults.standard
                            userDefaults.setValue(token, forKey: "token")
                            userDefaults.setValue(email, forKey: "email")
                            userDefaults.synchronize()
                            completion(true, "")
                        } else {
                            completion(false, JSON["message"] as? String ?? "")
                        }
                    }
                    else {
                        completion(false, "Please check the email address you entered.")
                    }
                }
        }

    }
    
    func userLogin(email: String, password: String,  completion:@escaping (_ success: Bool, _ error: String) -> Void) {
        let url = "\(baseUrl)api/v1/login"
        let parameters = ["email":email,
                          "password":password] as [String : Any]
        Alamofire.request(url, method: .post, parameters: parameters)
            .responseJSON { response in
                if (response.response?.statusCode == 401) {
                    completion(false, "Please check your email and password.")
                }
                else {
                    if let JSON = response.result.value as? [String:Any] {
                        if let token = JSON["token"] as? String {
                            let userDefaults = UserDefaults.standard
                            userDefaults.setValue(token, forKey: "token")
                            userDefaults.setValue(email, forKey: "email")
                            userDefaults.synchronize()
                            completion(true, "")
                        } else {
                            completion(false, "Please check your email and password.")
                        }
                    }
                    else {
                        completion(false, "Please check your email and password.")
                    }
                }
        }
    }
    
    func userResetPassword(email: String, completion:@escaping (_ success: Bool, _ error: String) -> Void) {
        let url = "\(baseUrl)api/v1/forgot-password"
        let parameters = ["email":email] as [String : Any]
        Alamofire.request(url, method: .post, parameters: parameters)
            .responseJSON { response in
                if (response.response?.statusCode == 401) {
                    completion(false, "Please check your email address.")
                }
                else {
                    if let JSON = response.result.value as? [String:Any] {
                        if ((JSON["result"] as! String) == "error") {
                            if let messages = JSON["messages"] as? NSArray {
                                if let errorFields = messages[0] as? [String:Any] {
                                    let emailError = errorFields["email"] as! NSArray
                                    completion(false, emailError[0] as! String)
                                    return
                                }
                            }
                            completion(false, "")
                        }
                        else {
                            completion(true, "")
                        }
                    }
                }
        }
    }

    func userOneSignal(playerId: String, completion:@escaping (_ success: Bool, _ error: String) -> Void) {
        let url = "\(baseUrl)api/v1/settings/onesignal"
        let parameters = ["player_id":playerId] as [String : Any]
        
        if (UserDefaults.standard.object(forKey: "token") == nil) {
            return
        }
        
        let token = UserDefaults.standard.value(forKey: "token") as! String
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Accept": "application/json"
        ]
        
        Alamofire.request(url, method: .post, parameters: parameters, headers: headers)
            .responseJSON { response in
                if (response.response?.statusCode == 401) {
                    completion(false, "Please logout and try again.")
                }
                else {
                    completion(true, "")
                }
        }
    }
    
    // MARK:- Orders
    func listOrders(completion:@escaping (_ success: Bool, _ error: String) -> Void) {
        
        let realm = try! Realm()
        
        let url = "\(baseUrl)api/v1/order"
        let token = UserDefaults.standard.value(forKey: "token") as! String
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Accept": "application/json"
        ]
        
        var email = ""
        if let _ = UserDefaults.standard.value(forKey: "token") as? String {
            email = UserDefaults.standard.value(forKey: "email") as! String
        }
        
        Alamofire.request(url, method: .get, parameters: [:], headers: headers)
            .responseJSON { response in
                
                if (response.response?.statusCode == 401) {
                    completion(false, "")
                }
                else {
                    if let JSON = response.result.value as? [String:Any] {
                        if let orders = JSON["data"] as? [[String:Any]] {
                            
                            // delete all local orders (which AREN'T isCurrent)
                            try! realm.write {
                                print("deleting noncurrent orders")
                                realm.delete(realm.objects(Order.self).filter("isCurrent == NO && email == %@", email))
                            }

                            let df = DateFormatter()
                            df.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            
                            for order in orders {
                                
                                print("order: \(order)")
                                
                                let dateString = order["created_at"]! as! String
                                let date = df.date(from: dateString)
                                
                                let orderToSave = Order()
                                orderToSave.orderId = order["id"]! as! Int
                                orderToSave.orderNumber = order["id"]! as! Int // TODO: should be actual order number
                                orderToSave.email = email
                                
                                if let _ = order["grandtotal_price"] as? NSString {
                                    orderToSave.overallTotal = (order["grandtotal_price"] as! NSString).doubleValue
                                }
                                if let _ = order["total_price"] as? NSString {
                                    orderToSave.totalCost = (order["total_price"] as! NSString).doubleValue
                                }
                                if let _ = order["total_fee"] as? NSString {
                                    orderToSave.totalFee = (order["total_fee"] as! NSString).doubleValue
                                }
                                if let _ = order["is_delivery"] as? Bool {
                                    orderToSave.isDeliver = order["is_delivery"] as! Bool
                                }
                                if let _ = order["table_number"] as? Int {
                                    orderToSave.deliverTable = "\(order["table_number"] as! Int)"
                                }

                                orderToSave.isCurrent = false
                                orderToSave.dateTime = date!
                                
                                if let orderItems = order["order_items"] as? [[String:Any]] {
                                    let orderItemsToSave:List<OrderItem> = List()
                                    for orderItem in orderItems {
                                        
                                        let orderItemToSave = OrderItem()
                                        
                                        if let item = orderItem["item"] as? [String:Any] {
                                            let itemId = item["id"] as! Int
                                            var itemToSave = realm.objects(Item.self).filter("itemId == %@", itemId).first
                                            
                                            // if item not found, add it.
                                            if itemToSave == nil {
                                                
                                                let price = Double(item["price"] as! String)!
                                                let newItem = Item()
                                                newItem.itemId = item["id"] as! Int
                                                newItem.categoryId = item["category_id"] as! Int
                                                newItem.name = item["name"] as! String
                                                newItem.itemPrice = price
                                                var description = ""
                                                if let descriptionValue = item["description"] as? String {
                                                    description = descriptionValue
                                                }
                                                newItem.itemDescription = description
                                                
                                                try! realm.write {
                                                    realm.add(newItem)
                                                }
                                                itemToSave = newItem
                                            }
                                            
                                            try! realm.write {
                                                orderItemToSave.itemId = (itemToSave?.itemId)!
                                            }
                                        }
                                        
                                        try! realm.write {
                                            orderItemToSave.quantity = orderItem["quantity"] as! Int
                                            orderItemToSave.orderId = order["id"] as! Int
                                            
                                            orderItemsToSave.append(orderItemToSave)
                                        }
                                    }
                                    
                                    orderToSave.orderitems = orderItemsToSave
                                }
                                
                                let orderStatusId = order["status"]! as! Int
                                switch orderStatusId {
                                    case 0:
                                        orderToSave.status = .pending
                                        break;
                                    case 1:
                                        orderToSave.status = .failed
                                        break;
                                    case 2:
                                        orderToSave.status = .readyForCollection
                                        break;
                                    case 3:
                                        orderToSave.status = .readyForDelivery
                                        break;
                                    case 4:
                                        orderToSave.status = .completed
                                        break;
                                    default:
                                        orderToSave.status = .pending
                                        break;
                                }
                                
                                let dictLocation = order["location"] as! [String:Any]
                                let location = self.addLocation(dictLocation: dictLocation)
                                
                                try! realm.write {
                                    orderToSave.location = location
                                    print("location: \(orderToSave.location)")
                                    realm.add(orderToSave)
                                }
                            }
                        }
                    }
                    completion(true, "")
                }
        }
    }
    
    
    func submitOrder(order:Order, location:Location, completion:@escaping (_ success: Bool, _ error: String) -> Void) {
        
        let realm = try! Realm()
        
        let url = "\(baseUrl)api/v1/order"
        let token = UserDefaults.standard.value(forKey: "token") as! String

        var items:[[String:Int]] = []
        for orderItem in order.orderitems {
            var item:[String:Int] = [:]
            item["id"] = orderItem.itemId
            item["quantity"] = orderItem.quantity
            items.append(item)
        }
        
        let parameters:NSMutableDictionary? = [
            "stripe_token" : "",
            "location_id" : location.locationId,
            "description" : "",
            "is_delivery": order.isDeliver,
            "table_number": order.deliverTable,
            "grandtotal_price": order.overallTotal,
            "total_price": order.totalCost,
            "total_fee": order.totalFee,
            "items": items
        ]
        
        var request = URLRequest(url: NSURL(string:url as String)! as URL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let data = try! JSONSerialization.data(withJSONObject: parameters!, options: JSONSerialization.WritingOptions.prettyPrinted)
        let json = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        if let json = json {
            print(json)
        }
        request.httpBody = json!.data(using: String.Encoding.utf8.rawValue);
        
        Alamofire.request(request as! URLRequestConvertible)
            .responseJSON { response in
                if (response.response?.statusCode == 200) {
                    
                    if let JSON = response.result.value as? [String:Any] {
                        if let data = JSON["data"] as? [String:Any] {
                            let orderId = data["id"] as! Int
                            try! realm.write {
                                order.orderId = orderId
                                order.orderNumber = orderId // TODO: should be the ticket code/id
                                order.isCurrent = false
                            }
                            completion(true, "")
                        }
                    }
                    else {
                        completion(false, "Error submitting the order. Please try again.")
                    }
                    
                }
                else {
                    completion(false, "Error submitting the order. Please try again.")
                }
        }
    }
    
    // MARK:- Payment Methods
    func listPaymentMethods(completion:@escaping (_ success: Bool, _ error: String) -> Void) {
        
        let realm = try! Realm()
        
        let url = "\(baseUrl)api/v1/payment-method"
        let token = UserDefaults.standard.value(forKey: "token") as! String
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Accept": "application/json"
        ]
        
        Alamofire.request(url, method: .get, parameters: [:], headers: headers)
            .responseJSON { response in
                
                if (response.response?.statusCode == 401) {
                    completion(false, "")
                }
                else {
                    if let JSON = response.result.value as? [String:Any] {
                        if let cards = JSON["cards"] as? [[String:Any]] {
                            for card in cards {
                                let paymentMethod = PaymentMethod()
                                paymentMethod.name = "\(card["brand"] as! String) Ending in \(card["last4"] as! String)"
                                paymentMethod.id = card["id"] as! String

                                // get existing card
                                let cardCurrent = realm.objects(PaymentMethod.self).filter("id == '\(paymentMethod.id)'").first
                                if cardCurrent == nil {
                                    try! realm.write {
                                        realm.add(paymentMethod)
                                    }
                                }
                            }
                        }
                    }
                    completion(true, "")
                }
        }
    }
    
    func addPaymentMethod(cardToken:String, completion:@escaping (_ success: Bool, _ error: String) -> Void) {
        
        let url = "\(baseUrl)api/v1/payment-method"
        let token = UserDefaults.standard.value(forKey: "token") as! String
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Accept": "application/json"
        ]
        
        let parameters = ["token":cardToken]
        Alamofire.request(url, method: .post, parameters: parameters, headers: headers)
            .responseJSON { response in
                if (response.response?.statusCode == 401) {
                    completion(false, "")
                }
                else {
                    completion(true, "")
                }
        }
    }

    func deletePaymentMethod(cardId:String, completion:@escaping (_ success: Bool, _ error: String) -> Void) {
        
        let url = "\(baseUrl)api/v1/payment-method/\(cardId)"
        let token = UserDefaults.standard.value(forKey: "token") as! String
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Accept": "application/json"
        ]
    
        Alamofire.request(url, method: .delete, headers: headers)
            .responseJSON { response in
                if (response.response?.statusCode == 401) {
                    completion(false, "")
                }
                else {
                    completion(true, "")
                }
        }
    }

    
///api/v1/payment-method/{id}
    
}

// MARK:- Locations
extension Networking {
    
    func location(id: Int,  completion:@escaping (_ success: Bool, _ error: String) -> Void) {
        
        let realm = try! Realm()
        
        let items = realm.objects(Item.self)
        print("all items in db: \(items)")
        
        // headers with token + json
        let url = "\(baseUrl)api/v1/location/\(id)/categories"
        
        var headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        if let token = UserDefaults.standard.value(forKey: "token") as? String {
            headers = [
                "Authorization": "Bearer \(token)",
                "Accept": "application/json"
            ]
        }
                
        Alamofire.request(url, method: .get, parameters: [:], headers: headers)
            .responseJSON { response in
                if (response.response?.statusCode == 401) {
                    completion(false, "")
                }
                else {
                    
                    let locationCategories = realm.objects(Category.self).filter("locationId == \(id)")
                    let locationItems = realm.objects(Item.self).filter("locationId == \(id)")
                    
                    // delete all items and categories
                    try! realm.write {
                        print("deleting categories + items in network api")
                        realm.delete(locationCategories)
                        realm.delete(locationItems)
                    }

                    if let JSON = response.result.value as? [String:Any] {
                        if let categories = JSON["data"] as? [[String:Any]] {
                            
                            for category in categories {
                                let categoryId = Int(category["id"] as! Int)
                                let name = category["name"] as! String
                                var description = ""
                                if let descriptionValue = category["description"] as? String {
                                    description = descriptionValue
                                }
                                let categoryObject = Category(value:[
                                    "categoryId":categoryId,
                                    "locationId":id,
                                    "name":name,
                                    "description":description,
                                ])
                                try! realm.write {
                                    realm.add(categoryObject)
                                }
                                
                                // get items in category
                                if let itemSingle = category["items"] as? NSDictionary {
                                    let item = itemSingle["1"]! as! NSDictionary
                                    let itemId = Int(item["id"] as! Int)
                                    let userId = Int(item["user_id"] as! Int)
                                    let categoryId = Int(item["category_id"] as! Int)
                                    let name = item["name"] as! String
                                    var description = ""
                                    if let descriptionValue = item["description"] as? String {
                                        description = descriptionValue
                                    }
                                    let price = Double(item["price"] as! String)!
                                    let images = item["images"] as! [[String:Any]]
                                    var imageUrl = ""
                                    if images.count > 0 {
                                        let image = images[0]
                                        imageUrl = image["url"] as! String
                                    }

                                    let itemObject = Item(value:[
                                        "itemId":itemId,
                                        "userId":userId,
                                        "categoryId":categoryId,
                                        "locationId":id,
                                        "name":name,
                                        "itemDescription":description,
                                        "itemPrice":price,
                                        "imageUrl":imageUrl,
                                    ])
                                    
                                    try! realm.write {
                                        realm.add(itemObject)
                                    }
                                }
                                else if let items = category["items"] as? [[String:Any]] {
                                    for item in items {
                                        let itemId = Int(item["id"] as! Int)
                                        let userId = Int(item["user_id"] as! Int)
                                        let categoryId = Int(item["category_id"] as! Int)
                                        let name = item["name"] as! String
                                        var description = ""
                                        if let descriptionValue = item["description"] as? String {
                                            description = descriptionValue
                                        }
                                        let price = Double(item["price"] as! String)!
                                        let images = item["images"] as! [[String:Any]]
                                        var imageUrl = ""
                                        if images.count > 0 {
                                            let image = images[0]
                                            imageUrl = image["url"] as! String
                                        }
                                        let itemObject = Item(value:[
                                            "itemId":itemId,
                                            "userId":userId,
                                            "locationId":id,
                                            "categoryId":categoryId,
                                            "name":name,
                                            "itemDescription":description,
                                            "itemPrice":price,
                                            "imageUrl":imageUrl,
                                            ])
                                        
                                        try! realm.write {
                                            realm.add(itemObject)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // remove all categories where there are no items
//                        let categoriesAll = realm.objects(Category.self).filter("locationId == \(id)")
//                        for category in categoriesAll {
//                            let items = Database.sharedInstance.getItemsInCategory(category: category)
//                            if (items!.count == 0) {
//                                try! realm.write {
//                                    realm.delete(category)
//                                }
//                            }
//                        }
                        
                        completion(true, "")
                    }
                }
        }
    }
    
    func locationClosest(location: CLLocationCoordinate2D,  completion:@escaping (_ success: Bool, _ error: String) -> Void) {
        
        let realm = try! Realm()

        // headers with token + json
        let url = "\(baseUrl)api/v1/location/closest"
        var headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        if let token = UserDefaults.standard.value(forKey: "token") as? String {
            headers = [
                "Authorization": "Bearer \(token)",
                "Accept": "application/json"
            ]
        }

        let parameters = ["latitude":location.latitude,
                          "longitude":location.longitude] as [String : Any]
        Alamofire.request(url, method: .get, parameters: parameters, headers: headers)
            .responseJSON { response in
                if (response.response?.statusCode == 401) {
                    completion(false, "")
                }
                else {
                    
//                    try! realm.write {
//                        print("deleting locations in location network api")
//                        realm.delete(realm.objects(Location.self))
//                    }
                    
                    if let JSON = response.result.value as? [String:Any] {
                        if let data = JSON["data"] as? [[String:Any]] {
                            
                            for dictLocation in data {
                                _ = self.addLocation(dictLocation: dictLocation)
                            }
                            
                            completion(true, "")
                        }
                    }
                    else {
                        completion(false, "")
                    }
                }
        }
    }
    
    func addLocation(dictLocation:[String:Any]) -> Location {

        let locationId = dictLocation["id"] as! Int
        
        // see if it exists
        let realm = try! Realm()
        let locationExisting = realm.objects(Location.self).filter("locationId == %d", locationId).first
        
        // if so do nothing
        if (locationExisting != nil) {
            return locationExisting!
        }
        
        // add it again
        var phone = ""
        var country = ""
        var state = ""
        var city = ""
        var address = ""
        var description = ""
        
        if let phoneValue = dictLocation["phone"] as? String { phone = phoneValue }
        if let countryValue = dictLocation["country"] as? String { country = countryValue }
        if let stateValue = dictLocation["state"] as? String { state = stateValue }
        if let cityValue = dictLocation["city"] as? String { city = cityValue }
        if let addressValue = dictLocation["address"] as? String { address = addressValue }
        if let descriptionValue = dictLocation["description"] as? String { description = descriptionValue }
        
        let location = Location(value:[
            "locationId":dictLocation["id"] as! Int,
            "userId":dictLocation["user_id"] as! Int,
            "name":dictLocation["name"],
            "locationDescription":description,
            "phone":phone,
            "country":country,
            "state":state,
            "city":city,
            "address":address,
            "latitude": dictLocation["latitude"],
            "longitude": dictLocation["longitude"]
            ])
        try! realm.write {
            realm.add(location)
        }

        return location
    }
}
