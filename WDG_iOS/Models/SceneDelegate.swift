//
//  SceneDelegate.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 10/27/23.
//

import Foundation
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let sceneUrl = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(sceneUrl)) {
                _ = AuthController.handleOpenUrl(url: sceneUrl)
            }
        }
    }
}
