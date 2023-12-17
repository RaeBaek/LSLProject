//
//  LogoutViewModel.swift
//  LSLProject
//
//  Created by 백래훈 on 12/17/23.
//

import Foundation
import RxSwift
import RxCocoa

final class LogoutViewModel: ViewModelType {
    
    struct Input {
        let logoutButtonTap: ControlEvent<Void>
        let cancelButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let logoutStatus: PublishRelay<Bool>
    }
    
    var repository: NetworkRepository
    private let diposeBag = DisposeBag()
    
    init(repository: NetworkRepository) {
        self.repository = repository
    }
    
    func transform(input: Input) -> Output {
        
        let logoutStatus = PublishRelay<Bool>()
        
        input.logoutButtonTap
            .bind { _ in
                logoutStatus.accept(true)
            }
            .disposed(by: diposeBag)
        
        input.cancelButtonTap
            .bind { _ in
                logoutStatus.accept(false)
            }
            .disposed(by: diposeBag)
        
        
        return Output(logoutStatus: logoutStatus)
    }
    
}

