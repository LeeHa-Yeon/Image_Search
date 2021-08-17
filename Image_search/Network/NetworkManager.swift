//
//  NetworkManager.swift
//  Image_search
//
//  Created by 이하연 on 2021/08/03.
//

import UIKit
import Alamofire

class NetworkManager {
    static let shared = NetworkManager()
    private let REQUEST_URL: String = "https://dapi.kakao.com/v2/search/image"
    // HTTPHeaders => var httpHearders: [String:String]{ get }
    // get -> 가져올수만 있다.
    private let HEADERS: HTTPHeaders = ["Authorization":"KakaoAK f4d74c671333d7ac4cdadf11e105e972"]
    private init(){  }
    
    func requestResultImage(parameter: ImageRequestParameter, completion: @escaping (ImageResponse)->(Void)){
        AF.request(REQUEST_URL, method: .get, parameters: parameter.toDict, headers: HEADERS).validate(statusCode: 200..<300).responseJSON { response in
            switch response.result{
            case .success:
                do{
                    let jsonData = try JSONSerialization.data(withJSONObject: response.value!, options: .prettyPrinted)
//                    let jsonToString = String(data: jsonData, encoding: .utf8)
//                    print(jsonToString)
                    let json = try JSONDecoder().decode(ImageResponse.self, from: jsonData)
                    completion(json)
                }catch{
                    print("parsing error --> \(error.localizedDescription)")
                }
            case .failure:
                print("fail, statusCode --> \(response.result)")
            }
        }
    }
    
    
}
