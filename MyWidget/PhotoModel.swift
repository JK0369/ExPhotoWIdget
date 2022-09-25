//
//  PhotoModel.swift
//  ExPhotoWidget
//
//  Created by 김종권 on 2022/09/25.
//

import Foundation

struct PhotoModel: Codable {
  struct Item: Codable {
    struct Media: Codable {
      let m: String
    }
    let media: Media
  }
  let items: [Item]
}

extension PhotoModel {
  var url: String? {
    items.first?.media.m
  }
}
