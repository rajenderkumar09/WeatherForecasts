//
//  WeatherViewModel.swift
//  WeatherForecast
//
//  Created by Rajender Sharma on 28/01/20.
//  Copyright © 2020 Rajender Sharma. All rights reserved.
//

import Foundation
import CoreLocation


class WeatherViewModel:NSObject {
  // MARK: - Constants
  fileprivate let emptyString = ""

  // MARK: - Properties
  let hasError: Observable<Bool>
  let errorMessage: Observable<String?>

  let location: String
  let iconText: String
  let temperature: String
  let forecasts: [ForecastViewModel]

  // MARK: - Services
  fileprivate lazy var locationManager:CLLocationManager = {
	  let locationManager = CLLocationManager()
	  locationManager.delegate = self
	  locationManager.desiredAccuracy = kCLLocationAccuracyBest
	  locationManager.distanceFilter = kCLLocationAccuracyKilometer
	  return locationManager
  }()

  fileprivate var weatherService: WeatherServiceProtocol

  // MARK: - init
	override init() {
		hasError = Observable(false)
		errorMessage = Observable(nil)

		location = emptyString
		iconText = emptyString
		temperature = emptyString
		forecasts = []

		// Can put Dependency Injection here
		self.startLocationService()
		weatherService = OpenWeatherMapService()
	  }

	  // MARK: - public
	  func startLocationService() {
		if CLLocationManager.locationServicesEnabled() {
			let status = CLLocationManager.authorizationStatus()
			switch status {
				case .authorizedWhenInUse, .authorizedAlways:
					self.locationManager.startUpdatingLocation()
				default:
					self.locationManager.requestWhenInUseAuthorization()
			}
		}
	  }


	  // MARK: - private
	  fileprivate func update(_ weather: Weather) {
		  hasError.value = false
		  errorMessage.value = nil

		  location.value = weather.location
		  iconText.value = weather.iconText
		  temperature.value = weather.temperature

		  let tempForecasts = weather.forecasts.map { forecast in
			return ForecastViewModel(forecast)
		  }
		  forecasts.value = tempForecasts
	  }

	  fileprivate func update(_ error: SWError) {
		  hasError.value = true

		  switch error.errorCode {
		  case .urlError:
			errorMessage.value = "The weather service is not working."
		  case .networkRequestFailed:
			errorMessage.value = "The network appears to be down."
		  case .jsonSerializationFailed:
			errorMessage.value = "We're having trouble processing weather data."
		  case .jsonParsingFailed:
			errorMessage.value = "We're having trouble parsing weather data."
		  case .unableToFindLocation:
			errorMessage.value = "We're having trouble getting user location."
		  }

		  location.value = emptyString
		  iconText.value = emptyString
		  temperature.value = emptyString
		  self.forecasts.value = []
	  }
}

// MARK: LocationServiceDelegate
extension WeatherViewModel : CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("Error: \(error.localizedDescription)")
	}

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.first else {
			return
		}
		self.locationManager.stopUpdatingLocation()
		self.weatherService.fet
	}

	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		switch status {
		case .authorizedAlways, .authorizedWhenInUse:
			self.fetchCurrentLocation()
		default:
			print("\(status)")
		}
	}
}
