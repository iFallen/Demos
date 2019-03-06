//
//  PhotoWriter.swift
//  RxSwift-D1
//
//  Created by screson on 2019/3/6.
//  Copyright © 2019 screson. All rights reserved.
//

import Photos
import RxSwift


class PhotoWriter {
    enum Errors: Error {
        case couldNotSavePhoto
    }
    
    static func save(_ image: UIImage) -> Single<String> {
        var savedAssetId: String?
        
        return Single.create(subscribe: { (observer) -> Disposable in
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                savedAssetId = request.placeholderForCreatedAsset?.localIdentifier
            }, completionHandler: { (success, error) in
                DispatchQueue.main.async {
                    if success, let id = savedAssetId {
                        observer(.success(id))
                    } else {
                        observer(.error(error ?? Errors.couldNotSavePhoto))
                    }
                }
            })
            return Disposables.create()
        })
    }
}
