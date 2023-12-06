//
//  PostViewModel.swift
//  LSLProject
//
//  Created by 백래훈 on 11/26/23.
//

import Foundation
import RxSwift
import RxCocoa

final class PostViewModel: ViewModelType {
    
    let startMessage = "스레드를 시작하세요..."
    
    struct Input {
        let postButtonTap: ControlEvent<Void>
        let imageButtonTap: ControlEvent<Void>
        let textViewText: ControlProperty<String>
        let textViewBeginEditing: ControlEvent<Void>
        let textViewEndEditing: ControlEvent<Void>
        let imageData: BehaviorRelay<Data?>
        let userToken: BehaviorRelay<String>
    }
    
    struct Output {
        let profile: PublishRelay<String>
        let profileImageURL: PublishRelay<URL>
        let postResult: PublishRelay<Bool>
        let phpicker: PublishRelay<Bool>
        let textViewBeginEditing: PublishRelay<Void>
        let textViewEndEditing: PublishRelay<Bool>
        let postButtonStatus: BehaviorRelay<Bool>
    }
    
    var repository: NetworkRepository
    
    init(repository: NetworkRepository) {
        self.repository = repository
    }
    
    let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
        let userNickame = PublishRelay<String>()
        let profileImageURL = PublishRelay<URL>()
        let postResult = PublishRelay<Bool>()
        let phpicker = PublishRelay<Bool>()
        let textViewBeginEditing = PublishRelay<Void>()
        let textViewEndEditing = PublishRelay<Bool>()
        let postButtonStatus = BehaviorRelay<Bool>(value: false)
        
        input.userToken
            .flatMap { _ in
                self.repository.requestMyProfile()
            }
            .subscribe(onNext: { value in
                switch value {
                case .success(let data):
                    let url = URL(string: APIKey.sesacURL + (data.profile ?? ""))
                    
                    userNickame.accept(data.nick ?? "닉네임 확인 필요")
                    profileImageURL.accept(url!)
                    
                case .failure(let error):
                    guard let allPostError = MyProfileError(rawValue: error.rawValue) else {
                        print("내 프로필 조회 실패.. \(error.message)")
                        return
                    }
                    print("커스텀 포스트 에러 \(allPostError.message)")
                }
            })
            .disposed(by: disposeBag)
        
        input.textViewBeginEditing
            .bind(to: textViewBeginEditing)
            .disposed(by: disposeBag)
        
        input.textViewEndEditing
            .withLatestFrom(input.textViewText) { _, text in
                return text.isEmpty
            }
            .bind(to: textViewEndEditing)
            .disposed(by: disposeBag)
        
        input.imageData
            .map { $0 != nil }
            .bind(to: postButtonStatus)
            .disposed(by: disposeBag)
        
        input.textViewText
            .withUnretained(self)
            .map { owner, value in
                if value == "" || value == self.startMessage {
                    return false
                } else {
                    return true
                }
            }
            .bind(to: postButtonStatus)
            .disposed(by: disposeBag)
        
        input.postButtonTap
            .observe(on: SerialDispatchQueueScheduler(qos: .userInteractive))
            .withLatestFrom(input.textViewText) { _, text in
                if text == "" || text == self.startMessage {
                    return ""
                } else {
                    return text
                }
            }
            .withLatestFrom(input.imageData) { text, file in
                return (text, file)
            }
            .flatMap { value in
                let productID = "hihi"
                if value.0 == "" {
                    return self.repository.requestPostAdd(title: nil, file: value.1 ,productID: productID)
                } else {
                    return self.repository.requestPostAdd(title: value.0, file: value.1 ,productID: productID)
                }
            }
            .subscribe(onNext: { value in
                switch value {
                case .success(_):
                    print("게시글 작성 성공!")
                    postResult.accept(true)
                case .failure(let error):
                    guard let postAddError = PostAddError(rawValue: error.rawValue) else {
                        print("기본 에러: \(error.message)")
                        return
                    }
                    print("게시글 작성 커스텀 에러: \(postAddError.message)")
                    
                }
            })
            .disposed(by: disposeBag)
        
        input.imageButtonTap
            .bind { _ in
                phpicker.accept(true)
            }
            .disposed(by: disposeBag)
        
        return Output(profile: userNickame,
                      profileImageURL: profileImageURL,
                      postResult: postResult,
                      phpicker: phpicker,
                      textViewBeginEditing: textViewBeginEditing,
                      textViewEndEditing: textViewEndEditing,
                      postButtonStatus: postButtonStatus)
        
    }
    
}
