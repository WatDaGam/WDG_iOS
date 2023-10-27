//
//  AuthKakao.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 10/27/23.
//

import Foundation
import Combine
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

class AuthKakao: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @MainActor
    func handleKakaoLogin() {
        Task {
            isLoggedIn = await (UserApi.isKakaoTalkLoginAvailable() ?
                                loginWithKakaoTalkApp() : loginWithoutKakaoTalkApp())
        }
    }
    @MainActor
    func handleKakaoLogout() { Task { isLoggedIn = await logoutWithKakao() } }
    func loginWithKakaoTalkApp() async -> Bool {
        await withCheckedContinuation { continuation in
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if error != nil { continuation.resume(returning: false) } else {
                    _ = oauthToken
                    continuation.resume(returning: true)
                }
            }
        }
    }
    func loginWithoutKakaoTalkApp() async -> Bool {
        await withCheckedContinuation { continuation in
            UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                if error != nil { continuation.resume(returning: false) } else {
                    _ = oauthToken
                    continuation.resume(returning: true)
                }
            }
        }
    }
    func logoutWithKakao() async -> Bool {
        await withCheckedContinuation { continuation in
            UserApi.shared.logout {(error) in
                if error != nil { continuation.resume(returning: false) } else {
                    continuation.resume(returning: true)
                }
            }
        }
    }
}
