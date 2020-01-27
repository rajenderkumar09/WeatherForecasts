//
//  WeatherForecastTests.swift
//  WeatherForecastTests
//
//  Created by Rajender Sharma on 25/01/20.
//  Copyright © 2020 Rajender Sharma. All rights reserved.
//

import XCTest
@testable import WeatherForecast

class WeatherForecastTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

	func testWeatherModel() {
//		let city = ["name":"Chandigarh", "country":"IN"]
//		let weather = [["description" : "few clouds", "icon" : "02n","id": 801]]
//		let json = ["dt" : "1580515200", "city": city, "weather" : weather] as [String : Any]
//
//		let weather = Weather(json:json as JSON)
//		let weatherIcon = WeatherIcon(condition: 801, iconString: "02n")
//
//		//Test
//		XCTAssertEqual(weather.city, "Chandigarh")
//		XCTAssertEqual(weather.description, "few clouds")
//		XCTAssertEqual(weather.iconText, weatherIcon.iconText)
//		XCTAssertEqual(weather.temperature, "Chandigarh")
//		XCTAssertEqual(weather.city, "Chandigarh")

	}

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
