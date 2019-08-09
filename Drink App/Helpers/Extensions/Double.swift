//
//  Double.swift
//  Drink App
//
//  Created by Andrew Dunn on 27/02/2019.
//  Copyright © 2019 Denis Yakovenko. All rights reserved.
//

import Foundation

extension Double {
    func asCurrency() -> String {
        return String(format: "€%.02f", self)
    }
}
