//
//  ViewController.swift
//  Image_search
//
//  Created by 이하연 on 2021/08/02.
//

import UIKit
import Kingfisher


// 검색창
class SearchViewController: UIViewController,UISearchResultsUpdating {
    @IBOutlet weak var ImageCollectionView: UICollectionView!
    let searchController = UISearchController(searchResultsController: nil)
    let manager = NetworkManager.shared
    var clickIdx: Int = 0
    var sendUrl = String()
    
    //나중에 viewModel에 들어갈 것들을 임시로 사용
    var documents: [Document] = [Document]()
    var testParameter = ImageRequestParameter(query: "아기동물", sort: "accuracy", page: 1, size: 80) // 일단 전역변수로 사용하자 ㅋㅋ 나중에 viewmodel로 옮기기
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search"
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let destinationController = segue.destination as! DetailViewController
//            destinationController.pageIndex = clickIdx
            guard let cell: UICollectionViewCell = sender as? UICollectionViewCell else { return }
            guard let index: IndexPath = self.ImageCollectionView.indexPath(for: cell) else { return }
            
            destinationController.imageURL = documents[index.row].thumbnail_url
            
//            destinationController.documents1 = documents
        }
    }

    
    func updateSearchResults(for searchController: UISearchController){
        guard let searchWord = searchController.searchBar.text, searchWord.isEmpty == false else{
            return
        }
        //TODO: 1. requestParameter의 query가 계속 바뀌겟지? 바꿔줌
        self.testParameter.setQuery(query: searchWord)
        //TODO: 2. 바뀐 parameter를 이용해 api호출
        manager.requestResultImage(parameter: testParameter) { response in
            // 메인 스레드 조정 ( 네트워크 스레드에 있었기 때문에 )
            DispatchQueue.main.async {
                self.documents = response.documents
                // collectionView의 데이터를 refrash 하는 것
                self.ImageCollectionView.reloadData()
            }
        }
        
        print("검색어 ---- >\(searchWord)")
    }
    
}

// collectionViewDateSource 데이터 개수, 데이터 표현
extension SearchViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.documents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCell else{
            return UICollectionViewCell()
        }
        // string to url
        // // imagePath -> image ( url로 네트워크 요청해서 받은 이미지 데이터를 UIImage로 만들어서 세팅해야함)
        // 외부 코드 가져다 쓰기 (KingFisher)
        // SPM(Swift Package Mananger), Cocoa Pod, Carthage
        // https://github.com/onevcat/Kingfisher
        let url = URL(string: self.documents[indexPath.row].thumbnail_url)
        cell.imageViewForCell.kf.setImage(with: url)
        
        return cell
    }
}
extension SearchViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        clickIdx = indexPath.row
        print("-----------> \(indexPath.row)")
    }
}

extension SearchViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let margin: CGFloat = 2
        let width: CGFloat = (self.view.bounds.width-(2*margin))/4
        let height: CGFloat = width


        return CGSize(width: width, height: height)
    }
}

// Cell
class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageViewForCell: UIImageView!
}





