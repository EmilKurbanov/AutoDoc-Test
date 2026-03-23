//
//  NewsViewController.swift
//  AutoDocNews
//
//  Created by emil kurbanov on 19.03.2026.
//

import UIKit
import Combine

class NewsViewController: UIViewController, UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let news = viewModel.news[indexPath.item]
            
            guard let url = URL(string: news.titleImageUrl ?? "") else { continue }
            
            if ImageCache.shared.object(forKey: url as NSURL) != nil {
                continue
            }
            
            Task {
                _ = try? await URLSession.shared.data(from: url)
            }
        }
    }
    

    private var collectionView: UICollectionView!
    private var viewModel = NewsViewModel()
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 1
    private let pageSize = 15
    
    // Diffable data source
    private var dataSource: UICollectionViewDiffableDataSource<Section, NewsModel>!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        
        bindViewModel()
        Task {
            await viewModel.fetchNews(page: currentPage, pageSize: pageSize)
        }
        title = "Новости AutoDoc"
    }

    private func setupCollectionView() {
        let layout = NewsLayout.createCompositionalLayout(for: traitCollection)
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        collectionView.register(NewsCell.self, forCellWithReuseIdentifier: NewsCell.reuseIdentifier)
        
        collectionView.delegate = self
        
        // 👉 ВОТ СЮДА ДОБАВЛЯЕШЬ
        collectionView.prefetchDataSource = self
        
        view.addSubview(collectionView)
        
        dataSource = UICollectionViewDiffableDataSource<Section, NewsModel>(
            collectionView: collectionView
        ) { (collectionView, indexPath, news) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: NewsCell.reuseIdentifier,
                for: indexPath
            ) as? NewsCell else {
                fatalError("Unable to dequeue NewsCell")
            }
            
            cell.configure(with: news)
            return cell
        }
    }

    private func bindViewModel() {
        viewModel.$news
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.applySnapshot()
            }
            .store(in: &cancellables)
    }

    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, NewsModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.news)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.collectionView.collectionViewLayout = NewsLayout.createCompositionalLayout(for: self.traitCollection)
        })
    }
}

extension NewsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let news = viewModel.news[indexPath.item]
        let detailVC = NewsDetailViewController(news: news)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        
        if offsetY > contentHeight - scrollViewHeight - 100 {
            loadMoreNewsIfNeeded()
        }
    }

    private func loadMoreNewsIfNeeded() {
        guard !viewModel.isLoading else { return }
        currentPage += 1
        Task {
            await viewModel.fetchNews(page: currentPage, pageSize: pageSize)
        }
    }
}

enum Section {
    case main
}
