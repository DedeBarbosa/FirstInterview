//
//  ViewController.swift
//  InterviewTask
//
//  Created by Yeskendir Salgara on 4/15/20.
//  Copyright © 2020 Yeskendir Salgara. All rights reserved.
//

import UIKit

protocol ViewControllerDelegate{
    func rememberImage(by indexPath: IndexPath)
}

class ViewController: UICollectionViewController {

    enum Identifier: String{
        case imageCellId
    }
    
    private let infiniteSize = 100000
    private var imagesByIndex = [IndexPath : UIImage](){
        didSet{
            let maxRememberingRow = imagesByIndex.keys.max()?.row ?? 0
            if maxRememberingRow > waitForLoadIndex - 1{
                activityIndicator.isHidden = true
                activityIndicator.stopAnimating()
            }
        }
    }
    private var waitForLoadIndex = 0
    private var activityIndicator: UIActivityIndicatorView!
    
    init() {
        let layout = UICollectionViewFlowLayout()
        super.init(collectionViewLayout: layout)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTable()
        configureActivityIndicator()
    }

    private func configureActivityIndicator(){
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: self.view.frame.midX - 50, y: self.view.frame.height - 140, width: 100, height: 100))
        activityIndicator.style = .large
        activityIndicator.color = UIColor.white
        activityIndicator.hidesWhenStopped = true
        activityIndicator.layer.cornerRadius = 15
        self.view.addSubview(activityIndicator)
        self.view.bringSubviewToFront(activityIndicator)
        activityIndicator.isHidden = true
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.imageCellId.rawValue, for: indexPath) as? ImageCollectionCell else {return UICollectionViewCell()}
        if imagesByIndex.keys.contains(indexPath),
            let image = imagesByIndex[indexPath]{
            cell.imageView.image = image
        }else{
            cell.imageView.image = UIImage(named: "blank")
            cell.imageView.setImage(from: API.photo.url){[weak self] in
                self?.imagesByIndex[indexPath] = cell.imageView.image
            }
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let maxRememberingRow = imagesByIndex.keys.max()?.row ?? 0
        if indexPath.row - maxRememberingRow > 20{
            if waitForLoadIndex == 0{
                waitForLoadIndex = indexPath.row + 20
            }
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            let maxIndexPath = IndexPath(row: maxRememberingRow + 20, section: indexPath.section)
            collectionView.scrollToItem(at: maxIndexPath, at: UICollectionView.ScrollPosition.bottom, animated: true)
        } else{
            waitForLoadIndex = 0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        infiniteSize
    }
}
private extension ViewController{
    func configureTable(){
        collectionView.register(ImageCollectionCell.self, forCellWithReuseIdentifier: Identifier.imageCellId.rawValue)
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: view.bounds.size.width * 0.9, height: view.bounds.size.height * 0.45)
    }
}
