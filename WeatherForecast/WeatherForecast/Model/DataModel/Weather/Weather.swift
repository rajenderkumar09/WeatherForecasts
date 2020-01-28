//
//  ViewController.swift
//  WeatherForecast
//
//  Created by Rajender Sharma on 25/01/20.
//  Copyright © 2020 Rajender Sharma. All rights reserved.
//

import Foundation

typealias JSON = [String:AnyObject]

struct Weather {
	var city: String = ""
	var forecasts: [Forecast] = []
}
