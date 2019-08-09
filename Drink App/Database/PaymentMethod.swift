//
//  PaymentMethod.swift
//  Drink App
//
//  Created by Andrew Dunn on 05/03/2019.
//  Copyright © 2019 Denis Yakovenko. All rights reserved.
//

import Foundation
import RealmSwift

class PaymentMethod: Object {
    @objc dynamic var id:String = ""
    @objc dynamic var name:String = ""
    @objc dynamic var colour:String = ""
    @objc dynamic var defaultCard:Bool = false
}
