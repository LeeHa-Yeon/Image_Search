//
//  ImageRequestParameter.swift
//  Image_search
//
//  Created by 이하연 on 2021/08/03.
//

import UIKit

struct ImageRequestParameter {
    private var query: String
    private var sort: String
    private var page: Int
    private var size: Int
    
    init(query: String, sort: String, page: Int, size: Int){
        self.query = query
        self.sort = sort
        self.page = page
        self.size = size
    }
    
    mutating func setQuery(query: String){
        self.query = query
    }
    mutating func setSort(sort: String){
        self.sort = sort
    }
    mutating func setPage(page: Int){
        self.page = page
    }
    mutating func setSize(size: Int){
        self.size = size
    }
    
    var toDict: [String:Any]{
        let dict: [String:Any] = [
            "query" : self.query,
            "sort" : self.sort,
            "page" : self.page,
            "size" : self.size
            ]
        return dict
    }
    
}
