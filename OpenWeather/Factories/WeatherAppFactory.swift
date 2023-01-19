//
//  WeatherAppFactory.swift
//  OpenWeather
//
//  Created by Jian Quan Ma on 1/18/23.
//

import Combine
import UIKit

final class WeatherAppFactory {
    private let snakeCaseDecoder = JSONDecoder().then {
        $0.keyDecodingStrategy = .convertFromSnakeCase
    }
    private var bag: [AnyCancellable] = []
    private let session = URLSession.shared
    
    func makeViewController() -> UIViewController {
        let tempImage = UIImage.add
        let gozioHQ = latlon(first: 33.78591032377107, second: -84.40964058633683)
        let source = UnitTemperature.celsius
        
        let req = RemoteRequestFactory.make(
            latlon: gozioHQ,
            source: source,
            appid: "3aa158b2f14a9f493a8c725f8133d704")
        
        let viewController = ViewController()
        
        viewController.onViewDidDisppear = {[weak self] in self?.bag = []}
        
        viewController.onViewDidLoad = { [weak self, weak viewController] in
            guard let self = self else { return }
            
            self.makeViewModelPublisher(
                tempImage: tempImage,
                source: source,
                req: req
            ).sink (
                receiveCompletion: {_ in }, receiveValue: { viewController?.show(viewModel: $0)}
            ).store(in: &self.bag)
            
        }
        
        viewController.imagePublisherForRequest = { [session] in
            session
                .dataTaskPublisher(for: $0)
                .map(\.data)
                .compactMap(UIImage.init)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        return viewController
    }
    
    private func makeViewModelPublisher(
        tempImage: UIImage,
        source: UnitTemperature,
        req: URLRequest
    ) -> AnyPublisher<CurrentWeatherViewModel<UIImage>,Error> {
        session
            .dataTaskPublisher(for: req)
            .map(\.data)
            .decode(type: RemoteWeatherRoot.self, decoder: snakeCaseDecoder)
            .receive(on: DispatchQueue.main)
            .map {
                CurrentWeatherViewModel.init(
                    location: UIImage(named: "location")!,
                    sunrise: UIImage(named: "sunrise")!,
                    wind: UIImage(named: "wind")!,
                    humidity: UIImage(named: "humidity")!,
                    remote: $0,
                    unit: source
                )}.eraseToAnyPublisher()   
            }
}
