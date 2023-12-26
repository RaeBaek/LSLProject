//
//  PostEditViewModel.swift
//  LSLProject
//
//  Created by 백래훈 on 12/26/23.
//

import Foundation
import RxSwift
import RxCocoa

final class PostEditViewModel: ViewModelType {
    
    struct Input {
        let editPostID: BehaviorRelay<String?>
        let editButtonTap: ControlEvent<Void>
        let imageButtonTap: ControlEvent<Void>
        let textViewText: ControlProperty<String>
        let textViewBeginEditing: ControlEvent<Void>
        let textViewEndEditing: ControlEvent<Void>
        let imageData: BehaviorRelay<Data?>
        let imageDeleteButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let currentData: PublishRelay<PostResponse>
        let postEditResult: PublishRelay<Bool>
        let phpicker: PublishRelay<Bool>
        let textViewBeginEditing: PublishRelay<Void>
        let textViewEndEditing: PublishRelay<Bool>
        let editButtonStatus: BehaviorRelay<Bool>
    }
    
    var repository: NetworkRepository
    
    init(repository: NetworkRepository) {
        self.repository = repository
    }
    
    let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
        let currentData = PublishRelay<PostResponse>()
        let postEditResult = PublishRelay<Bool>()
        let phpicker = PublishRelay<Bool>()
        let textViewBeginEditing = PublishRelay<Void>()
        let textViewEndEditing = PublishRelay<Bool>()
        let editButtonStatus = BehaviorRelay<Bool>(value: false)
        
        input.editPostID
            .withUnretained(self)
            .flatMap { owner, id in
                owner.repository.requestAPost(id: id!)
            }
            .withUnretained(self)
            .bind { owner, result in
                switch result {
                case .success(let data):
                    currentData.accept(data)
                case .failure(let error):
                    guard let aPostError = AllPostError(rawValue: error.rawValue) else {
                        print("게시글 공통 에러: \(error.message)")
                        return
                    }
                    print("게시글 수정 커스텀 에러: \(aPostError.message)")
                }
            }
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
        
        input.textViewText
            .withUnretained(self)
            .map { owner, value in
                if (value == "" || value == StartMessage.post.placeholder) && input.imageData.value == nil {
                    return false
                } else {
                    return true
                }
            }
            .bind(to: editButtonStatus)
            .disposed(by: disposeBag)
        
        input.imageData
            .map { $0 != nil }
            .withLatestFrom(input.textViewText, resultSelector: { bool, text in
                if (text == "" || text == StartMessage.post.placeholder) && bool == false {
                    return false
                } else {
                    return true
                }
            })
            .bind(to: editButtonStatus)
            .disposed(by: disposeBag)
        
        input.editButtonTap
            .observe(on: SerialDispatchQueueScheduler(qos: .userInteractive))
            .withLatestFrom(input.textViewText) { _, text in
                if text == "" || text == StartMessage.post.placeholder {
                    return ""
                } else {
                    return text
                }
            }
            .withLatestFrom(input.imageData) { text, file in
                return (text, file)
            }
            .withLatestFrom(input.editPostID) { data, postID in
                return (data.0, data.1, postID)
            }
            .flatMap { value in
                let productID = "myThreads"
                if value.0 == "" {
                    return self.repository.requestPostEdit(id: value.2!, title: nil, file: value.1 ,productID: productID)
                } else {
                    return self.repository.requestPostEdit(id: value.2!, title: value.0, file: value.1 ,productID: productID)
                }
            }
            .subscribe(onNext: { value in
                switch value {
                case .success(_):
                    print("게시글 수정 성공!")
                    postEditResult.accept(true)
                case .failure(let error):
                    guard let postEditError = PostEditError(rawValue: error.rawValue) else {
                        print("게시글 공통 에러: \(error.message)")
                        postEditResult.accept(false)
                        return
                    }
                    print("게시글 수정 커스텀 에러: \(postEditError.message)")
                    postEditResult.accept(false)
                }
            })
            .disposed(by: disposeBag)
        
        input.imageButtonTap
            .bind { _ in
                phpicker.accept(true)
            }
            .disposed(by: disposeBag)
        
        input.imageDeleteButtonTap
            .withLatestFrom(input.textViewText, resultSelector: { _, text in
                return text
            })
            .withLatestFrom(input.imageData, resultSelector: { text, image in
                return (text, image)
            })
            .bind { value in
                if (value.0 == "" || value.0 == StartMessage.post.placeholder) && value.1 == nil {
                    editButtonStatus.accept(false)
                } else {
                    editButtonStatus.accept(true)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(currentData: currentData,
                      postEditResult: postEditResult,
                      phpicker: phpicker,
                      textViewBeginEditing: textViewBeginEditing,
                      textViewEndEditing: textViewEndEditing,
                      editButtonStatus: editButtonStatus)
    }
    
}
