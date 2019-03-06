//
//  PhotosViewController.swift
//  RxSwift-D1
//
//  Created by screson on 2019/3/6.
//  Copyright © 2019 screson. All rights reserved.
//

import UIKit
import Photos
import RxSwift

private let reuseIdentifier = "PhotoCCVCell"

class PhotosViewController: UIViewController {

    private let disposeBag = DisposeBag()
    
    var selectedPhotos: Observable<UIImage> {
        return selectedPhotoSubject.asObservable()
    }
    
    private let selectedPhotoSubject = PublishSubject<UIImage>()
    
    private lazy var photos = PhotosViewController.loadPhotos()
    private lazy var imageManager = PHCachingImageManager()
    
    private lazy var thumbnailSize: CGSize  = {
        let cellSize = (self.ccvList.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        return CGSize(width: cellSize.width * UIScreen.main.scale, height: cellSize.height * UIScreen.main.scale)
    }()
    
    static func loadPhotos() -> PHFetchResult<PHAsset> {
        let allPhotosOption = PHFetchOptions()
        allPhotosOption.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        return PHAsset.fetchAssets(with: allPhotosOption)
    }
    
    
    @IBOutlet weak var ccvList: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.ccvList.delegate = self
        self.ccvList.dataSource = self
        
        let authorized = PHPhotoLibrary.authorized.share()
        authorized.skipWhile{ $0 == false}.take(1).subscribe(onNext: { [unowned self] _ in
            self.photos = PhotosViewController.loadPhotos()
            DispatchQueue.main.async {
                self.ccvList.reloadData()
            }
        }).disposed(by: disposeBag)
        
        authorized.skip(1).takeLast(1).filter{ $0 == false }.subscribe(onNext: { [unowned self] _ in
            DispatchQueue.main.async {
                self.errorMessage()
            }
        }).disposed(by: disposeBag)
    }
    
    
    private func errorMessage() {
        alert(title: "No access to Camera Roll", text: "You can grant access to Combinestagram from the Settings app").asObservable().take(5.0, scheduler: MainScheduler.instance).subscribe(onCompleted: {
            self.dismiss(animated: true, completion: {
                self.navigationController?.popViewController(animated: true)
            })
        }).disposed(by: disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        selectedPhotoSubject.onCompleted()
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PhotosViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let asset = photos.object(at: indexPath.item)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCCVCell
        
        cell.representedAssetIndentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil) { (image, _) in
            if cell.representedAssetIndentifier == asset.localIdentifier {
                cell.imgPhoto.image = image
            }
        }
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = photos.object(at: indexPath.item)
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCCVCell {
            cell.flash()
        }
        imageManager.requestImage(for: asset, targetSize: view.frame.size, contentMode: .aspectFill, options: nil) { (image, info) in
            guard let image = image, let info = info else { return }
            if let isThumbnail = info[PHImageResultIsDegradedKey as String] as? Bool, !isThumbnail {
                self.selectedPhotoSubject.onNext(image)
            }
        }
    }

}


