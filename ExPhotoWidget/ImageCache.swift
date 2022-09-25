//
//  ImageCache.swift
//  ExPhotoWidget
//
//  Created by 김종권 on 2022/09/25.
//

import Foundation
import UIKit

final class ImageCache {
  static let shared = NSCache<NSString, UIImage>()
  
  private init() {}
}
