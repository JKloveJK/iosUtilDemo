//
//  UIImage+Extension.swift
//  iosUtilDemo
//
//  Created by Jiankai Lei on 2025/2/18.
//

import Foundation
import UIKit

extension UIImage {
    func resize(to targetSize: CGSize) -> UIImage? {
        let render = UIGraphicsImageRenderer(size: targetSize)
        return render.image { context in
            self.draw(in: .init(origin: .zero, size: targetSize))
        }
    }
}
