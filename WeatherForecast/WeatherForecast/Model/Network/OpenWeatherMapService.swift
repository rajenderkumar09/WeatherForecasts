//
//  OpenWeatherMapService.swift
//  WeatherForecast
//
//  Created by Rajender Sharma on 28/01/20.
//  Copyright © 2020 Rajender Sharma. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire
import AFDateHelper



struct OpenWeatherMapService: WeatherServiceProtocol {

	func fetchWeatherInfo(_ location: CLLocation, completionHandler: @escaping (Weather?, NSError?)->Void) {

		let apiPath = API.host + "2.5/forecast"
		let parameters = ["appid":API.key, "lat":location.coordinate.latitude, "lon":location.coordinate.longitude] as [String : Any]
		Alamofire.request(apiPath, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { response in

			guard let error = response.error else {
				guard let json = response.result.value as? JSON else {
					let error = NSError(domain: "Unauthorized", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid Json"])
					completionHandler(nil, error)
					return
				}

				//Parse Json
				guard let city = json["city"] as? JSON, let name = city["name"] as? String, let country = city["country"] as? String, let list = json["list"] as? [JSON] else {
					let error = NSError(domain: "Unauthorized", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid Json"])
					completionHandler(nil, error)
					return
				}

				let forecasts = self.getForecasts(country: country, list: list)
				//Set Weather Model Object
				let weather = Weather(city:name, forecasts:forecasts)
				completionHandler(weather, nil)
				return
			}
			completionHandler(nil, error as NSError)
		}
	}

	func fetchWeather(for cityIds:String, handler: @escaping ([Weather]?, NSError?)->Void) {
		let apiPath = API.host + "2.5/group"
		let parameters = ["appid":API.key, "id":cityIds]
		Alamofire.request(apiPath, method: .get, parameters: parameters as Parameters, encoding: URLEncoding.default, headers: nil).responseJSON { response in

			guard let error = response.error else {
                guard let json = response.result.value as? JSON else {
					let error = NSError(domain: "Unauthorized", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid Json"])
					handler(nil, error)
                    return
                }

				guard let code = json["cod"] as? NSNumber, code.intValue != 200 else {
					guard let list = json["list"] as? [JSON] else {
						let error = NSError(domain: "Unauthorized", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid Json"])
						handler(nil, error)
						return
					}
					var weathers:[Weather] = []
					for item in list {
						//Parse Json
						 guard let name = item["name"] as? String,
							let rawDateTime = item["dt"] as? Double,
							let sys = item["sys"] as? JSON,
							let main = item["main"] as? JSON,
							let weatherInfo = item["weather"] as? [JSON],
							let firstWeather = weatherInfo.first,
							let wind = item["wind"] as? JSON else {
								let error = NSError(domain: "Unauthorized", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid Json"])
								handler(nil, error)
								return
						 }

						 guard let temperature = main["temp"] as? Double,
						 let tempMax = main["temp_max"] as? Double,
						 let tempMin = main["temp_min"] as? Double,
						 let country = sys["country"] as? String,
						 let forecastCondition = firstWeather["id"] as? Int,
						 let forecastIcon = firstWeather["icon"] as? String,
						 let description = firstWeather["description"] as? String,
						 let windSpeed = wind["speed"] as? NSNumber else {
							let error = NSError(domain: "Unauthorized", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid Json"])
							handler(nil, error)
							return
						 }

						let forecastTimeString = ForecastDateTime(date: rawDateTime).dateTimeString
						let forecastDate = ForecastDateTime(date: rawDateTime).date

						let weatherIcon = WeatherIcon(condition: forecastCondition, iconString: forecastIcon)
						let forcastIconText = weatherIcon.iconText
						let forecastTemperature = Temperature(country: country, openWeatherMapDegrees: temperature)
						let min = Temperature(country: country, openWeatherMapDegrees: tempMin)
						let max = Temperature(country: country, openWeatherMapDegrees: tempMax)

						let forecast = Forecast(time: forecastTimeString,
												date: forecastDate,
												iconText: forcastIconText,
												temperature: forecastTemperature.degrees,
												description: description,
												windSpeed: windSpeed.stringValue,
												temperatureMin: min.degrees,
												temperatureMax: max .degrees)
						//Set Weather Model Object
						let weather = Weather(city:name, forecasts:[forecast])
						weathers.append(weather)
					}
					handler(weathers, nil)
					return
				}

				if let message = json["message"] as? String {
					let error = NSError(domain: "Unauthorized", code: code.intValue, userInfo: [NSLocalizedDescriptionKey: message])
					handler(nil, error as NSError)
				} else {
					let error = NSError(domain: "Unauthorized", code: code.intValue, userInfo: [NSLocalizedDescriptionKey: "Something went wrong, Please try again later."])
					handler(nil, error as NSError)
				}
				return
            }
			handler(nil, error as NSError)
        }
	}

	//method for getting forcasts
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

            let forecastTimeString = ForecastDateTime(date: rawDateTime).shortTimeString
            let forecastDate = ForecastDateTime(date: rawDateTime).date
			let weatherIcon = WeatherIcon(condition: forecastCondition, iconString: forecastIcon)
            let forcastIconText = weatherIcon.iconText
			let forecastTemperature = Temperature(country: country, openWeatherMapDegrees: temperature)
			let min = Temperature(country: country, openWeatherMapDegrees: tempMin)
			let max = Temperature(country: country, openWeatherMapDegrees: tempMax)

            let forecast = Forecast(time: forecastTimeString,
									date: forecastDate,
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
