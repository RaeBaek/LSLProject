//
//  CustomActiveButton.swift
//  LSLProject
//
//  Created by 백래훈 on 12/8/23.
//

import UIKit

final class CustomActiveButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.tintColor = .black
        self.imageView?.contentMode = .scaleAspectFit
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    func setSymbolImage(image: String, size: CGFloat) {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: size)
        let image = UIImage(systemName: image, withConfiguration: imageConfig)
        self.setImage(image, for: .normal)
    }
    
}
