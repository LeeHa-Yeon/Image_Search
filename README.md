## [목표]

- search bar에 검색할 단어를 입력하고 수행하여 검색 결과를 띄워야 한다.

    → SearchBar 이용

- 이미지 검색 API가 필요 → 카카오 API 사용

    [Kakao Developers](https://developers.kakao.com/docs/latest/ko/daum-search/dev-guide)

- 검색 결과를 받아올 모델(Movie), Response가 필요하다.
- 마지막으로 결과를 받아와서, collectionView에 띄워야 한다.

⇒ 즉, 서버에서 키워드로 검색을하고, 결과를 받아와서, 원하는 정보만 앱 내에 띄워주기

---

- paging 처리
- 이미지 셀 가변 개수 대응
- 검색 → debounce 적용해보기

---

---

# SearchBar 구성

## storyboard

view controller → navigation controller 설정

## SearchController

```swift
let searchController = UISearchController()

override func viewDidLoad() {
        super.viewDidLoad()
				title = "Search"
				navigationItem.searchController = searchController        
}
```

1. 결과

    [https://s3-us-west-2.amazonaws.com/secure.notion-static.com/5b3fdb77-c283-4414-843d-0b6db6118958/화면_기록_2021-08-02_오후_7.15.56.mov](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/5b3fdb77-c283-4414-843d-0b6db6118958/화면_기록_2021-08-02_오후_7.15.56.mov)

### 참고 자료

[UISearchController in Swift 5 (Search Bar, Swift 5 Xcode 12) -2021 - iOS for Beginners](https://www.youtube.com/watch?v=Lb8aJa7J4BI)

---

# CollectionView

## Storyboard

1. storyboard에 collectionView 추가 후 Constraint 적용하기
2. collectionView를 view에 delegate, dataSource 연결하기

## Controller

1. Viewcontroller에 레퍼런스를 가져오기

    ```swift
    class SearchViewController: UIViewController,UISearchResultsUpdating {   
        @IBOutlet weak var ImageCollectionView: UICollectionView!
    		...
    }
    ```

2. extension으로 UICollectionViewDataSource, UICollectionViewDelegate 따로 빼내어 가독성 높이기
    - UICollectionViewDataSource

        ```swift
        // collectionViewDateSource 데이터 개수, 데이터 표현
        extension SearchViewController: UICollectionViewDataSource{
            func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
                return imageArr.count
            }
            
            func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCell else{
                    return UICollectionViewCell()
                }
                cell.backgroundColor = .systemPink
                cell.imageLabel.text = imageArr[indexPath.item]
                return cell
            }
        }
        ```

    - UICollectionViewDelegate

        ```swift
        extension SearchViewController: UICollectionViewDelegate{
            
        }
        ```

    - UICollectionViewDelegateFlowLayout

        ```swift
        extension SearchViewController: UICollectionViewDelegateFlowLayout{
            func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
                let margin: CGFloat = 2
                let width: CGFloat = (self.view.bounds.width-(2*margin))/3
                let height: CGFloat = width
                
                
                return CGSize(width: width, height: height)
            }
        }
        ```

3. Cell 
    - storyboard
        - Collection Reusable View의 identifier에 지정한 셀이름 넣어주기
        - 따로 생성한 class명도 Custom Class의 Class에 넣어주기
        - 이때 Identifier와 사용할 클래스 이름을 같게 해주는 게 가독상 좋음

    ```swift
    // Cell
    class ImageCell: UICollectionViewCell {
        @IBOutlet weak var imageLabel: UILabel!
    }
    ```

4. 결과

<img width="437" alt="스크린샷_2021-08-03_오후_4 06 33" src="https://user-images.githubusercontent.com/55241258/130205742-c1cbbd74-139a-44fc-a1e6-26e797071184.png">


[[Swift] 넷플릭스 화면 따라만들기 (2)](https://leechamin.tistory.com/405)

---

# API 가져와서 띄우기

## Model

[Kakao Developers](https://developers.kakao.com/docs/latest/ko/daum-search/dev-guide)

이 곳에서 "이미지 검색" 부분의 request, response 파라미터 보고 모델 만들기

- Request 파라미터

    <img width="793" alt="스크린샷_2021-08-04_오전_3 29 51" src="https://user-images.githubusercontent.com/55241258/130206617-289d791a-b2ed-468e-b259-426148e322ee.png">


    <img width="792" alt="스크린샷_2021-08-04_오전_3 29 33" src="https://user-images.githubusercontent.com/55241258/130206711-80514599-ca0f-495b-bf01-c70439a62fa6.png">
    → 코드

    query : 검색을 원하는 질의어

    sort : default → 정확도순

    page: default → 1

    size: default → 80

    ```swift
    struct RequestParameter{
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
    	mutating func initPage(page: Int){
    			self.page = 1
    	}
    	mutating func nextPage(page: Int){
    			self.page = page + 1
    	}
    	mutating func setSize(size: Int){
    			self.size = size
    	}

    	// Dictionary형태로 바꾸기
    	var toDict: [String:Any]{
    			let dict: [String:Any] = [
    					"query": self.query,
    					"sort": self.sort,
    					"page": self.page,
    					"size": self.size
    				]
    			return dict
    	}
    ```

- Response 파라미터

    <img width="790" alt="스크린샷_2021-08-04_오전_3 30 13" src="https://user-images.githubusercontent.com/55241258/130206762-69f96cd1-7b25-4bf4-aaca-a9badaa5b7b6.png">

    <img width="790" alt="스크린샷_2021-08-04_오전_3 30 22" src="https://user-images.githubusercontent.com/55241258/130206833-8b71bab7-dbd1-4e04-893a-274d3802d0e3.png">

    → 코드

    meta, documents 만들어야됨

    ```swift
    struct ResponseParameter: Codable{
    		let meta: Meta
    		let documents: [Document]
    }

    struct Meta: Codable{
    		let total_count: Int
    		let pageable_count: Int
    		let is_end: Bool
    }

    struct Document: Codable{
    		let collection: String,
    		let thumbnail_url: String,
    		let image_url: String,
    		let width: Int
    		let height: Int
    		let doc_url: String
    } 
    ```

### Mutating이란 ??

스위프트에서 클래스는 참조 타입, 구조체 열거형은 값 타입입니다.

값 타입의 속성은 기본적으로 인스턴스 매서드 내에서 수정이 불가능합니다.

따라서 값 타입의 속성을 수정하기 위해선, 인스턴스 매서드에 mutating 키워드를 붙여줘야 합니다.

mutating을 붙이면 self 프로퍼티에 새로운 인스턴스를 할당할 수 있습니다. 

### Codable이란 ??

> struct 이용해 파라미터 짜서 json형태로 온 것을 우리가 사용할 수 있는 자료형으로 바꿔줘! → 코다블 corable

Codable이란 Encodable과 Decodable이 합쳐진 것입니다.

Encodable : data를 Encoder에서 변환해주려는 프로토콜로 바꿔주는 것

Decodable : data를 원하는 모델로 Decode해주는 것

Codable은 프로토콜이기에 채택해야하는데, struct, class, enum 모두 사용 가능

예) json

En-은 model → json

De-은 json → 내가 원하는 model

## AlamoFire → HTTP 통신( 네트워킹 라이브러리 )

### 정의

- 일반적인 네트워킹 작업을 단순화 시킨 것
- alamore란, iOS, macOS를 위한 swift 기반의 HTTP 네트워킹 라이브러리입니다.
- Alamofire는 URLSession 기반이며 URLSession은 네트워킹 호출에서 모호한 부분이 많은데 Alamofire를 사용한다면 데이터를 접근하기 위한 노력을 줄일 수 있으며 코드를 더 깔끔하고 가독성 있게 쓰는 것이 가능해집니다.
- 즉, Alamofire는 HTTP 네트워킹 라이브러리로써, 자주 사용하게 되는 코드나 함수를 더 쉽게 사용할 수 있도록 모아둔 것입니다. 이로써 코드가 더 깔끔해지고, 가독성 있게 쓰는 것이 가능해집니다.
- 비동기(asynchronously)로 네트워크 연동을 하기 때문에 서버로부터 응답을 받을 때까지 기다리지 않고 콜백을 통해서 응답을 처리해준다. 그래서 요청에 대한 응답은 이를 처리하는 핸들러 안에서만 유효하므로 수신한 응답이나 데이터에 의존적인 동작들은 반드시 해당 핸들러 내에서 완료해야 됩니다.
- request,response 메소드들, JSON 파라미터, 응답 직렬화, 인증 등 많은 기능들을 제공합니다.

### 설치

- CocoaPod로 진행

    [GitHub - Alamofire/Alamofire: Elegant HTTP Networking in Swift](https://github.com/Alamofire/Alamofire)

    - pod init → pod 추가후 저장 → pod install

### 사용

```swift
Alamofire.request("https://api.github.com/users", method: .get, parameters: [:], encoding: URLEncoding.default, headers: ["Content-Type":"application/json", "Accept":"application/json"])
            .validate(statusCode: 200..<300)
            .responseJSON { (response) in
            if let JSON = response.result.value
            {
                print(JSON)
            }
        }
```

- request 메소드 변수

    ```swift
    request(
    _ url: URLConvertible,
    method: HTTPMethod = .get,
    parameters: Parameters? = nil,
    encoding: ParameterEncoding = URLEncoding.default,
    headers: HTTPHeaders? = nil)
    ```

    - url : 요청할 URL
    - method : 요청 형식 ( get, post, put, delete 등 )
    - parameters : 요청 시 같이 보낼 파라미터
    - encoding : encoding → 이건 나는 안했음
    - header: [String:String] 형태로 보낼 수 있음
- request가 성공인지 실패인지를 필터를 하는 validate(statusCode: 200..<300)로 200~299사이의 statusCode결과만 받아올 수 있는 간편한 기능도 지원

### 코드

```swift
import UIKit
import Alamofire

class NetworkManager {
		// 싱글톤으로 NetworkManager 객체를 하나 생성
    static let shared = NetworkManager()
		// 이미지 검색에 해당하는 API주소의 URL
    private let REQUEST_URL: String = "https://dapi.kakao.com/v2/search/image"
    // HTTPHeaders => var httpHearders: [String:String]{ get }
    // get -> 가져올수만 있다.
		// ["Authorization":"KakaoAK {REST_API_KEY}"]
    private let HEADERS: HTTPHeaders = ["Authorization":"KakaoAK f4d74c671333d7ac4cdadf11e105e972"]
    private init(){  }
    
		// 
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

```

- 통신할때 코드

    ```swift
    AF.request(~).responseJSON{ response in ~~ }
    ```

    ~~에 해당하는 부분 

    ```swift
    switch response.result{
    case .success : 
    		do{
    				// json Parsing 부분 
    				let jsonData = try JSONSerialization.data(withJSONObject: response.value!, options: .prettyPrined)
    				let jsonToString = try JSONDecoder().decode(ImageResponse.self, from: jsonData)
    ```

    - json : 네트워크를 통해 데이터를 주고받는 데 자주 사용되는 경량의 데이터 형식으로,  key-value 형태의 쌍으로 이루어져 있습니다. key는 무조건 String형 , value는 상관 없음 ( 기본자료형, 배열, 객체 등 )
    - value 예시 : [ 10, {"v": 20}, [30, "마흔"] ] → [기본자료형, 객체, 배열]
    - 이때 객체는 반드시 key-value의 쌍 !!
    - JSON파싱하기 위해 → JSONSerialization 사용
        - JSONSerialization는 파라미터로 data를 받게됨
        - withJSONObject obj의 obj : JSON 데이터를 생성할 개체
        - options는 JSON 데이터를 생성하기 위한 옵션
    - Decoder하기
        - 일단, 첫번째 파라미터에는 Codable 프로토콜을 채택
        - 두번째 파라미터에는 json이 저장되어 있는 data를 전달

## Postman

- request, response 테스트
- API 개발을 빠르고 쉽게 개발된 API 테스트
- API로 request하여 나오는 response까지 확인할 수 있는 툴

## 참고 자료

[Kakao Developers](https://developers.kakao.com/docs/latest/ko/daum-search/dev-guide)

[Swift, Alamofire가 무엇인지, 어떻게 사용하는지 알아봅니다](https://devmjun.github.io/archive/Alamofire)

[Swift :: Codable 알아보기](https://shark-sea.kr/entry/Swift-Codable-%EC%95%8C%EC%95%84%EB%B3%B4%EA%B8%B0)
