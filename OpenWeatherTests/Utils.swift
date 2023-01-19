//
//  Utils.swift
//  OpenWeatherTests
//
//  Created by Jian Quan Ma on 1/18/23.
//

import Foundation
import XCTest

@testable import OpenWeather

func anyInt(from bottom: Int = 0, to top: Int = 100) -> Int {
    .random(in: bottom...top)
}

func anyDouble(from bottom: Double = 0, to top: Double = 1) -> Double {
    .random(in: bottom..<top)
}

func anyString(length: Int = 10) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).map{ _ in letters.randomElement()! })
}

extension Two: Equatable where T: Equatable {
    public static func == (lhs: Two, rhs: Two) -> Bool {
        lhs.first == rhs.first && lhs.second == rhs.second
    }
}

func anyCoord() -> Coord {
    .init(lon: anyDouble(), lat: anyDouble())
}

func anySys() -> Sys {
    .init(type: anyInt(), id: anyInt(), country: anyString(), sunrise: anyInt(), sunset: anyInt())
}

func anyClouds() -> Clouds {
    .init(all: anyInt())
}

func anyWind() -> Wind {
    .init(speed: anyDouble(), deg: anyInt(), gust: anyDouble())
}

func anyWeather(
    id: Int = anyInt(),
    main: String = anyString(),
    description: String = anyString(),
    icon: String = anyString()
) -> Weather {
    .init(id: id, main: main, description: description, icon: icon)
}

func anyMain(
    temp: Double = anyDouble(),
    feelsLike: Double = anyDouble(),
    tempMin: Double = anyDouble(),
    tempMax: Double = anyDouble(),
    pressure: Int = anyInt(),
    humidity: Int = anyInt()
) -> Main {
    .init(temp: temp, feelsLike: feelsLike, tempMin: tempMin, tempMax: tempMax, pressure: pressure, humidity: humidity)
}
