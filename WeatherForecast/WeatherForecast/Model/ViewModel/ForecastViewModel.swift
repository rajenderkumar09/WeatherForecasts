//
//  ForecastViewModel.swift
//  WeatherForecast
//
//  Created by Rajender Sharma on 28/01/20.
//  Copyright © 2020 Rajender Sharma. All rights reserved.
//

import Foundation

struct ForecastViewModel {
  let time: Observable<String>
  let iconText: Observable<String>
  let temperature: Observable<String>

  init(_ forecast: Forecast) {
    time = Observable(forecast.time)
    iconText = Observable(forecast.iconText)
    temperature = Observable(forecast.temperature)
  }
}
