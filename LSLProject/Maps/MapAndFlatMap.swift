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
        
//        goMap()
        goFlatMap()
    }
    
    func goMap() {
        let value = Observable.of(1, 2, 3)
        
        value
            .map { $0 * 2 }
            .bind { value in
                print(value)
            }
            .disposed(by: disposeBag)
        
    }
    
    func goFlatMap() {
        let upper = Observable.of("1", "rb2@sesac.com", "C", "rb2@sesac.com", "rb2@sesac.com", "rb2@sesac.com", "C", "C")
        let lower = Observable.of("a", "b", "c")
        
//        upper
//            .flatMap { value in
//                return lower.map { value + $0 }
//            }
//            .bind { value in
//                print(value)
//            }
//            .disposed(by: disposeBag)
        
        upper
            .flatMap {
                APIManager.shared.emailValidationAPI2(email: $0)
            }
            .bind { value in
                print()
            }
            .disposed(by: disposeBag)
    }
    
}
