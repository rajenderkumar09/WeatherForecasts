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
		//Given
		let city = ["name":"Chandigarh", "country":"IN"]
		let weatherInfo = ["description" : "few clouds", "icon" : "02n","id": 801] as [String : Any]
		let list = ["dt" : 1580515200, "main": ["temp":287.53, "temp_min":287.53, "temp_max":287.53], "weather" : [weatherInfo]] as [String : Any]
		let json = ["city": city, "list":[list]] as [String : Any]

		let weather = Weather(json:json as JSON)
		let weatherIcon = WeatherIcon(condition: 801, iconString: "02n")
		let temperature = Temperature(country: "IN", openWeatherMapDegrees:287.53)

		//Test
		XCTAssertEqual(weather.city, "Chandigarh")
		XCTAssertEqual(weather.description, "few clouds")
		XCTAssertEqual(weather.iconText, weatherIcon.iconText)
		XCTAssertEqual(weather.temperature, temperature.degrees)
	}

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
