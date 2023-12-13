//
//  CustomButton.swift
//  LSLProject
//
//  Created by 백래훈 on 12/9/23.
//

import UIKit

final class CustomButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = 15
        self.clipsToBounds = true
    }
    
    func buttonSetting(title: String, backgroundColor: UIColor, fontColor: UIColor, fontSize: CGFloat, fontWeight: UIFont.Weight) {
        
        var config = CustomButton.Configuration.filled() //apple system button
        var titleAttr = AttributedString.init(title)
        titleAttr.font = .systemFont(ofSize: fontSize, weight: fontWeight)
        
        config.baseForegroundColor = fontColor
        config.baseBackgroundColor = backgroundColor
        config.attributedTitle = titleAttr
        
        self.configuration = config
        
    }
    
}
