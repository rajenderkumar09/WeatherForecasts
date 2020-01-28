//
//  WeatherTableViewCell.swift
//  WeatherForecast
//
//  Created by Rajender Sharma on 28/01/20.
//  Copyright © 2020 Rajender Sharma. All rights reserved.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {
		var weather:Weather! {
			didSet {
				if let forecast = self.weather.forecasts.first {
					temperatureLabel.text = "\(forecast.temperatureMin) - \(forecast.temperatureMax)"
					windLabel.text = "Wind Speed - \(forecast.windSpeed) meters/sec"
					descriptionLabel.text = forecast.description
					dateLabel.text = forecast.time
					weatherImage.text = forecast.iconText
				} else {
					dateLabel.text = nil
					temperatureLabel.text = nil
					weatherImage.text = nil
					windLabel.text = nil
					descriptionLabel.text = nil
				}
			}
		}

		var forecast:Forecast! {
			didSet {
				descriptionLabel.text = self.forecast.description
				dateLabel.text = self.forecast.time
				temperatureLabel.text = self.forecast.temperature
				weatherImage.text = self.forecast.iconText
				windLabel.text = nil
			}
		}

		@IBOutlet weak var descriptionLabel: UILabel!
		@IBOutlet weak var windLabel: UILabel!
		@IBOutlet weak var temperatureLabel: UILabel!
		@IBOutlet weak var dateLabel: UILabel!
		@IBOutlet weak var weatherImage: UILabel!

		override func awakeFromNib() {
			super.awakeFromNib()
			// Initialization code
		}

		override func setSelected(_ selected: Bool, animated: Bool) {
			super.setSelected(selected, animated: animated)

			// Configure the view for the selected state
		}

	}
