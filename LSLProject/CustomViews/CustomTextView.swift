//
//  CustomTextView.swift
//  LSLProject
//
//  Created by 백래훈 on 12/7/23.
//

import UIKit

enum StartMessage: String, CaseIterable {
    case post
    case comment
    
    var placeholder: String {
        switch self {
        case .post:
            "스레드를 시작하세요..."
        case .comment:
            "@@@@님에게 답글 남기기..."
        }
    }
}

final class CustomTextView: UITextView {
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.font = .systemFont(ofSize: 14, weight: .regular)
        self.textColor = .lightGray
        self.sizeToFit()
        self.isScrollEnabled = false
        self.textContainer.lineFragmentPadding = 0
        self.textContainerInset = .zero
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
}
