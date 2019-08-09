//
//  Color.swift
//  Drink App
//
//  Created by Denis Yakovenko on 2/1/19.
//  Copyright © 2019 Denis Yakovenko. All rights reserved.
//

import Foundation
import UIKit

let main_color:UIColor = UIColor(red:245.0/255.0, green:14/255.0, blue:91/255.0, alpha:1)

let field_border_color:UIColor = UIColor(red:83.0/255.0, green:74.0/255.0, blue:107.0/255.0, alpha:1)

extension UIColor {
    
    static func orderPending() -> UIColor {
        return UIColor(hex:"F50E5B")
    }

    static func orderReady() -> UIColor {
        return UIColor(hex:"FCB549")
    }

    static func orderComplete() -> UIColor {
        return UIColor(hex:"3BD39C")
    }

    convenience init(hex: String) {
        self.init(hex: hex, alpha:1)
    }
    
    convenience init(hex: String, alpha: CGFloat) {
        var hexWithoutSymbol = hex
        if hexWithoutSymbol.hasPrefix("#") {
            hexWithoutSymbol = hex.substring(1)
        }
        
        let scanner = Scanner(string: hexWithoutSymbol)
        var hexInt:UInt32 = 0x0
        scanner.scanHexInt32(&hexInt)
        
        var r:UInt32! = 255, g:UInt32! = 255, b:UInt32! = 255
        switch (hexWithoutSymbol.length) {
        case 3: // #RGB
            r = ((hexInt >> 4) & 0xf0 | (hexInt >> 8) & 0x0f)
            g = ((hexInt >> 0) & 0xf0 | (hexInt >> 4) & 0x0f)
            b = ((hexInt << 4) & 0xf0 | hexInt & 0x0f)
            break;
        case 6: // #RRGGBB
            r = (hexInt >> 16) & 0xff
            g = (hexInt >> 8) & 0xff
            b = hexInt & 0xff
            break;
        default:
            // TODO:ERROR
            break;
        }
        
        self.init(
            red: (CGFloat(r)/255),
            green: (CGFloat(g)/255),
            blue: (CGFloat(b)/255),
            alpha:alpha)
    }
    
    static func randomColorFloat() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
    
    static func random() -> UIColor {
        return UIColor(red:   randomColorFloat(),
                       green: randomColorFloat(),
                       blue:  randomColorFloat(),
                       alpha: 1.0)
    }
}
