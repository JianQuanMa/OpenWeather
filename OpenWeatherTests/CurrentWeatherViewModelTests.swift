//
//  CurrentWeatherViewModelTests.swift
//  OpenWeatherTests
//
//  Created by Jian Quan Ma on 1/18/23.
//

import XCTest
@testable import OpenWeather

final class CurrentWeatherViewModelTests: XCTestCase {
    
    func test_info_withEmptyWeather() {
        let sut = SUT(remote: anyRemote(weathers: [], main: anyMain(temp: 212.1)))
        
        let expected: Two<String> = .init(first: "212 °C", second: "")
        
        XCTAssertEqual(sut.info, expected)
    }
    
    func test_remoteInit() {
        let main = anyString()
        let location = anyInt()
        let sunrise = anyInt()
        
        let sut = SUT(
            location: location,
            sunrise: sunrise,
            remote: anyRemote(
                weathers: [anyWeather(main: main)],
                main: anyMain(temp: 212.1),
                name: name
            )
        )
        
        XCTAssertEqual(
            sut.info,
            .init(first: "212 °C", second: main)
        )
        
        let (actualLocation, actualName) = sut.cityDisclosure
        
        XCTAssertEqual(actualName, name)
        XCTAssertEqual(actualLocation, location)
    }
    
    private func SUT(
        location: Int = anyInt(),
        sunrise: Int = anyInt(),
        wind: Int = anyInt(),
        humidity: Int = anyInt(),
        remote: RemoteWeatherRoot = anyRemote(),
        unit: UnitTemperature = .celsius
    ) -> CurrentWeatherViewModel<Int>{
        .init(location: location,
              sunrise: sunrise,
              wind: wind,
              humidity: humidity,
              remote: remote,
              unit: unit
        )
    }
}

private func anyRemote(
    coord: Coord = anyCoord(),
    weathers: [Weather] = [anyWeather()],
    base: String = anyString(),
    main: Main = anyMain(),
    visibility: Int = anyInt(),
    wind: Wind = anyWind(),
    clouds: Clouds = anyClouds(),
    dt: Int = anyInt(),
    sys: Sys = anySys(),
    timezone: Int = anyInt(),
    id: Int = anyInt(),
    name: String = anyString(),
    cod: Int = anyInt()
) -> RemoteWeatherRoot {
    .init(coord: coord,
          weather: weathers,
          base: base,
          main: main,
          visibility: visibility,
          wind: wind,
          clouds: clouds,
          dt: dt,
          sys: sys,
          timezone: timezone,
          id: id,
          name: name,
          cod: cod
    )
}
