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

class AuthModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var isNewAccount: Bool = true
    @Published var loginFailedAlert: Bool = false
    private var tokenModel: TokenModel = TokenModel()
    @MainActor
    func handleKakaoLogin() {
        Task {
            isLoggedIn = await (UserApi.isKakaoTalkLoginAvailable() ?
                                loginWithKakaoTalkApp() : loginWithoutKakaoTalkApp())
            if !isLoggedIn { loginFailedAlert = true }
        }
    }
    func handleLogout() {
        self.tokenModel.deleteAllToken()
        isLoggedIn = false
        isNewAccount = false
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
            guard let loginURL = URL(string: "http://52.78.126.48:8080/login?platform=KAKAO") else {
                print("Invalid URL")
                return
            }
            var request = URLRequest(url: loginURL)
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            URLSession.shared.dataTask(with: request) { _, response, error in
                if let httpResponse = response as? HTTPURLResponse {
                    DispatchQueue.main.async {
                        let accessToken = httpResponse.headers["Authorization"] ?? ""
                        let refreshToken = httpResponse.headers["Refresh-Token"] ?? ""
                        //                        let accessExpire = httpResponse.headers["expire"] ?? ""
                        if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 {
                            continuation.resume(returning: false)
                        } else if httpResponse.statusCode == 201 {
                            self.isNewAccount = true
                            self.tokenModel.saveAllToken(access: accessToken, refresh: refreshToken)
                            //                            self.tokenModel.saveToken(accessExpire, type: "accessExpire")
                            continuation.resume(returning: true)
                        } else {
                            self.isNewAccount = true // 닉네임 설정 뷰 개발 위해 임시 적용
                            self.tokenModel.saveAllToken(access: accessToken, refresh: refreshToken)
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
    func deleteAccount() {
        Task {
            await withCheckedContinuation { continuation in
                guard let deleteURL = URL(string: "http://52.78.126.48:8080/withdrawal") else {
                    print("Invalid URL")
                    return
                }
                let accessToken = self.tokenModel.getToken("accessToken") ?? ""
                var request = URLRequest(url: deleteURL)
                request.httpMethod = "DELETE"
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                URLSession.shared.dataTask(with: request) { _, response, error in
                    if let httpResponse = response as? HTTPURLResponse {
                        DispatchQueue.main.async {
                            print(httpResponse.allHeaderFields)
                            print(httpResponse.statusCode)
                            if httpResponse.statusCode != 200 {
                                print("delete false")
                                continuation.resume(returning: false)
                            } else {
                                print("delete here")
                                continuation.resume(returning: true)
                            }
                        }
                    } else {
                        print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
                        continuation.resume(returning: false)
                    }
                }.resume()
            }
        }
        self.tokenModel.deleteAllToken()
        isLoggedIn = false
        isNewAccount = false
    }
    func reissuanceAccessToken() async -> Bool {
        await withCheckedContinuation { continuation in
            guard let accessExpireStr = self.tokenModel.getToken("accessExpire"),
                  let accessExpireDate = ISO8601DateFormatter().date(from: accessExpireStr) else {
                print("No access token or invalid date format")
                return
            }
            if Date().timeIntervalSince(accessExpireDate) < 1000 {
                guard let reissuanceURL = URL(string: "http://52.78.126.48:8080/reissuance") else {
                    print("Invalid URL")
                    return
                }
                let beforeRefreshToken = self.tokenModel.getToken("refreshToken") ?? ""
                var request = URLRequest(url: reissuanceURL)
                request.httpMethod = "POST"
                request.addValue("Bearer \(beforeRefreshToken)", forHTTPHeaderField: "Authorization")
                URLSession.shared.dataTask(with: request) { _, response, error in
                    if let httpResponse = response as? HTTPURLResponse {
                        DispatchQueue.main.async {
                            print(httpResponse.allHeaderFields)
                            print(httpResponse.statusCode)
                            let afterAccessToken = httpResponse.headers["Authorization"] ?? ""
                            let afterRefreshToken = httpResponse.headers["Refresh-Token"] ?? ""
                            if httpResponse.statusCode != 200 {
                                continuation.resume(returning: false)
                            } else {
                                self.tokenModel.saveAllToken(access: afterAccessToken, refresh: afterRefreshToken)
                                continuation.resume(returning: true)
                            }
                        }
                    } else {
                        print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
                        continuation.resume(returning: false)
                    }
                }.resume()
            }
            continuation.resume(returning: true)
        }
    }
}
