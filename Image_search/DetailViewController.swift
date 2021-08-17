//
//  DetailViewController.swift
//  Image_search
//
//  Created by 이하연 on 2021/08/04.
//

import UIKit
import Kingfisher

class DetailViewController: UIViewController {

    @IBOutlet weak var showImage: UIImageView!
//    var documents1: [Document] = [Document]()
    var imageURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let url = URL(string: self.documents1[pageIndex].thumbnail_url)
//        showImage.kf.setImage(with: url)
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        guard let imageURL = imageURL else{ return }
        let url = URL(string: imageURL)
        
        self.showImage.kf.setImage(with: url)
    }

}
