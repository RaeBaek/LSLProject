# Threads - 텍스트 기반 대화 앱
<img width="933" alt="스크린샷 2023-12-23 17 30 58" src="https://github.com/RaeBaek/LSLProject/assets/88128192/6855a5cd-2fce-423e-9191-e0c4828592ba">
</br>

## 📸 Screen Shot
<img width="933" alt="스크린샷 2023-12-29 20 04 31" src="https://github.com/RaeBaek/LSLProject/assets/88128192/f25d450e-3d2d-4025-9eb9-0e887fb6bb2d">
</br>

## 📄 한 줄 소개
어떠한 주제든 생각을 공유할 수 있는 텍스트 기반 대화 앱 Threads입니다.
</br>
</br>

## 📃 서비스 특징
- 로그인 기능을 제공하고 있으며 회원가입이 필요한 서비스
- 현재 내 생각에 대한 게시글 작성, 수정, 삭제 가능
- 홈 화면에서 다른 사용자가 작성한 게시글 확인 가능
- 게시글에 대한 답글 작성, 수정, 삭제 가능
- 게시글에 대한 좋아요 / 좋아요 취소 가능
- 다른 유저 프로필 방문을 통해 작성한 게시글 확인 및 팔로우 가능
- 내가 좋아요한 게시글들을 좋아요 탭에서 확인 가능
- 내 프로필 화면을 통해 내 프로필 조회 및 편집이 가능하며 설정 버튼을 통해 로그아웃, 회원탈퇴 가능
</br>

## 📝 개발환경 및 기간
- 기획: SeSAC Memolease (API 제공)
- 디자인: Threads 클론
- 개발: 1인 개발
- Swift 5.9
- Xcode 15.0.1
- Deployment Target iOS 17.0
- 2023.11.13 ~ 2023.12.17 (35일간, 약 5주)
</br>

## 🛠️ 기술스택 및 라이브러리
- RxSwift, RxCocoa, RxDataSources, UIKit, Snapkit, Kingfisher
- UserDefaults, Repository, Protocol
- MVVM, In-Out Pattern
- Moya, Alamofire, RequestInterceptor, Codable
</br>

## 📻 API
- 회원인증
    - 회원가입, 이메일 중복 확인, 로그인, Access Token 갱신, 회원탈퇴
- 포스트(게시글)
    - 포스트 작성, 조회, 수정, 삭제, 유저별 작성한 포스트 조회
- 댓글(코멘트)
    - 댓글 작성, 수정, 삭제
- 좋아요
    - 포스트 좋아요 / 좋아요 취소
    - 좋아요한 포스트 조회
- 팔로우
    - 팔로우 / 언팔로우
- 프로필
    - 내 프로필 조회, 수정, 다른 유저 프로필 조회
</br>

## ⚽️ 트러블 슈팅
### Alamofire의 RequestInterceptor를 사용하면서 겪었던 Schedulers의 선택
- 이번 프로젝트에서는 Moya를 사용해 보았는데 Moya는 Alamofire를 한 번 더 추상화한 라이브러리이다.
- Alamofire를 추상화했기에 Moya에서도 Alamofire의 여러 기능을 사용할 수 있으며 RequestInterceptor를 사용했다.
- RequestInterceptor을 사용한 이유는 로그인 시 token과 refreshToken 관리를 위해 사용하였다.
- token은 만료되었지만 refreshToken은 아직 유효하다면 refreshToken을 이용하여 token을 갱신하는 방법을 사용할 수 있다.
- 갱신을 위해 RequestInterceptor 프로토콜을 다루며 겪었던 Trouble Shooting은 아래의 코드로 확인 가능하다.

### 수정 전 코드
- retry 메서드 내 .observe(on: MainScheduler.asyncInstance), MainScheduler 선언
- .observe(on: MainScheduler.asyncInstance) 미 선언 시 moya의 sync error 발생
- MainScheduler로 작성하고 넘어갔었지만 추후 네트워크 작업을 Main Thread에서 해주는 것이 과연 올바른 코드일까라는 의문을 제기
```ruby
import Foundation
import Alamofire
import RxSwift

final class SeSACRequestInterceptor: RequestInterceptor {
    
    static let shared = SeSACRequestInterceptor()
    
    private init() { }
    
    let repository = NetworkRepository()
    
    let disposeBag = DisposeBag()
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        guard urlRequest.url?.absoluteString.hasPrefix(APIKey.sesacURL) == true else {
            completion(.success(urlRequest))
            return
        }
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 419 else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        let task = Observable.just(())
        
        task
            .observe(on: MainScheduler.asyncInstance)
            .flatMap { _ in
                self.repository.requestAccessToken()
            }
            .subscribe(onNext: { result in
                switch result {
                case .success(let data):
                    print(UserDefaultsManager.token)
                    UserDefaultsManager.token = data.token
                    completion(.retry)
                case .failure(let error):
                    completion(.doNotRetryWithError(error))
                }
            })
            .disposed(by: disposeBag)
    }
}
```

### 수정 후 코드
- 수정 전에는 Scheduler의 개념과 종류를 잘 모르고 단순 동작을 위해 MainScheduler로 작성하였다.
- RxSwift의 Scheduler에 대해 찾아보니 SerialDispatchQueueScheduler가 있었고
- MainScheduler는 SerialDispatchQueueScheduler의 인스턴스 중 하나임을 알게되었다.
- 또한 SerialDispatchQueueScheduler는 qos를 사용할 수 있는데
- qos의 종류 중 userInitiated가 API 통신에 적합함을 확인하였다.
```ruby
let task = Observable.just(())

task
    .observe(on: SerialDispatchQueueScheduler.init(qos: .userInitiated))
    .withUnretained(self)
    .flatMap { owner, _ in
        owner.repository.requestAccessToken()
    }
    .subscribe(onNext: { result in
        switch result {
        case .success(let data):
            print(UserDefaultsManager.token)
            UserDefaultsManager.token = data.token
            completion(.retry)
        case .failure(let error):
            completion(.doNotRetryWithError(error))
        }
    })
    .disposed(by: disposeBag)
```
</br>

## 📌 회고
- 많은 경험을 할 수 있었던 프로젝트이지 않았을까?
    - 이번 프로젝트에서는 Moya를 사용하였고 Moya의 'TargetType' 프로토콜을 사용함으로써 Network Layer를 템플릿 화하여 재사용성을 높이고 request, response에 집중할 수 있었다.
    - 멘토 분들께서 직접 서버를 구성하시고 API 명세서를 제공해 주셔서 백엔드와 클라이언트의 협업 느낌을 받을 수 있었다.
    - API 명세서를 제공받으며 Restful 한 API를 구현할 수 있었으며 HTTP Method(GET, POST, PUT, DELETE)를 모두 사용해 볼 수 있었다.
    - 개발을 진행하며 전체 포스트에 대한 API는 있었으나 포스트 개별 API는 없었는데 게시물에 대한 detail 화면을 보여줘야 했던 나의 프로젝트에서는 개별 포스트에 대한 API가 필요하여 멘토 분들에게 요청을 드렸고 실제 현업에서도 백엔드 개발자와 API 요청 건으로 많은 대화를 나눈다고 말씀해 주시고 개별 포스트 API 또한 추가해 주셨다.
    - 본인뿐만이 아닌 다른 수강생분들도 사용하는 공용 API이기에 구현하고자 하는 프로젝트에서 REST API의 Overfetcing과 Underfetching을 경험할 수 있었다.
    - 또한 MVVM 구조로 개발하며 RxSwift와 In-Out Pattern을 사용하여 비동기적 코드를 작성하였다.
    - 이전까지 RxSwift를 사용해 본 적이 없었으나 이번 프로젝트를 진행하면서 RxSwift, RxCocoa, MVVM 구조, In-OutPut Pattern들을 다양하게 프로젝트에 녹여보면서 이전 프로젝트와는 다른 경험을 할 수 있었던 것 같다.

- Moya의 TargetType 활용
```ruby
extension SeSACAPI: TargetType {

    var baseURL: URL {
        URL(string: APIKey.sesacURL)!
    }
    
    var path: String {
        switch self {
        case .signUp:
            return "join"  
        ...
        
        case .like(let model):
            return "post/like/\(model.id)"
        ...
          
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .accessToken, .withdraw, .allPost, .downloadImage, .myProfile, .userPosts, .userProfile, .aPost, .likes:
            return .get
            
        case .signUp, .emailValidation, .login, .postAdd, .commentAdd, .follow, .like:
            return .post
            
        case .postEdit, .profileEdit, .commentEdit:
            return .put
        
        case .postDel, .commentDel, .unfollow:
            return .delete
            
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .signUp(let model):
            return .requestJSONEncodable(model)
        ...
            
        case .accessToken, .withdraw, .downloadImage, .myProfile, .userPosts, .postDel, .userProfile, .follow, .likes, .unfollow, .aPost, .like:
            return .requestPlain
            
        case .allPost(let model):
            return .requestParameters(parameters: ["next": model.next, "limit": model.limit, "product_id": model.productID], encoding: URLEncoding.queryString)
            
        case .postAdd(let model), .postEdit(let model, _):
            if let file = model.file {
                let imageData = MultipartFormData(provider: .data(file), name: "file", fileName: "image.jpg", mimeType: "image/jpg")
                let title = MultipartFormData(provider: .data((model.title?.data(using: .utf8)!) ?? Data()), name: "title")
                let productId = MultipartFormData(provider: .data((model.productID?.data(using: .utf8)!)!), name: "product_id")
                
                return .uploadMultipart([imageData, title, productId])
                
            } else {
                let title = MultipartFormData(provider: .data((model.title?.data(using: .utf8)!)!), name: "title")
                let productId = MultipartFormData(provider: .data((model.productID?.data(using: .utf8)!)!), name: "product_id")
                
                return .uploadMultipart([title, productId])
            }
        }
    }
    
    var headers: [String : String]? {
        let key = APIKey.sesacKey
        let token = UserDefaultsManager.token
        let refreshToken = UserDefaultsManager.refreshToken
        
        switch self {
        case .signUp, .emailValidation, .login:
            return ["Content-Type": "application/json", "SesacKey": key]
            ...
            
        case .postAdd, .postEdit, .profileEdit:
            return ["Authorization": token, "SesacKey": key, "Content-Type": "multipart/form-data"]
        }
        
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
    
}
```
- In-Output Pattern 활용
```ruby
final class BirthdayViewModel: ViewModelType {
    
    struct Input {
        let inputText: ControlProperty<Date>
        let nextButtonClicked: ControlEvent<Void>
        let skipButtonClicked: ControlEvent<Void>
    }
    
    struct Output {
        let statusText: BehaviorRelay<String>
        let textStatus: PublishRelay<Bool>
        let borderStatus: PublishRelay<Bool>
        let loginStatus: PublishRelay<Bool>
    }
    
    func transform(input: Input) -> Output {
        ...
    }
}

final class BirthdayViewController: BaseViewController {

    private let viewModel = BirthdayViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        
    }
    
    func bind() {
        let input = BirthdayViewModel.Input(inputText: datePicker.rx.value,
                                    nextButtonClicked: nextButton.rx.tap,
                                    skipButtonClicked: skipButton.rx.tap)
        
        let output = viewModel.transform(input: input)
        
        output.textStatus
            .withUnretained(self)
            .bind { owner, value in
                owner.statusLabel.isHidden = value
            }
            .disposed(by: disposeBag)
        
        output.borderStatus
            .withUnretained(self)
            .bind { owner, value in
                owner.customTextField.layer.borderColor = value ? UIColor.systemGray4.cgColor : UIColor.systemRed.cgColor
            }
            .disposed(by: disposeBag)
        ...
    
    }
}
```

- RxSwift를 활용한 로그인 버튼 클릭 시 Stream 연결 및 API 호출
```ruby
input.signInButtonClicked
    .withLatestFrom(input.emailText) { _, email in
        return email
    }
    .withLatestFrom(input.passwordText) { email, password in
        return (email, password)
    }
    .withUnretained(self)
    .flatMap { owner, value in
        owner.repository.requestLogin(email: value.0, password: value.1)
    }
    .subscribe(onNext: { value in
        switch value {
        case .success(let data):
            input.token.accept(UserDefaultsManager.token)
            
        case .failure(let error):
            guard let loginError = LoginError(rawValue: error.rawValue) else {
                outputText.accept(error.message)
                textStatus.accept(false)
                borderStatus.accept(false)
                return
            }
            outputText.accept(loginError.message)
            textStatus.accept(false)
            borderStatus.accept(false)
        }
    })
    .disposed(by: disposeBag)
```
