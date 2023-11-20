//
//  BirthdayViewModel.swift
//  LSLProject
//
//  Created by 백래훈 on 11/16/23.
//

import Foundation
import RxSwift
import RxCocoa

class BirthdayViewModel {
    
    struct Input {
        let inputText: ControlProperty<Date>
        let nextButtonClicked: ControlEvent<Void>
        let skipButtonClicked: ControlEvent<Void>
    }
    
    struct Output {
        let sendText: PublishRelay<String?>
        let outputText: BehaviorRelay<String>
        let statusText: BehaviorRelay<String>
        let textStatus: PublishRelay<Bool>
        let borderStatus: PublishRelay<Bool>
        let pushStatus: PublishRelay<Bool>
    }
    
    private let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
        let textStatus = PublishRelay<Bool>()
        let sendText = PublishRelay<String?>()
        let outputText = BehaviorRelay(value: dateFormat(date: Date()))
        let statusText = BehaviorRelay(value: "만 17세 미만은 가입할 수 업습니다.")
        let borderStatus = PublishRelay<Bool>()
        let pushStatus = PublishRelay<Bool>()
        
        input.inputText
            .map { _ in
                return true
            }
            .bind { value in
                borderStatus.accept(value)
                textStatus.accept(value)
            }
            .disposed(by: disposeBag)
        
        input.inputText
            .map { [weak self] value in
                return self?.dateFormat(date: value)
            }
            .compactMap { $0 }
            .bind { value in
                outputText.accept(value)
                sendText.accept(value)
            }
            .disposed(by: disposeBag)
        
        input.nextButtonClicked
            .withLatestFrom(input.inputText) { _, text in
                return text
            }
            .map { [weak self] value in
                return self?.calculateBirthDay(date: value)
            }
            .compactMap { $0 }
            .bind { bool in
                textStatus.accept(bool)
                borderStatus.accept(bool)
                if bool {
                    pushStatus.accept(bool)
                }
            }
            .disposed(by: disposeBag)
        
        input.skipButtonClicked
            .bind { _ in
                sendText.accept(nil)
                pushStatus.accept(true)
            }
            .disposed(by: disposeBag)
        
        return Output(sendText: sendText, outputText: outputText, statusText: statusText, textStatus: textStatus, borderStatus: borderStatus, pushStatus: pushStatus)
    }
    
    private func dateFormat(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        
        return formatter.string(from: date)
    }
    
    private func calculateBirthDay(date: Date) -> Bool {
        let today = Calendar.current.dateComponents([.year, .month, .day], from: .now)
        let component = Calendar.current.dateComponents([.year, .month, .day], from: date)
        
        if let tYear = today.year, let tMonth = today.month, let tDay = today.day,
           let cYear = component.year, let cMonth = component.month, let cday = component.day {
            let year = tYear - cYear
            let month = tMonth - cMonth
            let day = tDay - cday
            
            // 태어난지 17년째 되는 년 + 오늘의 월이 내 생일의 월보다 같거나 커야함
            if year >= 17 && month >= 0 {
                // 오늘의 월은 같은데 오늘의 일이 내 생일보다 작다면 아직 내 생일은 오지 않음
                if month == 0 && day < 0 {
                    return false
                } else {
                    return true
                }
            } else {
                return false
            }
        }
        return false
    }
    
}
