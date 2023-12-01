//
//  HomeDetailViewModel.swift
//  LSLProject
//
//  Created by 백래훈 on 12/1/23.
//

import Foundation
import RxSwift
import RxCocoa

class HomeDetailViewModel: ViewModelType {
    
    struct Input {
        let item: BehaviorRelay<PostResponse>
    }
    
    struct Output {
        let item: BehaviorRelay<PostResponse>
    }
    
    func transform(input: Input) -> Output {
        
        let item = input.item
        
        return Output(item: item)
    }
}
