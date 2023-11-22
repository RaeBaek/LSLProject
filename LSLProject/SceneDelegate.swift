//
//  SceneDelegate.swift
//  LSLProject
//
//  Created by 백래훈 on 11/13/23.
//

import UIKit
import RxSwift
import RxCocoa

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    let disposeBag = DisposeBag()
    
    let repository = NetworkRepository()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        
        print(UserDefaultsManager.token)
        
        if UserDefaultsManager.token == "토큰 없음" {
            rootViewController(vc: SignInViewController())
        } else {
            checkUserToken()
                .bind { value in
                    self.rootViewController(vc: value)
                }
                .disposed(by: disposeBag)
        }
    }
    
    func rootViewController(vc: UIViewController) {
        
        let rootViewController = UINavigationController(rootViewController: vc)
        
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
    }
    
    func checkUserToken() -> PublishRelay<UIViewController> {
        
        let tokenCheck = BehaviorRelay<Void>(value: ())
        let statusCode = PublishRelay<Int>()
        let statusMessage = PublishRelay<String>()
        let viewController = PublishRelay<UIViewController>()//PublishRelay<UIViewController>()
        
        tokenCheck
            .flatMap { _ in
                self.repository.requestAccessToken()
            }
            .subscribe(onNext: { value in
                switch value {
                case .success(let data):
                    print("토큰 갱신완료!!")
                    UserDefaultsManager.token = data.token
                    UserDefaultsManager.refreshToken = data.refreshToken
                    statusCode.accept(200)
                    
                case .failure(let error):
                    guard let accessTokenError = AccessTokenError(rawValue: error.rawValue) else {
                        // 공통 에러일 때 420, 429, 444, 500
                        statusCode.accept(error.rawValue)
                        viewController.accept(SignInViewController())
                        print("심각한 공통에러입니다. 확인해주세요!")
                        return
                    }
                    // 커스텀한 에러일 때 401, 403, 409, 418
                    print("커스텀 에러입니다.")
                    print("에러 코드 \(accessTokenError.rawValue)")
                    print("에러 메시지 \(accessTokenError.message)")
                    statusCode.accept(accessTokenError.rawValue)
                    statusMessage.accept(accessTokenError.message)
//                    viewController.accept(SignInViewController())
                }
            })
            .disposed(by: disposeBag)

        statusCode
            .map { $0 == 200 }
            .filter { $0 }
            .bind { _ in
                print("토큰이 만료되어 갱신하였고 정상적으로 자동 로그인을 수행하였습니다.")
                viewController.accept(MainHomeViewController())
            }
            .disposed(by: disposeBag)
        
        statusCode
            .map { $0 == 409 }
            .filter { $0 }
            .bind { _ in
                viewController.accept(MainHomeViewController())
                print("액세스 토큰이 만료되지 않았습니다. 기존의 토큰을 유지합니다.")
            }
            .disposed(by: disposeBag)
        
        return viewController
        
    }
    
    func changeRootVC(_ vc: UIViewController, animated: Bool) {
        guard let window = self.window else { return }
        
        let rootViewController = UINavigationController(rootViewController: vc)
        window.rootViewController = rootViewController // 전환
        
        UIView.transition(with: window, duration: 0.2, options: [.transitionCrossDissolve], animations: nil, completion: nil)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

