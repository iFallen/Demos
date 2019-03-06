//
//  ViewController.swift
//  RxSwift-D1
//
//  Created by screson on 2019/3/5.
//  Copyright © 2019 screson. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CombinestagramViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let images = BehaviorRelay<[UIImage]>(value: [])
    
    @IBOutlet weak var imgPreview: UIImageView!
    @IBOutlet weak var btnAdd: UIBarButtonItem!
    @IBOutlet weak var btnClear: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //Add Action
        btnAdd.rx.tap.asObservable().subscribe(onNext: {[unowned self] _ in
            //self.images.accept(self.images.value + [UIImage(named: "test.png")!])
            self.addImageAction()
        }).disposed(by: disposeBag)
        //Clear Action
        btnClear.rx.tap.subscribe(onNext: { [unowned self] _ in
            self.images.accept([])
            self.imageCache = []
            self.navigationItem.leftBarButtonItem = nil
        }).disposed(by: disposeBag)
        //Save Action
        btnSave.rx.tap.subscribe(onNext: { [weak self]_ in
            if let strongSelf = self, let image = self?.imgPreview.image {
                PhotoWriter.save(image).subscribe(onSuccess: { (sId) in
                    strongSelf.showMessage(title: "Saved with id: \(sId)")
                    strongSelf.btnClear.sendActions(for: .touchUpInside)
                }, onError: { (error) in
                    strongSelf.showMessage(title: "Error", description: error.localizedDescription)

                }).disposed(by: strongSelf.disposeBag)
            }
        }).disposed(by: disposeBag)
        
        
        let imagesObservable = images.asObservable().share()
        //Update preview image
        imagesObservable.throttle(0.5, scheduler: MainScheduler.instance).subscribe(onNext: { [unowned self] (imgs) in
            self.imgPreview.image = UIImage.collage(images: imgs, size: self.imgPreview.frame.size)
        }).disposed(by: disposeBag)
        //Update ControlButton
        imagesObservable.subscribe(onNext: { [unowned self] imgs in
            self.updateUI(images: imgs)
        }).disposed(by: self.disposeBag)

    }
    
    private var imageCache = [Int]()
    func addImageAction() {
        let photosViewController = storyboard!.instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController
        let newPhotos = photosViewController.selectedPhotos.share()
        newPhotos.takeWhile { [weak self] _ in
            return (self?.images.value.count ?? 0) < 6
            }.filter { (newImage) -> Bool in
                return newImage.size.width > newImage.size.height
            }.filter { [weak self] newImage -> Bool in
                
                guard let len = newImage.pngData()?.count, self?.imageCache.contains(len) == false else {
                    return false
                }
                self?.imageCache.append(len)
                return true
            }.subscribe(onNext: { [weak self] newImage in
                if let strongSelf = self {
                    strongSelf.images.accept(strongSelf.images.value + [newImage])
                }
                }, onDisposed: {
                    print("Completed selection")
            }).disposed(by: disposeBag)
        newPhotos.ignoreElements().subscribe(onCompleted: {
            
        }).disposed(by: disposeBag)
        navigationController?.pushViewController(photosViewController, animated: true)
    }
    
    func updateNavigationIcon() {
        let icon = imgPreview.image?.scaled(CGSize(width: 22, height: 22)).withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: icon, style: .done, target: nil, action: nil)
    }
    
    func updateUI(images: [UIImage]) {
        btnSave.isEnabled = (images.count > 0) && (images.count % 2 == 0)
        btnClear.isEnabled = images.count > 0
        btnAdd.isEnabled = images.count < 6
        title = images.count > 0 ? "\(images.count) photos" : "Collage"
    }
    
    func showMessage(title: String, description: String? = nil) {
        alert(title: title, text: description).subscribe().disposed(by: disposeBag)
    }
}

extension UIViewController {
    func alert(title: String, text: String?) -> Completable {
        return Completable.create(subscribe: { [weak self](completable) -> Disposable in
            let alertVC = UIAlertController(title: self?.title, message: text, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Close", style: .default, handler: { (action) in
                completable(.completed)
            }))
            self?.present(alertVC, animated: true, completion: nil)
            return Disposables.create {
                self?.dismiss(animated: true, completion: nil)
            }
        })
        
    }
}
