//
//  Extension + UIButton.swift
//  LSLProject
//
//  Created by 백래훈 on 11/14/23.
//

import UIKit

extension UIButton {
    static func capsuleButton(title: String) -> UIButton {
        let view = UIButton()
        
        var config = UIButton.Configuration.filled()
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .systemBlue
        config.cornerStyle = .capsule
        
        var titleAttr = AttributedString.init(title)
        titleAttr.font = .systemFont(ofSize: 15, weight: .regular)
        
        config.attributedTitle = titleAttr
        
        view.configuration = config
        
        return view
    }
    
    static func signUpButton(title: String) -> UIButton {
        let view = UIButton()
        
        var config = UIButton.Configuration.filled()
        config.baseForegroundColor = .systemBlue
        config.baseBackgroundColor = .systemGray6
        config.cornerStyle = .capsule
        config.background.strokeColor = .systemBlue
        config.background.strokeWidth = 1
        
        var titleAttr = AttributedString.init(title)
        titleAttr.font = .systemFont(ofSize: 15, weight: .regular)
        
        config.attributedTitle = titleAttr
        
        view.configuration = config
        
        return view
    }
    
}
