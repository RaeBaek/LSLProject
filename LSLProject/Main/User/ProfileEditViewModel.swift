//
//  ProfileEditViewModel.swift
//  LSLProject
//
//  Created by 백래훈 on 12/10/23.
//

import Foundation
import RxSwift
import RxCocoa

final class ProfileEditViewModel: ViewModelType {
    
    struct Input {
        let userToken: BehaviorRelay<String>
        let completeButtonTapped: ControlEvent<Void>
        let image: BehaviorRelay<Data?>
        let nickname: ControlProperty<String>
        let phoneNum: ControlProperty<String>
        let birthDay: ControlProperty<String>
    }
    
    struct Output {
        let profile: PublishRelay<MyProfile>
        let profileEditStatus: PublishRelay<Bool>
    }
    
    private let repository: NetworkRepository
    
    private let disposeBag = DisposeBag()
    
    init(repository: NetworkRepository) {
        self.repository = repository
    }
    
    func transform(input: Input) -> Output {
        
        let profile = PublishRelay<MyProfile>()
        let profileEditStatus = PublishRelay<Bool>()
        
        let completeButtonTapped = input.completeButtonTapped
        let userToken = input.userToken
        let outputNickname = BehaviorRelay<String>(value: UserDefaultsManager.nickname)
        let outputPhoneNum = BehaviorRelay<String>(value: UserDefaultsManager.phoneNum)
        let outputBirthDay = BehaviorRelay<String>(value: UserDefaultsManager.birthDay)
        
        input.nickname
            .distinctUntilChanged()
            .bind { text in
                if text != "" {
                    outputNickname.accept(text)
                } else {
                    outputNickname.accept(UserDefaultsManager.nickname)
                }
            }
            .disposed(by: disposeBag)
        
        input.phoneNum
            .distinctUntilChanged()
            .bind { text in
                if text != "" {
                    outputPhoneNum.accept(text)
                } else {
                    outputPhoneNum.accept(UserDefaultsManager.phoneNum)
                }
            }
            .disposed(by: disposeBag)
        
        input.birthDay
            .distinctUntilChanged()
            .bind { text in
                if text != "" {
                    outputBirthDay.accept(text)
                } else {
                    outputBirthDay.accept(UserDefaultsManager.birthDay)
                }
            }
            .disposed(by: disposeBag)
        
        userToken
            .flatMap { _ in
                self.repository.requestMyProfile()
            }
            .subscribe(onNext: { value in
                switch value {
                case .success(let data):
                    print("내 프로필 조회 성공!")
                    profile.accept(data)
                case .failure(let error):
                    guard let allPostError = MyProfileError(rawValue: error.rawValue) else {
                        print("내 프로필 조회 실패.. \(error.message)")
                        return
                    }
                    print("커스텀 포스트 에러 \(allPostError.message)")
                }
            })
            .disposed(by: disposeBag)
        
        // 프로필 수정 완료 버튼 클릭 시
        // 텍스트 필드의 값이 제대로 기입되지 않는 버그
        // 수정할 것.
        completeButtonTapped
            .withUnretained(self)
            .flatMap { owner, value in
                return owner.repository.requestProfileEdit(profile: input.image.value,
                                                           nick: outputNickname.value,
                                                           phoneNum: outputPhoneNum.value,
                                                           birthDay: outputBirthDay.value)
            }
            .subscribe(onNext: { result in
                switch result {
                case .success(_):
                    print("프로필 수정 완료!")
                    UserDefaultsManager.nickname = outputNickname.value
                    UserDefaultsManager.phoneNum = outputPhoneNum.value
                    UserDefaultsManager.birthDay = outputBirthDay.value
                    profileEditStatus.accept(true)
                case .failure(let error):
                    guard let profileEditError = ProfileEditError(rawValue: error.rawValue) else {
                        print("프로필 수정 공통 에러입니다. \(error.message)")
                        profileEditStatus.accept(false)
                        return
                    }
                    print("프로필 수정 커스텀 에러입니다. \(profileEditError.message)")
                    profileEditStatus.accept(false)
                }
            })
            .disposed(by: disposeBag)
        
        return Output(profile: profile, 
                      profileEditStatus: profileEditStatus)
    }
    
}
