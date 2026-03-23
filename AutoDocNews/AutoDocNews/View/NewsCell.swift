//
//  NewsCell.swift
//  AutoDocNews
//
//  Created by emil kurbanov on 19.03.2026.
//

import UIKit

class NewsCell: UICollectionViewCell {
    
    static let reuseIdentifier = "NewsCell"
    private var imageTask: Task<Void, Never>?
    private var currentImageURL: URL?
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.backgroundColor = UIColor(white: 0.95, alpha: 1)
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let sp = UIActivityIndicatorView(style: .medium)
        sp.hidesWhenStopped = true
        sp.color = UIColor.systemGray
        return sp
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageTask?.cancel()
        imageTask = nil
        
        currentImageURL = nil   // 🔥 важно
        
        imageView.image = nil
        spinner.stopAnimating()
    }
    
    private func setupViews() {
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        
        contentView.addSubview(stackView)
        contentView.addSubview(spinner)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        spinner.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            spinner.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
    }
    
    func configure(with news: NewsModel) {
        titleLabel.text = news.title
        imageView.image = nil
        
        guard let url = URL(string: news.titleImageUrl ?? "") else { return }
        
        currentImageURL = url
        
        if let cachedImage = ImageCache.shared.object(forKey: url as NSURL) {
            imageView.image = cachedImage
            spinner.stopAnimating()
            return
        }
        
        spinner.startAnimating()
        
        imageTask = Task { [weak self] in
            guard let self else { return }
            
            if let image = await self.loadImage(from: url) {
                ImageCache.shared.setObject(image, forKey: url as NSURL)
                
                // 🔥 КЛЮЧЕВАЯ ПРОВЕРКА
                if self.currentImageURL == url && !Task.isCancelled {
                    self.imageView.image = image
                    self.spinner.stopAnimating()
                }
            } else {
                if self.currentImageURL == url {
                    self.spinner.stopAnimating()
                }
            }
        }
    }
    
    private func loadImage(from url: URL) async -> UIImage? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            print("Ошибка загрузки изображения: \(error)")
            return nil
        }
    }
}

