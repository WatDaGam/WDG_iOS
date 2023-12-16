//
//  TokenModel.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 11/2/23.
//

import Foundation

class TokenModel: ObservableObject {
    @Published var isValidToken: Bool = true
    let keychain = KeychainSwift()
    init() { }
    func saveToken(_ token: String, type: String) {
        keychain.set(token, forKey: type)
    }
    func saveAllToken(access: String, refresh: String) {
        keychain.set(access, forKey: "accessToken")
        keychain.set(refresh, forKey: "refreshToken")
    }
    func getToken(_ type: String) -> String? {
        return keychain.get(type)
    }
    func deleteToken(_ type: String) {
        keychain.delete(type)
    }
    func deleteAllToken() {
        keychain.delete("accessToken")
        keychain.delete("refreshToken")
        keychain.delete("accessExpire")
        keychain.delete("refreshExpire")
    }
    @MainActor
    func validateToken(authModel: AuthModel?) async {
        isValidToken = await reissuanceAccessToken()
        if !isValidToken { authModel?.handleLogout() }
    }
    @MainActor
    func autoLoginValidateToken() async -> Bool {
        return await reissuanceAccessToken()
    }
    func reissuanceAccessToken() async -> Bool {
        guard let accessExpireStr = self.getToken("accessExpire"),
              let accessExpireDouble = Double(accessExpireStr) else {
            print("No access token or invalid date format")
            return false
        }
        guard let refreshExpireStr = self.getToken("refreshExpire"),
              let refreshExpireDouble = Double(refreshExpireStr) else {
            print("No access token or invalid date format")
            return false
        }
        if self.getToken("refreshToken") == nil { return false }
        let refreshExpire = refreshExpireDouble / 1000
        if refreshExpire < Date().timeIntervalSince1970 { return false }
        let beforeAccessExpire = accessExpireDouble / 1000
        if beforeAccessExpire - Date().timeIntervalSince1970 < 10 {
            let serverURLString = Bundle.main.infoDictionary?["SERVER_URL"] as? String ?? ""
            guard let requestURL = URL(string: "https://\(serverURLString)/refreshtoken") else {
                print("Invalid URL")
                return false
            }
            let beforeRefreshToken = self.getToken("refreshToken") ?? ""
            var request = URLRequest(url: requestURL)
            request.addValue(beforeRefreshToken, forHTTPHeaderField: "Refresh-Token")
            do {
                let (_, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response")
                    return false
                }
                print("statusCode :", httpResponse.statusCode)
                if httpResponse.statusCode != 200 {
                    return false
                }
                let accessToken = httpResponse.headers["Authorization"] ?? ""
                let accessExpire = httpResponse.headers["Access-Expiration-Time"] ?? ""
                self.saveToken(accessToken, type: "accessToken")
                self.saveToken(accessExpire, type: "accessExpire")
                return true
            } catch {
                print("Fetch failed: \(error.localizedDescription)")
                return false
            }
        }
        return true
    }
}
