//
//  Date.swift
//  Drink App
//
//  Created by Andrew Dunn on 11/03/2019.
//  Copyright © 2019 Denis Yakovenko. All rights reserved.
//

import Foundation

extension Date {
    
    func asShortDate() -> String {
        
        let df = DateFormatter()
        df.dateFormat = "dd.MM.yyyy"
        
        return df.string(from: self)
    }
    
    func asShortDateTime() -> String {
        
        let df = DateFormatter()
        df.dateFormat = "dd.MM.yyyy / HH:mm"
        
        return df.string(from: self)
    }
}
