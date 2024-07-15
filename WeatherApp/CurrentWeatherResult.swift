//
//  CurrentWeatherResult.swift
//  WeatherApp
//
//  Created by ahnzihyeon on 7/15/24.
//

import Foundation

struct CurrentWeatherResult: Codable {
    let weather: [Weather]
    let main: WeatherMain
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct WeatherMain: Codable {
    let temp: Double
    let temp_min: Double
    let temp_max: Double
    let humidity: Int
}
