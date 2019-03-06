//
//  UIImage+Collage.swift
//  RxSwift-D1
//
//  Created by screson on 2019/3/6.
//  Copyright © 2019 screson. All rights reserved.
//

import UIKit

extension UIImage {
    static func collage(images: [UIImage], size: CGSize) -> UIImage? {
        if images.count == 0 {
            return nil
        }
        let rows = images.count < 3 ? 1 : 2
        let columns = Int(round(Double(images.count) / Double(rows)))
        let tileSize = CGSize(width: round(size.width / CGFloat(columns)), height: round(size.height / CGFloat(rows)))
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        UIColor.white.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        for (index, image) in images.enumerated() {
            image.scaled(tileSize).draw(at: CGPoint(x: CGFloat(index % columns) * tileSize.width, y: CGFloat(index / columns) * tileSize.height))
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndPDFContext()
        return image
    }
    
    func scaled(_ newSize: CGSize) -> UIImage {
        guard size != newSize else {
            return self
        }
        let ratio = max(newSize.width / size.width, newSize.height / size.height)
        let width = size.width * ratio
        let height = size.height * ratio
        let scaledRect = CGRect(x: (newSize.width - width) / 2, y: (newSize.height - height) / 2, width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(scaledRect.size, false, 0)
        defer {
            UIGraphicsEndImageContext()
        }
        draw(in: scaledRect)
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
}
