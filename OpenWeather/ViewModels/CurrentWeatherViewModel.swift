//
//  CurrentWeatherViewModel.swift
//  OpenWeather
//
//  Created by Jian Quan Ma on 1/16/23.
//
import Foundation
import UIKit

struct ImagedViewModel<Image: Hashable>: Hashable {
    let image: Image
    let title: String
    let description: String
    let request: URLRequest?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(image)
        hasher.combine(title)
        hasher.combine(description)
    }
    
    static func == (lhs: ImagedViewModel, rhs: ImagedViewModel) -> Bool {
        lhs.image == rhs.image &&
        lhs.title == rhs.title &&
        lhs.description == rhs.description
    }
}

struct CurrentWeatherViewModel<Image: Hashable> {
    let cityDisclosure: (Image, String)
    let temperature: String
    
    let info: Two<String>
    let descriptions: [ImagedViewModel<Image>]
    
    init(
        cityDisclosure: (Image, String),
        temperature: String,
        info: Two<String>,
        descriptions: [ImagedViewModel<Image>]
    ) {
        self.cityDisclosure = cityDisclosure
        self.temperature = temperature
        self.info = info
        self.descriptions = descriptions
    }
}

struct Two<T> {
    let first: T
    let second: T
}

typealias latlon = Two<Double>

extension CurrentWeatherViewModel {
    init(
        location: Image,
        sunrise: Image,
        wind: Image,
        humidity: Image,
        remote weather: RemoteWeatherRoot,
        unit: UnitTemperature,
        toUnit: UnitTemperature = .celsius
    ){
        self.cityDisclosure = (location, weather.name)
        let formatter = NumberFormatter().then {
            $0.numberStyle = .none
            $0.maximumFractionDigits = 0
        }
        
        let fahrenheit = Self.convert(weather.main.temp, from: unit, to: toUnit)
        let firstNum = Self.convert(weather.main.tempMax, from: unit, to: toUnit)
        let secondNum = Self.convert(weather.main.tempMin, from: unit, to: toUnit)
        
        let first = "H " + firstNum.description
        let second = "L " + secondNum.description
        self.temperature = first + " / " + second
        let sunriseDate = Date(timeIntervalSince1970: TimeInterval(weather.sys.sunrise))
        let dateFormatter = DateFormatter().then {
            $0.dateFormat = "hh:mm"
        }
        let dateString = dateFormatter.string(from: sunriseDate)
        let windPrefix = formatter.string(from: NSNumber(value: weather.wind.speed)) ?? ""
        let windDescription = windPrefix + " m/s"
        let humidityDescription = (formatter.string(from: NSNumber(value: weather.main.humidity)) ?? "") + " %"
        
        let fahrenheitValue = Int(fahrenheit.value)
        let fahrenheitDescription = String(format: "%d", fahrenheitValue) + " " + fahrenheit.unit.symbol
        self.info = .init(
            first: fahrenheitDescription,
            second: weather.weather.first?.main ?? ""
            )
        let remoteIconRequest =
        RemoteRequestFactory.makeCurriedIconImageRequest(scale: 2)(weather.weather.first?.icon)
        
        self.descriptions = [
            .init(image: sunrise,
                  title: "Sun rise",
                  description: dateString,
                  request: remoteIconRequest
            ),
            .init(image: wind,
                  title: "Wind",
                  description: windDescription,
                  request: remoteIconRequest
            ),
            .init(image: humidity,
                  title: "Humidity",
                  description: humidityDescription,
                  request: remoteIconRequest
            )
        ]
    }
    
    private static func convert(
        _ value: Double,
        from: UnitTemperature,
        to: UnitTemperature
    ) -> Measurement<UnitTemperature> {
        Measurement(
            value: value,
            unit: from
        ).converted(to: to)
    }
}
