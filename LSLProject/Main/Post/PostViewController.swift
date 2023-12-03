//
//  PostViewController.swift
//  LSLProject
//
//  Created by 백래훈 on 11/26/23.
//

import UIKit
import RxSwift
import RxCocoa
import PhotosUI

final class PostViewController: BaseViewController {

    lazy var dismissBarbutton = {
        let view = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(dismissViewController))
        view.tintColor = .black
        return view
    }()
    
    lazy var moreBarbutton = {
        let view = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), style: .plain, target: self, action: #selector(dismissViewController))
        view.tintColor = .black
        return view
    }()
    
    let profileImage = {
        let view = ProfileImageView(frame: .zero)
        view.backgroundColor = .systemGreen
        return view
    }()
    
    let userNickname = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 14, weight: .semibold)
        view.textColor = .black
        view.text = "100_r_h"
        return view
    }()
    
    private let lineBar = {
        let view = UIView()
        view.layer.cornerRadius = 1
        view.clipsToBounds = true
        view.backgroundColor = .systemGray5
        return view
    }()
    
    let albumButton = {
        let view = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 22)
        let image = UIImage(systemName: "photo.on.rectangle.angled", withConfiguration: imageConfig)
        view.tintColor = .lightGray
        view.setImage(image, for: .normal)
        view.imageView?.contentMode = .scaleAspectFit
        return view
    }()
    
    let gifButton = {
        let view = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 22)
        let image = UIImage(systemName: "book.pages", withConfiguration: imageConfig)
        view.tintColor = .lightGray
        view.setImage(image, for: .normal)
        view.imageView?.contentMode = .scaleAspectFit
        return view
    }()
    
    let recordButton = {
        let view = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 22)
        let image = UIImage(systemName: "mic", withConfiguration: imageConfig)
        view.tintColor = .lightGray
        view.setImage(image, for: .normal)
        view.imageView?.contentMode = .scaleAspectFit
        return view
    }()
    
    let voteButton = {
        let view = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 22)
        let image = UIImage(systemName: "line.3.horizontal.decrease", withConfiguration: imageConfig)
        view.tintColor = .lightGray
        view.setImage(image, for: .normal)
        view.imageView?.contentMode = .scaleAspectFit
        return view
    }()
    
    let mainTextView = {
        let view = UITextView()
        view.font = .systemFont(ofSize: 15, weight: .regular)
        view.text = "스레드를 시작하세요..."
        view.textColor = .lightGray
        view.backgroundColor = .systemGray6
        return view
    }()
    
    let postButton = {
        let view = UIButton()
        view.setTitle("게시", for: .normal)
        view.tintColor = .black
        view.backgroundColor = .systemYellow
        return view
    }()
    
    let imageButton = {
        let view = UIButton()
        view.setTitle("사진", for: .normal)
        view.tintColor = .black
        view.backgroundColor = .systemOrange
        return view
    }()
    
    let myImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    let viewModel = PostViewModel(repository: NetworkRepository())
    
    var data: Data? = Data()
    
    lazy var data2 = BehaviorRelay(value: data)
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBar()
        
        bind()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    private func bind() {
        
        let input = PostViewModel.Input(postButtonTap: postButton.rx.tap,
                                        imageButtonTap: imageButton.rx.tap,
                                        textViewText: mainTextView.rx.text.orEmpty,
                                        textViewBeginEditing: mainTextView.rx.didBeginEditing,
                                        textViewEndEditing: mainTextView.rx.didEndEditing,
                                        imageData: data2)
        
        let output = viewModel.transform(input: input)
        
        
        output.textViewBeginEditing
            .withUnretained(self)
            .bind { owner, _ in
                if owner.mainTextView.textColor == UIColor.lightGray {
                    owner.mainTextView.text = nil
                    owner.mainTextView.textColor = .black
                }
            }
            .disposed(by: disposeBag)
        
        output.textViewEndEditing
            .withUnretained(self)
            .bind { owner, bool in
                if bool {
                    owner.mainTextView.text = "스레드를 시작하세요..."
                    owner.mainTextView.textColor = .lightGray
                }
            }
            .disposed(by: disposeBag)
        
        output.postResult
            .withUnretained(self)
            .bind { owner, value in
                print("\(value)면 성공~")
            }
            .disposed(by: disposeBag)
        
        output.phpicker
            .withUnretained(self)
            .bind { owner, value in
                owner.presentPicker()
            }
            .disposed(by: disposeBag)
        
    }
    
    private func setNavigationBar() {
        title = "새로운 스레드"
        
        self.navigationItem.leftBarButtonItem = dismissBarbutton
        self.navigationItem.rightBarButtonItem = moreBarbutton
        
        self.navigationController?.navigationBar.isHidden = false
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
//        self.navigationController?.navigationBar.backgroundColor = .systemGray
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
    
    @objc func dismissViewController() {
        dismiss(animated: true)
        
    }
    
    override func configureView() {
        super.configureView()
        
        [profileImage, userNickname, mainTextView, lineBar, albumButton, gifButton, recordButton, voteButton].forEach {
            view.addSubview($0)
        }
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        profileImage.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.leading.equalToSuperview().offset(12)
            $0.size.equalTo(38)
        }
        
        userNickname.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.leading.equalTo(profileImage.snp.trailing).offset(12)
        }
        
        mainTextView.snp.makeConstraints {
            $0.top.equalTo(userNickname.snp.bottom).offset(12)
            $0.leading.equalTo(userNickname)
            $0.trailing.equalToSuperview().offset(-12)
            $0.height.equalTo(50)
        }
        
        lineBar.snp.makeConstraints {
            $0.top.equalTo(profileImage.snp.bottom).offset(16)
            $0.centerX.equalTo(profileImage)
            $0.bottom.equalToSuperview().offset(-16)
            $0.width.equalTo(2)
        }
        
        albumButton.snp.makeConstraints {
            $0.top.equalTo(mainTextView.snp.bottom).offset(16)
            $0.leading.equalTo(mainTextView)
            $0.size.equalTo(22)
        }
        
        gifButton.snp.makeConstraints {
            $0.top.equalTo(mainTextView.snp.bottom).offset(16)
            $0.leading.equalTo(albumButton.snp.trailing).offset(16)
            $0.size.equalTo(22)
        }
        
        recordButton.snp.makeConstraints {
            $0.top.equalTo(mainTextView.snp.bottom).offset(16)
            $0.leading.equalTo(gifButton.snp.trailing).offset(16)
            $0.size.equalTo(22)
        }
        
        voteButton.snp.makeConstraints {
            $0.top.equalTo(mainTextView.snp.bottom).offset(16)
            $0.leading.equalTo(recordButton.snp.trailing).offset(16)
            $0.size.equalTo(22)
        }
        
//        postButton.snp.makeConstraints {
//            $0.top.equalTo(mainTextView.snp.bottom).offset(12)
//            $0.centerX.equalToSuperview()
//            $0.size.equalTo(50)
//        }
//        
//        imageButton.snp.makeConstraints {
//            $0.top.equalTo(postButton.snp.bottom).offset(12)
//            $0.centerX.equalToSuperview()
//            $0.size.equalTo(50)
//        }
//        
//        myImageView.snp.makeConstraints {
//            $0.top.equalTo(imageButton.snp.bottom).offset(12)
//            $0.centerX.equalToSuperview()
//            $0.size.equalTo(200)
//        }
        
    }

}

extension PostViewController: PHPickerViewControllerDelegate {
    
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
                        self.myImageView.image = UIImage(data: compressedImageData) //image as? UIImage
                        self.data2.accept(compressedImageData)
                    } else {
                        print("압축된 이미지가 아닙니다 \(image?.jpegData(compressionQuality: 0.3))")
                        // 압축 실패 또는 원본 이미지가 이미 충분히 작을 때
                        self.myImageView.image = UIImage(data: (image?.jpegData(compressionQuality: 0.3))!) //image as? UIImage
                        self.data2.accept(image?.jpegData(compressionQuality: 0.3))
                        
                    }
                }
            }
        }
    }
}
