//
//  CustomTableViewCell.swift
//  OpenWeather
//
//  Created by Jian Quan Ma on 1/17/23.
//

import UIKit

final class CustomTableViewCell: UITableViewCell {
    private let mainImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 18)
        $0.textAlignment = .right
    }
    let descriptionLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.numberOfLines = 0
        $0.textAlignment = .right
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        
        backgroundColor = .clear
        let stack = UIStackView(arrangedSubviews: [
            mainImageView,
            titleLabel,
            descriptionLabel
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .trailing
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            mainImageView.heightAnchor.constraint(equalToConstant: 80),
            mainImageView.widthAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    func configure(with viewModel: ImagedViewModel<UIImage>) {
        mainImageView.image = viewModel.image
        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.description
    }
    
    func replaceImage(with image: UIImage) {
        mainImageView.image = image
        UIView.animate(withDuration: 0.3, delay: 1, animations: { print("testing") }, completion: nil)
    }
}
