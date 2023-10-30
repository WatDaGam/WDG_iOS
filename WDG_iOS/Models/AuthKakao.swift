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
    @Published var isNewAccount: Bool = false
    @MainActor
    func handleKakaoLogin() {
        Task {
            isLoggedIn = await (UserApi.isKakaoTalkLoginAvailable() ?
                                loginWithKakaoTalkApp() : loginWithoutKakaoTalkApp())
        }
    }
    @MainActor
    func handleKakaoLogout() {
        Task {
            let result = await !logoutWithKakao()
            DispatchQueue.main.async { self.isLoggedIn = result }
        }
    }
    func loginWithKakaoTalkApp() async -> Bool {
        await withCheckedContinuation { continuation in
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if error != nil { continuation.resume(returning: false) } else {
                    let accessToken = oauthToken?.accessToken // 백엔드에 전달할 토큰
//                    let result = getLoginInfoWithKakao(accessToken)
                    continuation.resume(returning: true)
//                    continuation.resume(returning: result)
                }
            }
        }
    }
    func loginWithoutKakaoTalkApp() async -> Bool {
        await withCheckedContinuation { continuation in
            UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                if error != nil { continuation.resume(returning: false) } else {
                    let accessToken = oauthToken?.accessToken // 백엔드에 전달할 토큰
//                    let result = getLoginInfoWithKakao(accessToken)
                    continuation.resume(returning: true)
//                    continuation.resume(returning: result)
                }
            }
        }
    }
//    func getLoginInfoWithKakao(accessToken: String) async -> Bool {
//        await withCheckedContinuation { continuation in
//            backendApi.login(accessToken) {(response) in
//                if response.status != 200 || response.status != 201 { continuation.resume(returning: false) }
//                else if response.status == 201 {
//                    isNewAccount = true
//                    continuation.resume(returning: true)
//                } else { continuation.resume(returning: true) }
//            }
//        }
//    }
    func logoutWithKakao() async -> Bool {
        await withCheckedContinuation { continuation in
            UserApi.shared.logout {(error) in
                if error != nil { continuation.resume(returning: false) } else {
                    continuation.resume(returning: true)
                }
            }
        }
    }
    func deleteAccountWithKakao() async -> Bool {
        await withCheckedContinuation { continuation in
            UserApi.shared.logout {(error) in
                if error != nil { continuation.resume(returning: false) } else {
                    // 백엔드로 회원 탈퇴 보내기, ourToken
                    continuation.resume(returning: true)
                }
            }
        }
    }
}
