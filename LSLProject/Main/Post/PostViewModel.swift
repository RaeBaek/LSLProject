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
        let textView: ControlProperty<String>
        let imageData: BehaviorRelay<Data?>
    }
    
    struct Output {
        let postResult: PublishRelay<Bool>
        let phpicker: PublishRelay<Bool>
    }
    
    var repository: NetworkRepository
    
    init(repository: NetworkRepository) {
        self.repository = repository
    }
    
    let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
        let postResult = PublishRelay<Bool>()
        let phpicker = PublishRelay<Bool>()
        
        input.postButtonTap
            .observe(on: MainScheduler.asyncInstance)
            .withLatestFrom(input.textView) { _, text in
                return text
            }
            .withLatestFrom(input.imageData) { text, image in
                guard let image else { return (text, image) }
                print("여기지~ \(image)")
                return (text, image)
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
        
        
        return Output(postResult: postResult, phpicker: phpicker)
    }
    
}
