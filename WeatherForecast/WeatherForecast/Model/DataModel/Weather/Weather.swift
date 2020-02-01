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

	//Group weather information date wise
	func groupedByDate() -> [Date: [Forecast]] {
		let empty: [Date: [Forecast]] = [:]
		return self.forecasts.reduce(into: empty) { acc, cur in
			let existing = acc[cur.date] ?? []
			acc[cur.date] = existing + [cur]
		}
	}

	lazy var section:[Date] = {
		let grouped = self.groupedByDate()
		let keys = Array (grouped.keys)
		return keys.sorted()
	}()
}
