//
//  MoreButton.swift
//  LSLProject
//
//  Created by 백래훈 on 12/7/23.
//

import UIKit
import RxSwift
import RxCocoa

final class MoreButton: UIButton {
    
    private let repository = NetworkRepository()
    
    private let disposeBag = DisposeBag()
    
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
    
}
