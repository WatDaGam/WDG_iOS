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
    init(
        tokenModel: TokenModel,
        isLoggedIn: Bool = false,
        isNewAccount: Bool = false,
        loginFailedAlert: Bool = false
    ) {
        self.tokenModel = tokenModel
        self.isLoggedIn = isLoggedIn
        self.isNewAccount = isNewAccount
        self.loginFailedAlert = loginFailedAlert
        // 임시 토큰 삭제
        tokenModel.deleteToken("tempAccessToken")
        tokenModel.deleteToken("tempAccessExpire")
        // 자동로그인 처리
        Task {
            let isValidToken = await tokenModel.autoLoginValidateToken()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                if isValidToken {
                    print("자동로그인 완료")
                    self.isLoggedIn = true
                }
            }
        }
    }
    @MainActor
    func handleAppleLogin(userId: String) {
        isLoggedIn = loginWithApple(userId: userId)
        if !isLoggedIn { loginFailedAlert = true }
    }
    func loginWithApple(userId: String) -> Bool {
        print(userId)
        let serverURLString = Bundle.main.infoDictionary?["SERVER_URL"] as? String ?? ""
        guard let requestURL = URL(string: "https://\(serverURLString)/login?platform=APPLE") else {
            print("Invalid URL")
            return false
        }
        var request = URLRequest(url: requestURL)
        request.addValue("Bearer \(userId)", forHTTPHeaderField: "Authorization")
        var result = false
        let semaphore = DispatchSemaphore(value: 0) // 동기화를 위한 세마포어
        URLSession.shared.dataTask(with: request) { _, response, error in
            defer { semaphore.signal() } // 작업이 완료되면 세마포어 신호를 보냄
            if let error = error {
                print("Fetch failed: \(error.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }
            DispatchQueue.main.async {
                print(httpResponse.allHeaderFields)
                let accessToken = httpResponse.headers["Authorization"] ?? ""
                let refreshToken = httpResponse.headers["Refresh-Token"] ?? ""
                let accessExpire = httpResponse.headers["Access-Expiration-Time"] ?? ""
                let refreshExpire = httpResponse.headers["Refresh-Expiration-Time"] ?? ""

                if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                    self.tokenModel.saveAllToken(access: accessToken, refresh: refreshToken)
                    self.tokenModel.saveToken(accessExpire, type: "accessExpire")
                    self.tokenModel.saveToken(refreshExpire, type: "refreshExpire")
                    result = true
                } else {
                    print("Account deletion failed with status code: \(httpResponse.statusCode)")
                }
            }
        }.resume()
        semaphore.wait() // URLSession dataTask의 완료를 기다림
        return result
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
            let serverURLString = Bundle.main.infoDictionary?["SERVER_URL"] as? String ?? ""
            guard let loginURL = URL(string: "https://\(serverURLString)/login?platform=KAKAO") else {
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
                            self.tokenModel.saveToken(accessToken, type: "tempAccessToken")
                            self.tokenModel.saveToken(accessExpire, type: "tempAccessExpire")
                            continuation.resume(returning: true)
                        } else {
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
    func deleteAccount() async -> Bool {
        await tokenModel.validateToken(authModel: self)
        let serverURLString = Bundle.main.infoDictionary?["SERVER_URL"] as? String ?? ""
        guard let requestURL = URL(string: "https://\(serverURLString)/withdrawal") else {
            print("Invalid URL")
            return false
        }
        let accessToken = self.tokenModel.getToken("accessToken") ?? ""
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        request.addValue(accessToken, forHTTPHeaderField: "Authorization")
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return false
            }
            print(String(data: data, encoding: .utf8) ?? "No data")
            print(httpResponse.allHeaderFields)
            print("Status Code: ", httpResponse.statusCode)
            if httpResponse.statusCode == 200 {
                self.tokenModel.deleteAllToken()
                DispatchQueue.main.async {
                    self.isLoggedIn = false
                    self.isNewAccount = false
                }
                // 이 상태 변경들은 `@MainActor`로 마크된 함수나 `DispatchQueue.main.async`를 사용해야 할 수도 있습니다.
                print("Account deletion successful.")
                return true
            } else {
                print("Account deletion failed with status code: \(httpResponse.statusCode)")
                return false
            }
        } catch {
            print("Fetch failed: \(error.localizedDescription)")
            return false
        }
    }
}
