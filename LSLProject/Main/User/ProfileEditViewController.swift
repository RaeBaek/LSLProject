//
//  ProfileEditViewController.swift
//  LSLProject
//
//  Created by 백래훈 on 12/10/23.
//

import UIKit
import SnapKit
import Kingfisher
import RxSwift
import RxCocoa
import PhotosUI

final class ProfileEditViewController: BaseViewController {
    
    lazy var dismissBarbutton = {
        let view = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(dismissViewController))
        view.tintColor = .black
        return view
    }()
    
    lazy var completeBarbutton = {
        let view = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(dismissViewController))
        return view
    }()
    
    let containerView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.clipsToBounds = true
        return view
    }()
    
    let profileImage = ProfileImageView(frame: .zero)
    let profileButton = DeleteButton(frame: .zero)
    
    let nicknameLabel = NicknameLabel(frame: .zero)
    let phoneLabel = NicknameLabel(frame: .zero)
    let birthdayLabel = NicknameLabel(frame: .zero)
    let nondisclosureLabel = NicknameLabel(frame: .zero)
    
    let nicknameTextField = CustomTextField(frame: .zero)
    let phoneTextField = CustomTextField(frame: .zero)
    let birthdayTextField = CustomTextField(frame: .zero)
    
    let nicknameLine = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    let phoneLine = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    let birthdayLine = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    let nondisclosureToggle = {
        let view = UISwitch()
        view.isOn = false
        view.tintColor = .black
        view.onTintColor = .black
        return view
    }()
    
    var data: Data? {
        didSet(newValue) {
            imageData.accept(newValue)
        }
    }
    
    lazy var imageData = BehaviorRelay(value: data)
    
    var sendDelegate: SendData?
    
    private let viewModel = ProfileEditViewModel(repository: NetworkRepository())
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBar()
        
        bind()
        
    }
    
    private func bind() {
        let input = ProfileEditViewModel.Input(userToken: BehaviorRelay(value: UserDefaultsManager.token),
                                               completeButtonTapped: completeBarbutton.rx.tap,
                                               image: imageData,
                                               nickname: nicknameTextField.rx.text.orEmpty,
                                               phoneNum: phoneTextField.rx.text.orEmpty,
                                               birthDay: birthdayTextField.rx.text.orEmpty)
        
        let output = viewModel.transform(input: input)
        
        output.profile
            .withUnretained(self)
            .bind { owner, value in
                
                if let profileURL = value.profile {
                    let url = URL(string: APIKey.sesacURL + profileURL)
                    owner.profileImage.kf.setImage(with: url, options: [.requestModifier(owner.imageDownloadRequest)])
                }
                
                owner.nicknameTextField.text = value.nick
                owner.phoneTextField.text = value.phoneNum
                owner.birthdayTextField.text = value.birthDay
                
            }
            .disposed(by: disposeBag)
        
        output.profileEditStatus
            .withUnretained(self)
            .bind { owner, value in
                if value {
                    owner.dismissViewController()
                }
            }
            .disposed(by: disposeBag)
        
        profileButton.rx.tap
            .withUnretained(self)
            .bind { owner, _ in
                owner.presentPicker()
            }
            .disposed(by: disposeBag)
        
    }
    
    private func setNavigationBar() {
        title = "프로필 편집"
        self.navigationItem.leftBarButtonItem = dismissBarbutton
        self.navigationItem.rightBarButtonItem = completeBarbutton
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.shadowImage = nil
        
    }
    
    private func presentPicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        // configuration.filter = .any(of: [.images, .livePhotos, .videos])
        
        let imagePicker = PHPickerViewController(configuration: configuration)
        imagePicker.delegate = self
        
        self.present(imagePicker, animated: true)
    }
    
    @objc private func dismissViewController() {
        sendDelegate?.sendData(data: Data())
        self.dismiss(animated: true)
        
    }
    
    override func configureView() {
        super.configureView()
        
        nicknameLabel.text = "닉네임"
        phoneLabel.text = "휴대폰 번호"
        birthdayLabel.text = "생년월일"
        nondisclosureLabel.text = "비공개 프로필"
        
        nicknameTextField.placeholder = "닉네임을 입력해주세요."
        phoneTextField.placeholder = "휴대폰 번호를 입력해주세요."
        birthdayTextField.placeholder = "생년월일을 입력해주세요."
        
        view.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        
        view.addSubview(containerView)
        containerView.backgroundColor = .systemBackground
        
        [profileImage, profileButton, nicknameLabel, nicknameTextField, nicknameLine, phoneLabel, phoneTextField, phoneLine, birthdayLabel, birthdayTextField, birthdayLine, nondisclosureLabel, nondisclosureToggle].forEach {
            containerView.addSubview($0)
        }
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        containerView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        profileImage.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.size.equalTo(50)
        }
        
        profileButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.size.equalTo(50)
        }
        
        nicknameLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(profileImage.snp.leading).offset(-16)
        }
        
        nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(6)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(profileImage.snp.leading).offset(-16)
        }
        
        nicknameLine.snp.makeConstraints {
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(10)
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.equalTo(profileImage.snp.leading).offset(-16)
            $0.height.equalTo(0.3)
        }
        
        phoneLabel.snp.makeConstraints {
            $0.top.equalTo(nicknameLine.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
        }
        
        phoneTextField.snp.makeConstraints {
            $0.top.equalTo(phoneLabel.snp.bottom).offset(6)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        phoneLine.snp.makeConstraints {
            $0.top.equalTo(phoneTextField.snp.bottom).offset(10)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(0.3)
        }
        
        birthdayLabel.snp.makeConstraints {
            $0.top.equalTo(phoneLine.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
        }
        
        birthdayTextField.snp.makeConstraints {
            $0.top.equalTo(birthdayLabel.snp.bottom).offset(6)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        birthdayLine.snp.makeConstraints {
            $0.top.equalTo(birthdayTextField.snp.bottom).offset(10)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(0.3)
        }
        
        nondisclosureToggle.snp.makeConstraints {
            $0.top.equalTo(birthdayLine.snp.bottom).offset(20)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-20)
        }
        
        nondisclosureLabel.snp.makeConstraints {
            $0.centerY.equalTo(nondisclosureToggle)
            $0.leading.equalToSuperview().offset(16)
        }
        
    }
    
}

extension ProfileEditViewController: PHPickerViewControllerDelegate {
    func compressImage(image: UIImage, targetSize: Int) -> Data? {
        var compression: CGFloat = 1.0
        var imageData = image.jpegData(compressionQuality: compression)
        
        while (imageData?.count ?? 0) > targetSize && compression > 0 {
            compression -= 0.1
            imageData = image.jpegData(compressionQuality: compression)
        }
        
        return imageData
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        let itemProvider = results.first?.itemProvider
        if let itemProvider = itemProvider,
           itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                
                DispatchQueue.main.sync { [weak self] in
                    guard let self else { return }
                    
                    let image = image as? UIImage
                    
                    let originalImage: UIImage = image!// 원본 이미지
                    
                    let targetSize: Int = 1 * 1024 * 1024 // 1MB
                    
                    if let compressedImageData = compressImage(image: originalImage, targetSize: targetSize) {
                        
                        // 압축된 이미지 데이터 사용
                        print("압축된 이미지 입니다! \(compressedImageData)")
                        self.profileImage.image = UIImage(data: compressedImageData) //image as? UIImage
                        self.imageData.accept(compressedImageData)
                    } else {
                        print("압축된 이미지가 아닙니다 \(image?.jpegData(compressionQuality: 0.3))")
                        // 압축 실패 또는 원본 이미지가 이미 충분히 작을 때
                        self.profileImage.image = UIImage(data: (image?.jpegData(compressionQuality: 0.3))!) //image as? UIImage
                        self.imageData.accept(image?.jpegData(compressionQuality: 0.3))
                        
                    }
                }
            }
        }
    }
}
