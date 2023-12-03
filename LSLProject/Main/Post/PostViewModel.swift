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
    
    struct Input {
        let postButtonTap: ControlEvent<Void>
        let imageButtonTap: ControlEvent<Void>
        let textViewText: ControlProperty<String>
        let textViewBeginEditing: ControlEvent<Void>
        let textViewEndEditing: ControlEvent<Void>
        let imageData: BehaviorRelay<Data?>
    }
    
    struct Output {
        let postResult: PublishRelay<Bool>
        let phpicker: PublishRelay<Bool>
        let textViewBeginEditing: PublishRelay<Void>
        let textViewEndEditing: PublishRelay<Bool>
    }
    
    var repository: NetworkRepository
    
    init(repository: NetworkRepository) {
        self.repository = repository
    }
    
    let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
        let postResult = PublishRelay<Bool>()
        let phpicker = PublishRelay<Bool>()
        let textViewBeginEditing = PublishRelay<Void>()
        let textViewEndEditing = PublishRelay<Bool>()
        
        input.textViewBeginEditing
            .bind(to: textViewBeginEditing)
            .disposed(by: disposeBag)
        
        input.textViewEndEditing
            .withLatestFrom(input.textViewText) { _, text in
                return text.isEmpty
            }
            .bind(to: textViewEndEditing)
            .disposed(by: disposeBag)
        
        input.postButtonTap
            .observe(on: MainScheduler.asyncInstance)
            .withLatestFrom(input.textViewText) { _, text in
                return text
            }
            .withLatestFrom(input.imageData) { text, file in
//                guard let image else { return (text, image.image, image.filename) }
                print("여기지~ \(file)")
                return (text, file)
            }
            .flatMap { value in
                let productID = "hihi"
                return self.repository.requestPostAdd(title: value.0, file: value.1 ,productID: productID)
            }
            .subscribe(onNext: { value in
                switch value {
                case .success(let data):
                    print("게시글 작성 성공!")
                    print(data.title)
                    print(data.image.first)
                    postResult.accept(true)
                case .failure(let error):
                    guard let postAddError = PostAddError(rawValue: error.rawValue) else {
                        print("기본 에러: \(error.message)")
                        return }
                    
                    print("게시글 작성 에러: \(postAddError.message)")
                    
                }
            })
            .disposed(by: disposeBag)
        
        input.imageButtonTap
            .bind { _ in
                phpicker.accept(true)
            }
            .disposed(by: disposeBag)
        
        
        return Output(postResult: postResult,
                      phpicker: phpicker,
                      textViewBeginEditing: textViewBeginEditing,
                      textViewEndEditing: textViewEndEditing)
    }
    
}
