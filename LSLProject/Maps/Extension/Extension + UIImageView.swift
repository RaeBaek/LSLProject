//
//  Extension + UIImageView.swift
//  LSLProject
//
//  Created by 백래훈 on 12/1/23.
//

import UIKit

extension UIImageView {
    func downloadImage(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
