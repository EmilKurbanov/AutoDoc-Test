//
//  NewsLayout.swift
//  AutoDocNews
//
//  Created by emil kurbanov on 19.03.2026.
//

import UIKit

class NewsLayout {
    static func createCompositionalLayout(for traitCollection: UITraitCollection) -> UICollectionViewLayout {
        let isPad = traitCollection.horizontalSizeClass == .regular
        let itemSize = NSCollectionLayoutSize(
            widthDimension: isPad ? .fractionalWidth(0.5) : .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(150)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
