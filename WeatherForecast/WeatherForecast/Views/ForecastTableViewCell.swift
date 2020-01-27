//
//  ForecastTableViewCell.swift
//  WeatherForecast
//
//  Created by Rajender Sharma on 26/01/20.
//  Copyright © 2020 Rajender Sharma. All rights reserved.
//

import UIKit

class ForecastTableViewCell: UITableViewCell {

	var weather:Weather! {
		didSet {
			if let forecast = self.weather.forecasts.first {
				self.descriptionLabel.text = "Wind Speed - \(forecast.windSpeed) meters/sec"
				self.dateLabel.text = forecast.description
				self.temperatureLabel.text = "\(forecast.temperatureMin) - \(forecast.temperatureMax)"
				self.weatherImage.text = forecast.iconText
			} else {
				self.dateLabel.text = weather.temperature
				self.temperatureLabel.text = weather.description
				self.weatherImage.text = weather.iconText
			}
		}
	}

	var forecast:Forecast! {
		didSet {
			self.descriptionLabel.text = self.forecast.description
			self.dateLabel.text = self.forecast.time
			self.temperatureLabel.text = self.forecast.temperature
			self.weatherImage.text = self.forecast.iconText
		}
	}

	@IBOutlet weak var descriptionLabel: UILabel!
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
