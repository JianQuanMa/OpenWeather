//
//  RemoteWeatherRequestFactoryTests.swift
//  OpenWeatherTests
//
//  Created by Jian Quan Ma on 1/18/23.
//

import XCTest
@testable import OpenWeather

final class RemoteWeatherRequestFactoryTests: XCTestCase {
    
    func test_zero() throws {
        let source = UnitTemperature.fahrenheit
        let gozioHQ = latlon(first: 33.78591032377107, second: -84.40964058633683)
        let appid = anyString()
        
        let sut = SUT(latlon: gozioHQ, source: source, appid: appid)
        
        let url = try XCTUnwrap(sut.url)
        
        XCTAssertEqual(
            url,
            URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=33.78591032377107&lon=-84.40964058633683&appid=\(appid)&units=imperial")!)
        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: true))
        XCTAssertEqual(
            components.queryItems,
            [
                .init(name: "lat", value: "33.78591032377107"),
                .init(name: "lon", value: "-84.40964058633683"),
                .init(name: "appid", value: appid),
                .init(name: "units", value: "imperial")
            ]
        )
    }
    
    func test_one() throws {
        let source = UnitTemperature.celsius
        let lat = 33.78591
        let lon: Double = -133683
        let appid = anyString()
        
        let sut = SUT(latlon: .init(first: lat, second: lon), source: source, appid: appid)
        let actualURL = try XCTUnwrap(sut.url)
        let expected = try XCTUnwrap(URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=33.78591&lon=-133683.0&appid=\(appid)&units=metric"))
        XCTAssertEqual(actualURL, expected)
        let components = try XCTUnwrap(URLComponents(url: actualURL, resolvingAgainstBaseURL: true))
        XCTAssertEqual(components.host, "api.openweathermap.org")
        XCTAssertEqual(components.scheme, "https")
        XCTAssertEqual(components.path, "/data/2.5/weather")
        
        XCTAssertEqual(
            components.queryItems,
            [
                .init(name: "lat", value: "33.78591"),
                .init(name: "lon", value: "-133683.0"),
                .init(name: "appid", value: appid),
                .init(name: "units", value: "metric")
            ])
    }
    
    func test_imageURLCreation() throws {
        let sut = makeImageRequest(icon: "20d", scale: 1.00000001)
        let actualURL = try XCTUnwrap(sut?.url)
        let components = try XCTUnwrap(URLComponents(url: actualURL, resolvingAgainstBaseURL: true))
        
        XCTAssertEqual(components.host, "openweathermap.org")
        XCTAssertEqual(components.scheme, "https")
        XCTAssertEqual(components.path, "/img/wn/20d@1x.png")
        
        XCTAssertNil(components.queryItems)
        
        XCTAssertEqual(actualURL, URL(string: "https://openweathermap.org/img/wn/20d@1x.png"))
    }

    private func makeImageRequest(
        icon: String,
        scale: CGFloat
    ) -> URLRequest? {
        RemoteRequestFactory.makeCurriedIconImageRequest(scale: scale)(icon)
    }
    
    func SUT(
        latlon: latlon,
        source: UnitTemperature,
        appid: String
    ) -> URLRequest {
        RemoteRequestFactory.make(
            latlon: latlon,
            source: source,
            appid: appid)
    }
}
