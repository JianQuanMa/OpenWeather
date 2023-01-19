//
//  RemoteRequestFactory.swift
//  OpenWeather
//
//  Created by Jian Quan Ma on 1/17/23.
//

import Foundation

enum RemoteRequestFactory {
    private enum Constants {
        static let host = "api.openweathermap.org"
        static let scheme = "https"
        static let path = "/data/2.5/weather"
        static let imageHost = "openweathermap.org"
    }
    
    static func make(
        latlon: latlon,
        source: UnitTemperature,
        appid: String
    ) -> URLRequest {
        let components = NSURLComponents().then {
            $0.host = Constants.host
            $0.scheme = Constants.scheme
            $0.path = Constants.path
            $0.queryItems = [
                .init(name: "lat", value: "\(latlon.first)"),
                .init(name: "lon", value: "\(latlon.second)"),
                .init(name: "appid", value: "\(appid)"),
                .init(name: "units", value: source.queryString ?? "")
            ]
        }
        return URLRequest(url: components.url!)
    }
    
    static func makeCurriedIconImageRequest(scale: CGFloat) -> (String?) -> URLRequest? {
        { icon in
            guard let icon = icon else {return nil}
            let components = NSURLComponents().then {
                $0.scheme = Constants.scheme
                $0.host = Constants.imageHost
                $0.path = String(format: "/img/wn/\(icon)@%.0fx.png", scale)
            }
            return URLRequest(url: components.url!)
        }
    }
}

extension UnitTemperature {
    var queryString: String? {
        switch self {
        case .celsius:
            return "metric"
        case .fahrenheit:
            return "imperial"
        case .kelvin:
            return "default"
        default:
            return nil
        }
    }
}
