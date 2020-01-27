//
//  ViewController.swift
//  WeatherForecast
//
//  Created by Rajender Sharma on 25/01/20.
//  Copyright © 2020 Rajender Sharma. All rights reserved.
//


import UIKit
import CoreLocation
import Alamofire

class HomeViewController: UIViewController  {
	var weather:Weather? = nil

	lazy var locationManager:CLLocationManager = {
		let locationManager = CLLocationManager()
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.distanceFilter = kCLLocationAccuracyKilometer
		return locationManager
	}()

	@IBOutlet weak var topView: UIView!
	@IBOutlet weak var cityName: UILabel!
	@IBOutlet weak var maxMinTemprature: UILabel!
	@IBOutlet weak var temperatureLabel: UILabel!
	@IBOutlet weak var weatherImage: UILabel!
	@IBOutlet weak var messageLabel: UILabel!

	@IBOutlet weak var tableView: UITableView! {
		didSet {
			tableView.delegate = self
			tableView.dataSource = self

			let cellNib = UINib(nibName: "ForecastTableViewCell", bundle: nil)
			tableView.register(cellNib, forCellReuseIdentifier: "ForecastCell")
		}
	}

	override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		configureView()
		fetchCurrentLocation()
    }

	private func configureView() {
		self.title = "Current City"
	}

	func fetchCurrentLocation() {

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

	func showWeatherDetails() {
		guard let weather = self.weather else {
			return
		}
		self.title = weather.city
		self.tableView.reloadData()
	}

	func fetchWeather(for location:CLLocation) {

        //Check for internet connection.
        guard self.isNetworkAvailable() == true else {
            return
        }
        self.showProgressHUD()
		let apiPath = API.host + "2.5/forecast"
		let parameters = ["appid":API.key, "lat":location.coordinate.latitude, "lon":location.coordinate.longitude] as [String : Any]
        Alamofire.request(apiPath, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { response in

			self.hideProgressHUD()
			print("Response: \(response)")

			guard let error = response.error else {
                guard let JSON = response.result.value as? JSON else {
                    self.presentDefaultErrorAlert()
                    return
                }
                print("Response: \(JSON)")
				let weather = Weather(json: JSON)
				self.weather = weather
				self.showWeatherDetails()
                return
            }
            self.presentAlert(withTitle: "", message: error.localizedDescription)
        }
    }
}


extension HomeViewController : CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("Error: \(error.localizedDescription)")
	}

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.first else {
			return
		}
		self.locationManager.stopUpdatingLocation()
		self.fetchWeather(for: location)
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

extension HomeViewController : UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let weather = self.weather else {
			return 0
		}
		return weather.forecasts.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastCell", for: indexPath) as! ForecastTableViewCell
		guard let weather = self.weather else {
			return cell
		}
		let forecast = weather.forecasts[indexPath.row]
		cell.forecast = forecast

		return cell
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 100
	}
}
