//
//  ImageCache.swift
//  AutoDocNews
//
//  Created by emil kurbanov on 19.03.2026.
//

import UIKit

final class ImageCache {
    static let shared = NSCache<NSURL, UIImage>()
}

