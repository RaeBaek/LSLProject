//
//  UserViewModel.swift
//  LSLProject
//
//  Created by 백래훈 on 11/26/23.
//

import Foundation
import RxSwift
import RxCocoa

final class UserViewModel: ViewModelType {
    
    struct Input {
        let userToken: BehaviorRelay<String>
    }
    
    struct Output {
        let items: PublishRelay<MyProfile>
    }
    
    private let reposity: NetworkRepository
    
    private let disposeBag = DisposeBag()
    
    init(reposity: NetworkRepository) {
        self.reposity = reposity
    }
    
    func transform(input: Input) -> Output {
        
        let items = PublishRelay<MyProfile>()
        
        input.userToken
            .flatMap { value in
                self.reposity.requestMyProfile()
            }
            .subscribe(onNext: { value in
                switch value {
                case .success(let data):
                    print("내 프로필 조회 성공!")
                    items.accept(data)
                case .failure(let error):
                    guard let allPostError = MyProfileError(rawValue: error.rawValue) else {
                        print("내 프로필 조회 실패.. \(error.message)")
                        return
                    }
                    print("커스텀 포스트 에러 \(allPostError.message)")
                }
            })
            .disposed(by: disposeBag)
        
        return Output(items: items)
    }
    
}
