//
//  ImageResponse.swift
//  Image_search
//
//  Created by 이하연 on 2021/08/03.
//

import UIKit

struct ImageResponse: Codable {
    let meta: Meta
    let documents: [Document]

}

struct Meta: Codable{
    var total_count: Int
    var pageable_count: Int
    var is_end: Bool
}

struct Document: Codable{
    var collection: String
    var thumbnail_url: String
    var image_url: String
    var width: Int
    var height: Int
    var doc_url: String
}
