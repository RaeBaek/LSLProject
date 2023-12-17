//
//  MainHomeViewModel.swift
//  LSLProject
//
//  Created by 백래훈 on 11/22/23.
//

import Foundation
import RxSwift
import RxCocoa

final class HomeViewModel: ViewModelType {
    
    struct Input {
        let nextCursor: BehaviorRelay<Void>
        let refreshing: ControlEvent<Void>?
        let sendData: PublishRelay<Void>
        let userID: BehaviorRelay<String>
    }
    
    struct Output {
        let items: PublishRelay<[PostResponse]>
        let refreshLoading: PublishRelay<Bool>
    }
    
    private let repository: NetworkRepository
    
    private let disposeBag = DisposeBag()
    
    init(repository: NetworkRepository) {
        self.repository = repository
    }
    
    func transform(input: Input) -> Output {
        let refreshLoading = PublishRelay<Bool>()
        
        var next = ""
        var items = [PostResponse]() {
            willSet(newValue) {
                print("확인필요", newValue)
                observerItems.accept(newValue)
            }
        }
        
        let observerItems = PublishRelay<[PostResponse]>()
        
        let sendData = input.sendData
        
        guard let refreshing = input.refreshing else {
            return Output(items: observerItems,
                          refreshLoading: refreshLoading)
        }
        
        refreshing
            .bind { value in
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) {
                    refreshLoading.accept(true)
                    sendData.accept(())
                }
            }
            .disposed(by: disposeBag)
        
        sendData
            .withUnretained(self)
            .flatMap { owner, value in
                owner.repository.requestAllPost(next: "", limit: "10", productID: "hihi")
            }
            .subscribe(onNext: { value in
                switch value {
                case .success(let data):
                    print("포스트 조회 성공!!")
                    items = data.data
                    next = data.nextCursor
                    
                case .failure(let error):
                    guard let allPostError = AllPostError(rawValue: error.rawValue) else {
                        print("포스트 조회 실패.. \(error.message)")
                        return
                    }
                    print("커스텀 포스트 에러 \(allPostError.message)")
                }
            })
            .disposed(by: disposeBag)
        
        input.nextCursor
            .filter { _ in
                next != "0"
            }
            .withUnretained(self)
            .flatMap { owner, value in
                owner.repository.requestAllPost(next: next, limit: "10", productID: "hihi")
            }
            .subscribe(onNext: { value in
                switch value {
                case .success(let data):
                    print("포스트 조회 성공!!")
                    items.append(contentsOf: data.data)
                    next = data.nextCursor
                    
                case .failure(let error):
                    guard let allPostError = AllPostError(rawValue: error.rawValue) else {
                        print("포스트 조회 실패.. \(error.message)")
                        return
                    }
                    print("커스텀 포스트 에러 \(allPostError.message)")
                }
            })
            .disposed(by: disposeBag)
        
        return Output(items: observerItems,
                      refreshLoading: refreshLoading)
    }
    
}
