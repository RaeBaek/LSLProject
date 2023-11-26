//
//  ViewModelType.swift
//  LSLProject
//
//  Created by 백래훈 on 11/26/23.
//

import Foundation

protocol ViewModelType {
    
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
    
}
