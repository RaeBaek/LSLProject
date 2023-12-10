//
//  CustomTextField.swift
//  LSLProject
//
//  Created by 백래훈 on 12/10/23.
//

import UIKit

final class CustomTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.font = .systemFont(ofSize: 14, weight: .regular)
        self.textColor = .black
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
