//
//  NewsModel.swift
//  AutoDocNews
//
//  Created by emil kurbanov on 19.03.2026.
//

import Foundation

struct NewsModel: Codable,Identifiable,Hashable {
    let id: Int
    let title: String
    let description: String
    let publishedDate: String
    let fullUrl: String
    let titleImageUrl: String?
    let categoryType: String
    
    var formattedDate: String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: publishedDate) else { return publishedDate }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .medium
        return outputFormatter.string(from: date)
    }
}

struct NewsResponse: Codable {
    let news: [NewsModel]
}
