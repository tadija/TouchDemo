//
//  AEColor.swift
//  TouchDemo
//
//  Created by Marko Tadic on 9/12/14.
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

import UIKit
import CoreGraphics

extension UIColor {
    
    // MARK: - HEX Color
    
    convenience init (var hex: String) {
        var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 1.0
        
        if (hex.hasPrefix("#")) {
            hex = hex.substringFromIndex(advance(hex.startIndex, 1))
        }
        
        let scanner = NSScanner(string: hex)
        var hexValue: UInt32 = 0
        if scanner.scanHexInt(&hexValue) {
            if count(hex) == 8 {
                red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                blue  = CGFloat((hexValue & 0x0000FF00) >> 8) / 255.0
                alpha = CGFloat((hexValue & 0x000000FF)) / 255.0
            } else if count(hex) == 6 {
                red   = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
                green = CGFloat((hexValue & 0x00FF00) >> 8) / 255.0
                blue  = CGFloat((hexValue & 0x0000FF)) / 255.0
            }
        }
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    // MARK: - Random Color
    
    class func randomColor() -> UIColor! {
        let hue = CGFloat(arc4random() % 256) / 256.0;   //  0.0 to 1.0
        let saturation = CGFloat(arc4random() % 256) / 256.0;  //  0.0 to 1.0
        let brightness = CGFloat(arc4random() % 256) / 256.0;  //  0.0 to 1.0
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
    
    class func randomVividColor() -> UIColor! {
        let hue = CGFloat(arc4random() % 256) / 256.0;   //  0.0 to 1.0
        let saturation = (CGFloat(arc4random() % 128) / 256.0) + 0.5;  //  0.5 to 1.0, away from white
        let brightness = (CGFloat(arc4random() % 128) / 256.0) + 0.5;  //  0.5 to 1.0, away from white
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
    
    // MARK: - Color Shades
    
    func lighterColorWithFactor(factor: CGFloat = 0.5) -> UIColor! {
        let colorSpaceModel = CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor))
        var lighterColor = UIColor.whiteColor()
        
        var hue: CGFloat = 0.0, saturation: CGFloat = 0.0, brightness: CGFloat = 0.0, alpha: CGFloat = 0.0, white: CGFloat = 0.0
        
        switch colorSpaceModel.value {
        case kCGColorSpaceModelRGB.value:
            if self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
                saturation -= saturation * factor;
                brightness += (1.0 - brightness) * factor;
                lighterColor = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
            }
        case kCGColorSpaceModelMonochrome.value:
            if self.getWhite(&white, alpha: &alpha) {
                white += factor;
                white = (white > 1.0) ? 1.0 : white; // set max white
                lighterColor = UIColor(white: white, alpha: alpha)
            }
        default:
            println("CGColorSpaceModel: \(colorSpaceModel) is not implemented")
        }
        
        return lighterColor
    }
    
    func darkerColorWithFactor(factor: CGFloat = 0.5) -> UIColor! {
        let colorSpaceModel = CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor))
        var darkerColor = UIColor.whiteColor()
        
        var hue: CGFloat = 0.0, saturation: CGFloat = 0.0, brightness: CGFloat = 0.0, alpha: CGFloat = 0.0, white: CGFloat = 0.0
        
        switch colorSpaceModel.value {
        case kCGColorSpaceModelRGB.value:
            if self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
                brightness -= brightness * factor;
                saturation += (1.0 - saturation) * factor;
                darkerColor = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
            }
        case kCGColorSpaceModelMonochrome.value:
            if self.getWhite(&white, alpha: &alpha) {
                white -= factor;
                white = (white < 0.0) ? 0.0 : white; // set min white
                darkerColor = UIColor(white: white, alpha: alpha)
            }
        default:
            println("CGColorSpaceModel: \(colorSpaceModel) is not implemented")
        }
        
        return darkerColor
    }
    
}
