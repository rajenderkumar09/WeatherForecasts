//
//  WeatherServiceProtocol.swift
//  WeatherForecast
//
//  Created by Rajender Sharma on 28/01/20.
//  Copyright © 2020 Rajender Sharma. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherServiceProtocol {
	func fetchWeatherInfo(_ location: CLLocation, completionHandler: @escaping (Weather?, NSError?)->Void)
	func fetchWeather(for cityIds:String, handler: @escaping ([Weather]?, NSError?)->Void)
}
