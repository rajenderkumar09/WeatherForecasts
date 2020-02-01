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
	var weatherService:WeatherServiceProtocol = OpenWeatherMapService()
	var dayWiseInfo:[Date: [Forecast]] = [:]

	lazy var locationManager:CLLocationManager = {
		let locationManager = CLLocationManager()
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.distanceFilter = kCLLocationAccuracyKilometer
		return locationManager
	}()


	@IBOutlet weak var messageLabel:UILabel! {
		didSet {
			messageLabel.text = "Please allow WeatherForecast to access device's GPS for getting your current city and weather forecasts."
			messageLabel.isHidden = true
			messageLabel.numberOfLines = 0
		}
	}

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
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
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
				self.tableView.isHidden = false
				self.messageLabel.isHidden = true

			case .denied, .restricted:
				self.messageLabel.isHidden = false
				self.tableView.isHidden = true

			default:
				self.locationManager.requestWhenInUseAuthorization()
			}
		} else {
			self.messageLabel.isHidden = false
			self.tableView.isHidden = true
		}
	}

	func showWeatherDetails() {
		guard let weather = self.weather else {
			return
		}
		self.title = weather.city
		
		self.dayWiseInfo = weather.groupedByDate()
		self.tableView.reloadData()
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

		//Check Network access
		guard self.isNetworkAvailable() == true else {
            return
        }
		//Show Progress indicator
		self.showProgressHUD()

		//Call API to get weather data
		weatherService.fetchWeatherInfo(location) { [unowned self] (weather, error) in

			//Hide Progress indicator
			self.hideProgressHUD()

			//Check for error and show alert if error is true
			guard let error = error else {

				//Hold weather object and show result in the list
				self.weather = weather
				self.showWeatherDetails()
				return
			}
			self.presentAlert(withTitle: "Sorry", message: error.localizedDescription)
		}
	}

	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		switch status {
		case .authorizedAlways, .authorizedWhenInUse:
			self.fetchCurrentLocation()
			self.messageLabel.isHidden = true
			self.tableView.isHidden = false
		default:
			self.messageLabel.isHidden = false
			self.tableView.isHidden = true
		}
	}
}

extension HomeViewController : UITableViewDelegate, UITableViewDataSource {

	func numberOfSections(in tableView: UITableView) -> Int {
		return dayWiseInfo.count
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		guard let key = self.weather?.section[section], let forecasts = self.dayWiseInfo[key] else {
			return 0
		}
		return forecasts.count
	}


	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		guard let key = self.weather?.section[section]  else {
			return ""
		}
		return key.toString(format: .custom("dd MMMM yyyy"))
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastCell", for: indexPath) as! ForecastTableViewCell

		guard let key = self.weather?.section[indexPath.section], let forecasts = self.dayWiseInfo[key] else {
			return cell
		}

		let forecast = forecasts[indexPath.row]
		cell.forecast = forecast

		return cell
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 40
	}
}
