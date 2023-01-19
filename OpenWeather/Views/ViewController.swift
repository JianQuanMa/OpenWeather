//
//  ViewController.swift
//  OpenWeather
//
//  Created by Jian Quan Ma on 1/16/23.
//

import UIKit
import Combine

final class ViewController: UIViewController {
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let cityLabel = UILabel()
    private let temperatureRangeLabel = UILabel()
    private let tableView = UITableView()
    private let currentTemperatureInFahrenheitLabel = UILabel()
    private let weatherDescriptionLabel = UILabel()
    
    private var bag: [AnyCancellable] = []
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        onViewDidLoad?()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onViewDidDisppear?()
    }
    
    var onViewDidLoad: (() -> Void)?
    var onViewDidDisppear: (() -> Void)?
    var imagePublisherForRequest: ((URLRequest) -> AnyPublisher<UIImage, URLError>)?
    
    func show(viewModel: CurrentWeatherViewModel<UIImage>) {
        self.cityLabel.text = viewModel.cityDisclosure.1
        self.temperatureRangeLabel.text = viewModel.temperature
        
        UIView.animate(withDuration: 0.3) {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
        }
        self.currentTemperatureInFahrenheitLabel.text = viewModel.info.first
        self.weatherDescriptionLabel.text = viewModel.info.second
        
        var snap = NSDiffableDataSourceSnapshot<Int, ImagedViewModel<UIImage>>()
        snap.appendSections([0])
        snap.appendItems(viewModel.descriptions, toSection: 0)
        
        datasource.apply(snap)
    }
    
    private func setupUI() {
        setupBackground()
        showLoader()
    }
    
    private func setupBackground() {
        let backgroundImage = UIImage(named: "bgImage1")
        let imageView = UIImageView(image: backgroundImage)
        imageView.contentMode = .scaleAspectFill
        imageView.frame = view.bounds
        view.insertSubview(imageView, at: 0)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
    }
    
    private func showLoader() {
        let loadingView = UIView(frame: self.view.bounds)
        loadingView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        activityIndicator.center = loadingView.center
        activityIndicator.startAnimating()
        loadingView.addSubview(activityIndicator)
        view.addSubview(loadingView)
        
        cityLabel.translatesAutoresizingMaskIntoConstraints = false
        cityLabel.textAlignment = .right
        temperatureRangeLabel.translatesAutoresizingMaskIntoConstraints = false
        temperatureRangeLabel.textAlignment = .right
        
        let topRightStack = UIStackView(arrangedSubviews: [
            cityLabel,
            temperatureRangeLabel
        ])
        
        topRightStack.spacing = 16
        topRightStack.axis = .vertical
        topRightStack.translatesAutoresizingMaskIntoConstraints = false
        
        let scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor(white: 1, alpha: 0.5)
        view.addSubview(scrollView)
        scrollView.isScrollEnabled = true
        
        let mainView = UIView()
        mainView.translatesAutoresizingMaskIntoConstraints = false
        mainView.addSubview(topRightStack)
        
        scrollView.addSubview(mainView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CustomTableViewCell.self)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(tableView)
        
        [currentTemperatureInFahrenheitLabel, weatherDescriptionLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.textAlignment = .right
        }
        
        let infoStack = UIStackView(arrangedSubviews: [
            currentTemperatureInFahrenheitLabel,
            weatherDescriptionLabel
        ])
        
        infoStack.spacing = 16
        infoStack.axis = .vertical
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        mainView.addSubview(infoStack)
        
        NSLayoutConstraint.activate([
            scrollView.safeAreaLayoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            mainView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            mainView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            mainView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            mainView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            topRightStack.topAnchor.constraint(equalTo: mainView.topAnchor),
            topRightStack.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
            topRightStack.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            
            infoStack.topAnchor.constraint(equalTo: topRightStack.bottomAnchor, constant: 32),
            infoStack.trailingAnchor.constraint(equalTo: topRightStack.trailingAnchor),
            infoStack.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            
            tableView.topAnchor.constraint(equalTo: infoStack.bottomAnchor, constant: 32),
            tableView.trailingAnchor.constraint(equalTo: infoStack.trailingAnchor),
            tableView.widthAnchor.constraint(equalTo: mainView.widthAnchor, multiplier: 0.5),
            tableView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),
            tableView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }
    
    private lazy var datasource = UITableViewDiffableDataSource<Int, ImagedViewModel<UIImage>>(
        tableView: tableView,
        cellProvider: { [weak self] tv, indexPath, model in
            let cell = tv.dequeue(CustomTableViewCell.self)
            cell.configure(with: model)
            
            if let request = model.request, let self = self {
                self.imagePublisherForRequest?(request)
                    .sink(
                        receiveCompletion: { _ in },
                        receiveValue: {
                            // ensure that reused cell hasn't been reused by the time this block triggers
                            if self.tableView.indexPath(for: cell) == indexPath {
                                cell.replaceImage(with: $0)
                            }
                        }
                    ).store(in: &self.bag)
            }
            return cell
        }
    )
    
}

