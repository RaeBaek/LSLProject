//
//  MoreButton.swift
//  LSLProject
//
//  Created by 백래훈 on 12/7/23.
//

import UIKit

final class MoreButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        let imageConfig = UIImage.SymbolConfiguration(pointSize: 15)
        let image = UIImage(systemName: "ellipsis", withConfiguration: imageConfig)
        self.tintColor = .black
        self.setImage(image, for: .normal)
        self.imageView?.contentMode = .scaleAspectFit
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    func myPostTapped(id: String) {
        // 내가 작성한 게시글에서 더보기 버튼 클릭 시
        
    }
    
    func userPostTapped(id: String) {
        // 다른 사용자가 작성한 게시글에서 더보기 버튼 클릭 시
        
    }
    
}
