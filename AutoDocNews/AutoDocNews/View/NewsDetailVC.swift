//
//  NewsDetailVC.swift
//  AutoDocNews
//
//  Created by emil kurbanov on 19.03.2026.
//

import UIKit
import WebKit

class NewsDetailViewController: UIViewController {
    private let news: NewsModel
    private let webView = WKWebView()
    
    init(news: NewsModel) {
        self.news = news
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        webView.frame = view.bounds
        if let url = URL(string: news.fullUrl) {
            webView.load(URLRequest(url: url))
        }
    }
}
