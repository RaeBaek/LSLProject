//
//  WithdrawViewModel.swift
//  LSLProject
//
//  Created by 백래훈 on 12/17/23.
//

import Foundation
import RxSwift
import RxCocoa

final class WithdrawViewModel: ViewModelType {
    
    struct Input {
        let withdrawButtonTap: ControlEvent<Void>
        let cancelButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let withdrawStatus: PublishRelay<Bool>
    }
    
    var repository: NetworkRepository
    private let diposeBag = DisposeBag()
    
    init(repository: NetworkRepository) {
        self.repository = repository
    }
    
    func transform(input: Input) -> Output {
        
        let withdrawStatus = PublishRelay<Bool>()
        
        input.withdrawButtonTap
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.repository.requestWithdraw()
            }
            .subscribe(onNext: { value in
                switch value {
                case .success(_):
                    print("회원 탈퇴 완료!")
                    withdrawStatus.accept(true)
                    
                case .failure(let error):
                    guard let withdrawError = WithdrawError(rawValue: error.rawValue) else {
                        print("회원 탈퇴 공동 에러 \(error.message)")
                        return
                    }
                    print("회원 탈퇴 커스텀 에러... \(withdrawError.message)")
                }
            })
            .disposed(by: diposeBag)
        
        input.cancelButtonTap
            .bind { _ in
                withdrawStatus.accept(false)
            }
            .disposed(by: diposeBag)
        
        
        return Output(withdrawStatus: withdrawStatus)
    }
    
}
