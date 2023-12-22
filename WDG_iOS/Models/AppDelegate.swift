//
//  AppDelegate.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 10/27/23.
//

import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import UIKit
import SwiftUI
import SwiftUI_Snackbar
import GoogleMobileAds

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:
                     [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let kakaoAppKey = Bundle.main.infoDictionary?["KAKAO_NATIVE_APP_KEY"] ?? ""
        KakaoSDK.initSDK(appKey: kakaoAppKey as! String)
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        return true
    }
    func application(_ application: UIApplication, open appUrl: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if (AuthApi.isKakaoTalkLoginUrl(appUrl)) {
            return AuthController.handleOpenUrl(url: appUrl)
        }
        return false
    }
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfiguration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfiguration.delegateClass = SceneDelegate.self
        return sceneConfiguration
    }
}
