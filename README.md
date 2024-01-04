# Link - 텍스트 기반 대화 앱
<img width="933" alt="스크린샷 2024-01-04 16 35 54" src="https://github.com/RaeBaek/LSLProject/assets/88128192/6569504e-b674-4368-b2c0-4c319afeb9b4">
</br>

## 📸 Screen Shot
<img width="933" alt="스크린샷 2024-01-04 21 41 32" src="https://github.com/RaeBaek/LSLProject/assets/88128192/3556e7f0-492a-42d8-97a5-9c3ada9ebec6">
</br>

## 📄 한 줄 소개
어떠한 주제든 생각을 공유할 수 있는 텍스트 기반 대화 앱 Link입니다.
</br>
</br>

## 📃 서비스 특징
- 회원인증: 로그인 기능을 제공하고 있으며 회원가입이 필요한 서비스
- 게시글: 현재 내 생각에 대한 게시글 작성, 수정, 삭제 가능
- 전체 게시글: 홈 화면에서 다른 사용자가 작성한 게시글 확인 가능
- 답글: 게시글에 대한 답글 작성, 수정, 삭제 가능
- 좋아요: 게시글에 대한 좋아요 / 좋아요 취소 가능
- 팔로우: 다른 유저 프로필 방문을 통해 작성한 게시글 확인 및 팔로우 가능
- 좋아요 목록: 내가 좋아요한 게시글들을 좋아요 탭에서 확인 가능
- 마이 프로필: 내 프로필 화면을 통해 내 프로필 조회 및 편집이 가능하며 설정 버튼을 통해 로그아웃, 회원탈퇴 가능
</br>

## ⚙️ 핵심 기능
- Moya의 **TargetType**을 채택하여 **Router Pattern** 구성
- Alamofire의 **RequestInterceptor**을 사용하여 token 확인 및 갱신 후 **자동 로그인** 구현
- **RxDataSources**를 활용해 **2개 이상**의 UITableView **Section**에 대해 대응
- RxCocoa의 **prefetchRows**를 활용하여 **페이지네이션** 구현
- jpegData의 **compressionQuality**를 활용하여 이미지를 1MB까지 **압축**시켜 서버에 업로드
- Kingfisher의 AnyModifier를 활용해 **이미지 캐싱 및 다운로드** 구현
- **시간 복잡도**를 고려하여 **Dictionary**를 활용한 **실시간 좋아요 및 답글** 상태 확인 구현
- NotificationCenter를 활용해 **게시글, 답글 작성 시 데이터 갱신** 구현
- propertyWrapper를 사용하여 반복되는 **UserDefaults 사용자 정보** 코드를 간결하게 구성
- **UIKeyboardLayoutGuide**을 활용한 게시글 및 답글 게시, 완료 버튼 구성
</br>

## 📝 개발환경 및 기간
- 기획: SeSAC Memolease (API 제공)
- 디자인 및 개발: 1인 개발
- Swift 5.9
- Xcode 15.0.1
- Mininum Deployment Target iOS 17.0
- 2023.11.13 ~ 2023.12.17 (35일간, 약 5주)
</br>

## 🛠️ 기술스택
- RxSwift, RxCocoa, RxDataSources, UIKit
- MVVM, In-Out Pattern
- Moya, Alamofire, RequestInterceptor, Codable
- Snapkit, Kingfisher
- UserDefaults, Repository, Protocol, PropertyWrapper
</br>

## 📻 API
- **회원인증**
    - 회원가입, 이메일 중복 확인, 로그인, Access Token 갱신, 회원탈퇴
- **포스트(게시글)**
    - 포스트 작성, 조회, 수정, 삭제, 유저별 작성한 포스트 조회
- **댓글(코멘트)**
    - 댓글 작성, 수정, 삭제
- **좋아요**
    - 포스트 좋아요 / 좋아요 취소
    - 좋아요한 포스트 조회
- **팔로우**
    - 팔로우 / 언팔로우
- **프로필**
    - 내 프로필 조회, 수정, 다른 유저 프로필 조회
</br>

## ⚽️ 트러블 슈팅
### Alamofire의 RequestInterceptor를 사용하면서 겪었던 Schedulers의 선택
- 이번 프로젝트에서는 Moya를 사용해 보았는데 Moya는 Alamofire를 한 번 더 추상화한 라이브러리이다.
- Alamofire를 추상화했기에 Moya에서도 Alamofire의 여러 기능을 사용할 수 있으며 RequestInterceptor를 사용하였다.
- RequestInterceptor을 사용한 이유는 로그인 시 token과 refreshToken 관리를 위해 사용하였다.
- token은 만료되었지만 refreshToken은 아직 유효하다면 refreshToken을 이용하여 token을 갱신하는 방법을 사용하였다.
- 갱신을 위해 RequestInterceptor 프로토콜을 다루며 겪었던 Trouble Shooting은 아래의 코드로 확인 가능하다.

### 수정 전 코드
- retry 메서드 내 .observe(on: MainScheduler.asyncInstance), MainScheduler 선언
- .observe(on: MainScheduler.asyncInstance) 미 선언 시 moya의 sync error 발생
- MainScheduler로 작성하고 넘어갔었지만 추후 네트워크 작업을 Main Thread에서 해주는 것이 과연 올바른 코드일까라는 의문을 제기
```ruby
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
func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
    guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 419 else {
        completion(.doNotRetryWithError(error))
        return
    }
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
    }
}
```
</br>

## 📌 회고
- 프로젝트 후기
- 많은 경험과 성장을 할 수 있었던 프로젝트
    - 이번 프로젝트에서는 Moya를 사용하였고 Moya의 **TargetType** 프로토콜을 사용함으로써 Network Layer를 템플릿 화하여 재사용성을 높이고 request, response에 집중할 수 있었다.
    - 멘토 분들께서 직접 서버를 구성하시고 API 명세서를 제공해 주셔서 백엔드와 클라이언트의 **협업**을 경험할 수 있었다.
    - API 명세서를 제공받으며 Restful API를 구현할 수 있었으며 HTTP Method(GET, POST, PUT, DELETE)를 모두 사용해 볼 수 있었다.
    - 개발을 진행하며 전체 포스트에 대한 API는 있었으나 포스트 개별 API는 없었는데 게시물에 대한 detail 화면을 보여줘야 했던 나의 프로젝트에서는 개별 포스트에 대한 API가 필요하여 멘토 분들에게 **요청**드렸고 실제 현업에서도 백엔드 개발자와 API 요청 건으로 많은 대화를 나눈다고 말씀해 주시고 개별 포스트 API를 추가해 주셨다.
    - 또한 **MVVM** 구조로 개발하며 RxSwift와 **In-Out Pattern**을 사용하여 비동기적 코드를 작성하였다.
    - 이전까지 RxSwift를 사용해 본 적이 없었으나 이번 프로젝트를 진행하면서 RxSwift, RxCocoa, MVVM 구조, In-OutPut Pattern들을 다양하게 프로젝트에 녹여보면서 이전과는 다른 경험을 할 수 있었던 것 같다.
    
- 아쉬웠던 점
- Rest API 요청 시 Overfetcing과 Underfetching의 경험
    - 공용 API였던 것 만큼 Overfetcing과 Underfetching을 경험할 수 있었다.
    - 내 프로필 화면에서 API를 2개 호출했어야했던 Underfetching
    - 개별 포스트 조회 API가 추가되기 전 까지 게시글 디테일 화면은 전체 포스트에서 해당하는 게시글 id를 비교 후 데이터를 바인딩했었던 Overfetcing 정도가 있었다.
    - swift에서 Overfetcing과 Underfetching 해결에 대해 구글링해보니 GraphQL이란 것이 있었고 Restful API의 단점을 해소할 수 있는 기술인 것 같았다.
    - 또한 iOS에서는 GraphQL을 편리하게 사용할 수 있는 Apollo 라이브러리를 확인할 수 있었다.
    - 하지만 새로운 기술을 적용할 시간이 많지는 않았던 이번 프로젝트였기에 적용하지 못한 부분이 아쉬웠다.
    - 끝으로 다음 프로젝트에서는 Apollo 라이브러리를 사용한 GraphQL 기술을 적용시켜 네트워크 통신을 해보면 좋을 것 같다는 회고를 남긴다!

<details>
    <summary>Moya의 TargetType 활용</summary>

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

</details>

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
