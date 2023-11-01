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
    @Published var isNewAccount: Bool = true
    @Published var loginFailedAlert: Bool = false
    @MainActor
    func handleKakaoLogin() {
        Task {
//            isLoggedIn = await (UserApi.isKakaoTalkLoginAvailable() ?
//                                loginWithKakaoTalkApp() : loginWithoutKakaoTalkApp())
            isLoggedIn = true // 개발용
            if !isLoggedIn { loginFailedAlert = true }
        }
    }
    @MainActor
    func handleKakaoLogout() {
        Task {
//            let result = await !logoutWithKakao()
            let result = false // 개발용
            DispatchQueue.main.async { self.isLoggedIn = result }
        }
    }
    func loginWithKakaoTalkApp() async -> Bool {
        await withCheckedContinuation { continuation in
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print("Login error: \(error.localizedDescription)")
                    continuation.resume(returning: false)
                } else if let accessToken = oauthToken?.accessToken {
                    Task {
                        let result = await self.getLoginInfoWithKakao(accessToken: accessToken)
                        continuation.resume(returning: result)
                    }
                } else {
                    print("No access token available")
                    continuation.resume(returning: false)
                }
            }
        }
    }
    func loginWithoutKakaoTalkApp() async -> Bool {
        await withCheckedContinuation { continuation in
            UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                if let error = error {
                    print("Login error: \(error.localizedDescription)")
                    continuation.resume(returning: false)
                } else if let accessToken = oauthToken?.accessToken {
                    Task {
                        let result = await self.getLoginInfoWithKakao(accessToken: accessToken)
                        continuation.resume(returning: result)
                    }
                } else {
                    print("No access token available")
                    continuation.resume(returning: false)
                }
            }
        }
    }
    func getLoginInfoWithKakao(accessToken: String) async -> Bool {
        await withCheckedContinuation { continuation in
            guard let loginURL = URL(string: "https://0b88436b-a8a0-463a-bb4d-07b31d747be2.mock.pstmn.io/login?platform=KAKAO") else {
                print("Invalid URL")
                return
            }
            var request = URLRequest(url: loginURL)
            request.addValue("Bearer newValidToken", forHTTPHeaderField: "Authorization")
//            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            URLSession.shared.dataTask(with: request) { _, response, error in
                if let httpResponse = response as? HTTPURLResponse {
                    DispatchQueue.main.async {
                        if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 {
                            self.isNewAccount = true // 닉네임 설정 뷰 개발 위해 임시 적용
                            continuation.resume(returning: false)
                        } else if httpResponse.statusCode == 201 {
                            self.isNewAccount = true
                            continuation.resume(returning: true)
                        } else {
                            self.isNewAccount = true // 닉네임 설정 뷰 개발 위해 임시 적용
                            continuation.resume(returning: true)
                        }
                    }
                } else {
                    print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
                    continuation.resume(returning: false)
                }
            }.resume() // URLSession dataTask를 시작하기 위해 resume() 호출 필요
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
