//
//  ForecastTableViewCell.swift
//  WeatherForecast
//
//  Created by Rajender Sharma on 01/02/20.
//  Copyright © 2020 Rajender Sharma. All rights reserved.
//

import UIKit

class ForecastTableViewCell: UITableViewCell {
		var forecast:Forecast! {
			didSet {
				descriptionLabel.text = self.forecast.description
				dateLabel.text = self.forecast.time
				temperatureLabel.text = self.forecast.temperature
				weatherImage.text = self.forecast.iconText
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
