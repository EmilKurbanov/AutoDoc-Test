//
//  NewsViewModel.swift
//  AutoDocNews
//
//  Created by emil kurbanov on 19.03.2026.
//

import Combine
import Foundation

class NewsViewModel: ObservableObject {
    @Published var news: [NewsModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var newsDict: [Int: NewsModel] = [:]
    private var cancellables = Set<AnyCancellable>()
    private let baseUrl = "https://webapi.autodoc.ru/api/news"
   
    
    private func removeDuplicateNews(newNews: [NewsModel]) -> [NewsModel] {
        var uniqueNews = [Int: NewsModel]()
        
        for item in newNews {
            uniqueNews[item.id] = item
        }

        return Array(uniqueNews.values)
    }
    
    

    func fetchNews(page: Int, pageSize: Int) async {
        guard let url = URL(string: "\(baseUrl)/\(page)/\(pageSize)") else {
            await MainActor.run {
                self.errorMessage = "Invalid URL"
            }
            return
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResponse = try JSONDecoder().decode(NewsResponse.self, from: data)
            
            await MainActor.run {
                for newsItem in decodedResponse.news {
                    self.newsDict[newsItem.id] = newsItem
                }
                self.news = Array(self.newsDict.values)
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Failed to load news. Please try again."
            }
            print("Error fetching news: \(error)")
        }
    }

}

