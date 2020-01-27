//
//  UIFont+Extension.swift
//  WeatherForecast
//
//  Created by Rajender Sharma on 25/01/20.
//  Copyright © 2020 Rajender Sharma. All rights reserved.
//


import Foundation
import UIKit


extension UIFont {
    static func defaultFont(with weight: UIFont.Weight, size: CGFloat) -> UIFont {
		UIFont.systemFont(ofSize: size, weight: weight)
    }
}
