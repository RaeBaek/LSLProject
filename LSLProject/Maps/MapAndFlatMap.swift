//
//  MapAndFlatMap.swift
//  LSLProject
//
//  Created by 백래훈 on 11/17/23.
//

import UIKit
import RxSwift
import RxCocoa

class MapAndFlatMap: UIViewController {
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        goFlatMap()
        
    }

    func goFlatMap() {
        let upper = Observable.of("1", "2", "3")
        let lower = Observable.of("a", "b", "c")
        
        upper
            .flatMap { value in
                return lower.map { value + $0 }
            }
            .subscribe(onNext: {                    value in
                print(value)
            })
            .disposed(by: disposeBag)
        
    }
    
    func goMap() {
        
//        let upper = Observable.of("1", "rb2@sesac.com", "C", "rb2@sesac.com", "rb2@sesac.com", "rb2@sesac.com", "C", "C")
        
//        upper
//            .flatMap {
//                APIManager.shared.emailValidationAPI2(email: $0)
//            }
//            .bind { value in
//                print()
//            }
//            .disposed(by: disposeBag)
        
        let value = Observable.of(1, 2, 3)
        
        value
            .map { value in
                return value * 2
            }
            .subscribe(onNext: { value in
                print(value)
            })
            .disposed(by: disposeBag)
        
    }
    
}
