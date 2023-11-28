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
    
    let mainTextView = {
        let view = UITextView()
        view.textColor = .black
        view.font = .systemFont(ofSize: 15, weight: .regular)
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
    
//    private var itemProviders: [NSItemProvider] = []
    
    let viewModel = PostViewModel(repository: NetworkRepository())
    
    var data: Data? = Data()
    
//    lazy var data2 = BehaviorSubject(value: data)
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBar()
        
        print("ㅇㅇㅇ...")
        bind()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    private func bind() {
        
        let input = PostViewModel.Input(postButtonTap: postButton.rx.tap, imageButtonTap: imageButton.rx.tap, textView: mainTextView.rx.text.orEmpty, imageData: BehaviorRelay(value: data))
        let output = viewModel.transform(input: input)
        
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
    
    private func test() {
        
        
        
    }
    
    private func presentPicker() {
        
        var configuration = PHPickerConfiguration()
        // 🎆 selectionLimit
        // 🎆 유저가 선택할 수 있는 에셋의 최대 갯수. 기본값 1. 0 설정시 제한은 시스템이 지원하는 최대값으로 설정.
        configuration.selectionLimit = 1

        // 🎆 filter
        // 🎆 picker 가 표시하는 에셋 타입 제한을 적용. 기본적으로 모든 에셋 유형을 표시(이미지, 라이브포토, 비디오)
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
        
        [mainTextView, myImageView, postButton, imageButton].forEach {
            view.addSubview($0)
        }
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        mainTextView.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(12)
            $0.height.equalTo(50)
        }
        
        postButton.snp.makeConstraints {
            $0.top.equalTo(mainTextView.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(50)
        }
        
        imageButton.snp.makeConstraints {
            $0.top.equalTo(postButton.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(50)
        }
        
        myImageView.snp.makeConstraints {
            $0.top.equalTo(imageButton.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(200)
        }
        
    }

}

extension PostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // 🎆 선택완료 혹은 취소하면 뷰 dismiss.
        picker.dismiss(animated: true, completion: nil)
        
        // 🎆 itemProvider 를 가져온다.
        let itemProvider = results.first?.itemProvider
        if let itemProvider = itemProvider,
           // 🎆 itemProvider 에서 지정한 타입으로 로드할 수 있는지 체크
           itemProvider.canLoadObject(ofClass: UIImage.self) {
            // 🎆 loadObject() 메서드는 completionHandler 로 NSItemProviderReading 과 error 를 준다.
            itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                
                // 🎆 itemProvider 는 background asnyc 작업이기 때문에 UI 와 관련된 업데이트는 꼭 main 쓰레드에서 실행해줘야 합니다.
                DispatchQueue.main.sync { [weak self] in
                    guard let self else { return }
                    self.myImageView.image = image as? UIImage
                    
                    var imageFile: UIImage? = nil
                    
                    guard let image = self.myImageView.image else {
                        print("")
                        print("=======================")
                        print("image file is nil....")
                        print("=======================")
                        return
                    }
                    
                    imageFile = image
                    print(imageFile?.jpegData(compressionQuality: 0.5))
                    
                    let pngData = imageFile?.jpegData(compressionQuality: 0.5)
                    print(pngData)
                    
                    self.data = pngData
                    
//                    if let image = self.myImageView.image {
//                        print("이거지~")
//                        imageFile = image
//                        print(imageFile?.pngData())
//                    } else {
//                        
//                        return
//                    }
//                    
//                    let pngData = imageFile?.pngData()
//                    
//                    self.data = pngData!
                    
                    
                    
                }
            }
        }
    }
    
    
}
