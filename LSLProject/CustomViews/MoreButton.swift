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
    
    func btnTapped(id: String, completion: @escaping (Bool) -> ()) {
        
//        let id = Observable<String>.of(id)
        
        
        
        
//            id
//            .withUnretained(self)
//            .flatMap {
//                self.repository.requestUserPosts(id: UserDefaultsManager.id)
//            }
//            .withLatestFrom(self.repository.requestUserPosts(id: UserDefaultsManager.id),
//                            resultSelector: { value, result in
//                return (value.1, result)
//            })
//            .subscribe(onNext: { id, result in
//                switch result {
//                case .success(let data):
//                    for i in 0..<data.data.count {
//                        if data.data[i].id == id {
//                            completion(true) // 내가 작성한 게시물일 경우
//                        } else {
//                            completion(false) // 내가 아닌 다른 유저가 작성한 게시물일 경우
//                        }
//                    }
//                case .failure(let error):
//                    guard let userPostsError = UserPostsError(rawValue: error.rawValue) else {
//                        print("유저별 작성한 포스트 조회 실패.. \(error.message)")
//                        return
//                    }
//                    print("커스텀 유저별 작성한 포스트 조회 에러 \(userPostsError.message)")
//                }
//            })
//            .disposed(by: disposeBag)
        
    }
    
    func myPostTapped(id: String) {
        // 내가 작성한 게시글에서 더보기 버튼 클릭 시
        
    }
    
    func userPostTapped(id: String) {
        // 다른 사용자가 작성한 게시글에서 더보기 버튼 클릭 시
        
    }
    
}
