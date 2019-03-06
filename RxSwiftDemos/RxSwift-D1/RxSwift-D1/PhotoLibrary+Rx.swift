//
//  PhotoLibrary+Rx.swift
//  RxSwift-D1
//
//  Created by screson on 2019/3/6.
//  Copyright © 2019 screson. All rights reserved.
//

import UIKit
import Photos
import RxSwift

extension PHPhotoLibrary {
    static var authorized: Observable<Bool> {
        return Observable<Bool>.create({ (observer) -> Disposable in
            DispatchQueue.main.async {
                if authorizationStatus() == .authorized {
                    observer.onNext(true)
                    observer.onCompleted()
                } else {
                    observer.onNext(false)
                    requestAuthorization({ (status) in
                        observer.onNext(status == .authorized)
                        observer.onCompleted()
                    })
                }
            }
            return Disposables.create()
        })
    }
}
