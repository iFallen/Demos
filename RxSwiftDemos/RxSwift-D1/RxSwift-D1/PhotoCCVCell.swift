//
//  PhotoCCVCell.swift
//  RxSwift-D1
//
//  Created by screson on 2019/3/6.
//  Copyright © 2019 screson. All rights reserved.
//

import UIKit

class PhotoCCVCell: UICollectionViewCell {
    @IBOutlet weak var imgPhoto: UIImageView!
    var representedAssetIndentifier: String!

    override func prepareForReuse() {
        super.prepareForReuse()
        imgPhoto.image = nil
    }
    
    
    func flash() {
        imgPhoto.alpha = 0
        setNeedsLayout()
        UIView.animate(withDuration: 0.5, animations: {
            self.imgPhoto.alpha = 1
        }, completion: nil)
    }
    
}
