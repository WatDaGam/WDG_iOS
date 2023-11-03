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
    @Published var isLoggedIn: Bool
    @Published var isNewAccount: Bool
    @Published var loginFailedAlert: Bool
    var tokenModel: TokenModel // @EnvironmentObject 대신 일반 프로퍼티로 변경
    init(tokenModel: TokenModel, isLoggedIn: Bool = false, isNewAccount: Bool = false, loginFailedAlert: Bool = false) {
        self.tokenModel = tokenModel
        self.isLoggedIn = isLoggedIn
        self.isNewAccount = isNewAccount
        self.loginFailedAlert = loginFailedAlert
    }
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
                        print(httpResponse.allHeaderFields)
                        let accessToken = httpResponse.headers["Authorization"] ?? ""
                        let refreshToken = httpResponse.headers["Refresh-Token"] ?? ""
                        let accessExpire = httpResponse.headers["Access-Expiration-Time"] ?? ""
                        let refreshExpire = httpResponse.headers["Refresh-Expiration-Time"] ?? ""
                        if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 {
                            continuation.resume(returning: false)
                        } else if httpResponse.statusCode == 201 {
                            self.isNewAccount = true
                            self.tokenModel.saveAllToken(access: accessToken, refresh: refreshToken)
                            self.tokenModel.saveToken(accessExpire, type: "accessExpire")
                            self.tokenModel.saveToken(refreshExpire, type: "refreshExpire")
                            continuation.resume(returning: true)
                        } else {
                            self.isNewAccount = true // 닉네임 설정 뷰 개발 위해 임시 적용
                            self.tokenModel.saveAllToken(access: accessToken, refresh: refreshToken)
                            self.tokenModel.saveToken(accessExpire, type: "accessExpire")
                            self.tokenModel.saveToken(refreshExpire, type: "refreshExpire")
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
            await tokenModel.validateToken(authModel: self)
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
//    @MainActor
//    func validateToken() {
//        Task {
//            self.isValidToken = await reissuanceAccessToken()
//            if !self.isValidToken { handleLogout() }
//        }
//    }
//    func reissuanceAccessToken() async -> Bool {
//        guard let accessExpireStr = self.tokenModel.getToken("accessExpire"),
//              let accessExpireDouble = Double(accessExpireStr) else {
//            print("No access token or invalid date format")
//            return false
//        }
//        guard let refreshExpireStr = self.tokenModel.getToken("refreshExpire"),
//              let refreshExpireDouble = Double(refreshExpireStr) else {
//            print("No access token or invalid date format")
//            return false
//        }
//        let refreshExpire = refreshExpireDouble / 1000
//        if refreshExpire < Date().timeIntervalSince1970 { return false }
//        let beforeAccessExpire = accessExpireDouble / 1000
//        if beforeAccessExpire - Date().timeIntervalSince1970 < 10 {
//            guard let reissuanceURL = URL(string: "http://52.78.126.48:8080/refreshtoken") else {
//                print("Invalid URL")
//                return false
//            }
//            let beforeRefreshToken = self.tokenModel.getToken("refreshToken") ?? ""
//            var request = URLRequest(url: reissuanceURL)
//            request.addValue(beforeRefreshToken, forHTTPHeaderField: "Refresh-Token")
//            do {
//                let (_, response) = try await URLSession.shared.data(for: request)
//                guard let httpResponse = response as? HTTPURLResponse else {
//                    print("Invalid response")
//                    return false
//                }
//                print("statusCode :", httpResponse.statusCode)
//                if httpResponse.statusCode != 200 {
//                    return false
//                }
//                let accessToken = httpResponse.headers["Authorization"] ?? ""
//                let accessExpire = httpResponse.headers["Access-Expiration-Time"] ?? ""
//                self.tokenModel.saveToken(accessToken, type: "accessToken")
//                self.tokenModel.saveToken(accessExpire, type: "accessExpire")
//                return true
//            } catch {
//                print("Fetch failed: \(error.localizedDescription)")
//                return false
//            }
//        }
//        return true
//    }
}
