//
//  SearchViewController.swift
//  WeatherForecast
//
//  Created by Rajender Sharma on 25/01/20.
//  Copyright © 2020 Rajender Sharma. All rights reserved.
//

import UIKit
import Alamofire
import Toaster

class SearchViewController: UIViewController {
	var weather:[Weather]? = []
	var weatherService:WeatherServiceProtocol = OpenWeatherMapService()

	/*
	List of cities downloaded from: http://bulk.openweathermap.org/sample/
	*/
	lazy var cityNames:[JSON] = {
		if let path = Bundle.main.path(forResource: "city_list", ofType: "json") {
			do {
				  let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
				  let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
				  if let jsonResult = jsonResult as? [JSON] {
					// do stuff
					return jsonResult
				}
			  } catch {
				   // handle error
					return []
			  }
		}
		return []
	}()

	@IBOutlet weak var textView: UITextView! {
		didSet {
			textView.text = ""
			textView.delegate = self
			textView.font = UIFont.defaultFont(with: .medium, size: 14)

			textView.layer.borderColor = UIColor.gray.cgColor
			textView.layer.borderWidth = 1.0
			textView.layer.cornerRadius = 8.0
			textView.clipsToBounds = true
		}
	}
	
	@IBOutlet weak var tableView: UITableView! {
		didSet {
			tableView.delegate = self
			tableView.dataSource = self

			let cellNib = UINib(nibName: "WeatherTableViewCell", bundle: nil)
			tableView.register(cellNib, forCellReuseIdentifier: "WeatherCell")
		}
	}

	override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		configureView()
    }

	private func configureView() {
		self.title = "Search Cities"
	}

	//Get city info from city list json file.
	func getCityInfo(city:String) -> JSON? {
		let name = city.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
		if name.count == 0 { return nil }

		let cityInfo = self.cityNames.first { (object) -> Bool in
			if let objectCityName = object["name"] as? String {
				return objectCityName.lowercased() == name
			}
			return false
		}
		return cityInfo
	}

	func fetchWeatherDetails(for cities:[String]) {
		//Check for internet connection.
		guard self.isNetworkAvailable() == true else {
			return
		}
		var cityIDs = ""
		//Call API to get weather details for city one by one
		cities.forEach({ [unowned self] (city) in
			if let cityInfo = self.getCityInfo(city: city), let cityId = cityInfo["id"] as? NSNumber {
				cityIDs.append("\(cityId.stringValue),")
			}
		})
		if cityIDs.hasSuffix(",") {
			cityIDs.removeLast()
		}

		self.weather = []
		//Show Progress indicator
		self.showProgressHUD()
		//API call with City name
		self.weatherService.fetchWeather(for: cityIDs) { [unowned self] (response, error) in
			DispatchQueue.main.async {
				//Hide Progress indicator
				self.hideProgressHUD()

				//Check for error and show alert if error is true
				guard let error = error else {
					if  let weathers = response, weathers.count > 0 {
						self.weather = weathers
						self.tableView.reloadData()
					}
					return
				}
				self.presentAlert(withTitle: "Sorry", message: error.localizedDescription)
			}
		}
	}
}

extension SearchViewController : UITextViewDelegate {

	//Check for duplicate city names
	func hasDuplicate(names:[String]) -> Bool {
		let uniqueNames = Array(Set(names))
		return uniqueNames.count != names.count
	}

	//Check Minimum and Maximum number of cities allowed
	func hasValidNumberOfCities(names:[String]) -> Bool {
		return names.count > 2 && names.count < 8
	}

	//Validations
	func validateCityName(names:[String]) -> Bool {
		var hasError = false
		if self.hasDuplicate(names: names) {
			self.presentAlert(withTitle: "Sorry", message: "Duplicate city names are not allowed.")
			hasError = true
		}
		if !self.hasValidNumberOfCities(names: names) {
			self.presentAlert(withTitle: "Sorry", message: "You can only enter minimum 3 and maximum 7 City names seprated by commas")
			hasError = true
		} else {
			for city in names {
				if self.getCityInfo(city: city) == nil {
					hasError = true
					self.presentAlert(withTitle: "Sorry", message: "Invalid City named - \(city)")
					break
				}
			}
		}
		return !hasError
	}

	func textViewDidEndEditing(_ textView: UITextView) {
		guard var text = textView.text else {
			return
		}
		if text.hasSuffix(",") {
			text.removeLast()
		}
		let cities = text.components(separatedBy: ",")
		if self.validateCityName(names: cities) {
			self.fetchWeatherDetails(for: cities)
		}
	}
}


extension SearchViewController : UITableViewDelegate, UITableViewDataSource {

	func numberOfSections(in tableView: UITableView) -> Int {
		guard let weather = self.weather else {
			return 0
		}
		return weather.count
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		guard let weather = self.weather else {
			return ""
		}
		let cityWeather = weather[section]
		return cityWeather.city
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 40
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell", for: indexPath) as! WeatherTableViewCell
		guard let weather = self.weather else {
			return cell
		}
		let cityWeather = weather[indexPath.section]
		cell.weather = cityWeather

		return cell
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 130
	}
}
