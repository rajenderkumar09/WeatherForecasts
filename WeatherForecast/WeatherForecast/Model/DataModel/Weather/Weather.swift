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
	var iconText: String = ""
	var temperature: String = ""
	var description: String = ""
	var datetime: String = ""
	var forecasts: [Forecast] = []

	init(json:JSON) {
		// Get temperature, location and icon and check parsing error
		guard let city = json["city"] as? JSON, let list = json["list"] as? [JSON], let first = list.first, let main = first["main"] as? JSON, let weatherInfo = first["weather"] as? [JSON], let firstWeather = weatherInfo.first,
			let dateTime = first["dt"] as? Double
		else {
			return
		}

		guard let tempDegrees = main["temp"] as? Double,
			let country = city["country"] as? String,
			let name = city["name"] as? String,
			let weatherCondition = firstWeather["id"] as? Int,
			let iconString = firstWeather["icon"] as? String,
			let description = firstWeather["description"] as? String
			else {
				return
		}

		let temperature = Temperature(country: country, openWeatherMapDegrees:tempDegrees)
		self.temperature = temperature.degrees
		self.city = name
		self.description = description

		let datetimeString = ForecastDateTime(date: dateTime, timeZone: TimeZone.current).dateTime
		self.datetime = datetimeString

		let weatherIcon = WeatherIcon(condition: weatherCondition, iconString: iconString)
		self.iconText = weatherIcon.iconText

		let forecasts = self.getForecasts(country: country, list: list)
		self.forecasts = forecasts
	}

	func getForecasts(country: String, list: [JSON]) -> [Forecast] {
        var forecasts: [Forecast] = []

        for item in list {

			guard let main = item["main"] as? JSON, let weatherInfo = item["weather"] as? [JSON], let firstWeather = weatherInfo.first, let wind = item["wind"] as? JSON else {
				return []
			}

			guard let temperature = main["temp"] as? Double,
				let rawDateTime = item["dt"] as? Double,
				let forecastCondition = firstWeather["id"] as? Int,
				let forecastIcon = firstWeather["icon"] as? String,
				let description = firstWeather["description"] as? String,
				let windSpeed = wind["speed"] as? NSNumber,
				let tempMin = main["temp_min"] as? Double,
				let tempMax = main["temp_max"] as? Double
				else {
					return []
			}

            let forecastTimeString = ForecastDateTime(date: rawDateTime, timeZone: TimeZone.current).dateTime
            let weatherIcon = WeatherIcon(condition: forecastCondition, iconString: forecastIcon)
            let forcastIconText = weatherIcon.iconText
			let forecastTemperature = Temperature(country: country, openWeatherMapDegrees: temperature)
			let min = Temperature(country: country, openWeatherMapDegrees: tempMin)
			let max = Temperature(country: country, openWeatherMapDegrees: tempMax)

            let forecast = Forecast(time: forecastTimeString,
                                    iconText: forcastIconText,
                                    temperature: forecastTemperature.degrees,
									description: description,
									windSpeed: windSpeed.stringValue,
									temperatureMin: min.degrees,
									temperatureMax: max .degrees)

            forecasts.append(forecast)
        }

        return forecasts
    }

}
