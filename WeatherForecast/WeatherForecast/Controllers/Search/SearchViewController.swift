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

			let cellNib = UINib(nibName: "ForecastTableViewCell", bundle: nil)
			tableView.register(cellNib, forCellReuseIdentifier: "ForecastCell")
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

	func fetchWeather(for city:String, handler: @escaping (Weather)->Void) {

        //Check for internet connection.
        guard self.isNetworkAvailable() == true else {
            return
        }
        self.showProgressHUD()
		let apiPath = API.host + "2.5/forecast"
		let parameters = ["appid":API.key, "q":city]
		Alamofire.request(apiPath, method: .get, parameters: parameters as Parameters, encoding: URLEncoding.default, headers: nil).responseJSON { response in

			self.hideProgressHUD()

			guard let error = response.error else {
                guard let json = response.result.value as? JSON else {
                    self.presentDefaultErrorAlert()
                    return
                }
				let weather = Weather(json: json)
				handler(weather)
				return
            }
            self.presentAlert(withTitle: "", message: error.localizedDescription)
        }
    }
}

extension SearchViewController : UITextViewDelegate {

	func validateCityName(names:[String]) -> Bool {
		var hasError = false
		if names.count < 3 {
			self.presentAlert(withTitle: "Sorry", message: "Please enter atleast 3 City names seprated by comma")
			hasError = true
		} else if (names.count > 7) {
			self.presentAlert(withTitle: "Sorry", message: "You can only enter maximum 7 City names seprated by comma")
			hasError = true
		} else {
			for city in names {
				if city.trimmingCharacters(in: .whitespacesAndNewlines).count < 1 {
					hasError = true
					break
				}
			}
			if hasError == true {
				self.presentAlert(withTitle: "Sorry", message: "You have entered invalid City names")
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
			self.weather = []
			cities.forEach({ [unowned self] (city) in
				self.fetchWeather(for: city, handler: { [unowned self] (cityWeather) in
					DispatchQueue.main.async {
						if cityWeather.city.count == 0 {
							ToastCenter.default.cancelAll()
							_ = Toast(text: "No weather details available for \(city)", duration: Delay.long)
						} else {
							self.weather?.append(cityWeather)
						}
						//self.weather?.append(cityWeather)
						self.tableView.reloadData()
					}
				})
			})
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
		if let forecast = cityWeather.forecasts.first {
			return "\(cityWeather.city) - \(forecast.time)"
		}
		return cityWeather.city
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 40
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastCell", for: indexPath) as! ForecastTableViewCell
		guard let weather = self.weather else {
			return cell
		}
		let cityWeather = weather[indexPath.section]
		cell.weather = cityWeather

		return cell
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 100
	}
}
