//
//  SetNicknameViewModel.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 10/31/23.
//

import Foundation

class SetNicknameViewModel: ObservableObject {
    private var tokenModel: TokenModel = TokenModel()
    private var isConfirm: Bool = false
    func getIsConfirm() -> Bool { return self.isConfirm }
    func checkNicknameForm(nickname: String) -> Bool {
        // 닉네임 길이 검사
        if nickname.count < 2 {
            return false
        }
        // 영어 알파벳, 한국어 문자, 숫자만 허용하는 정규 표현식
        let pattern = "^[a-zA-Z0-9가-힣]+$"
        // 정규 표현식 검사
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return false
        }
        let range = NSRange(location: 0, length: nickname.utf16.count)
        // 정규 표현식에 일치하는지 검사
        if let match = regex.firstMatch(in: nickname, options: [], range: range) {
            // 여기서 옵셔널 바인딩으로 'match'가 nil이 아닌지 확인
            return match.range == range
        } else {
            return false
        }
    }
    func checkNickname(nickname: String) async -> Bool {
        if checkNicknameForm(nickname: nickname) {
            // 백엔드로 중복 검사 체크
            print("checkNickname")
            let serverURLString = Bundle.main.infoDictionary?["SERVER_URL"] as? String ?? ""
            guard let requestURL = URL(string: "https://\(serverURLString)/nickname/check") else {
                print("Invalid URL")
                return false
            }
            let accessToken = self.tokenModel.getToken("tempAccessToken") ?? ""
            var request = URLRequest(url: requestURL)
            request.httpMethod = "POST"
            request.addValue(accessToken, forHTTPHeaderField: "Authorization")
            request.addValue("text/plain", forHTTPHeaderField: "Content-Type")
            request.httpBody = nickname.data(using: .utf8)
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response")
                    self.isConfirm = false
                    return false
                }
                if let responseBody = String(data: data, encoding: .utf8) {
                    print("Response Body: \(responseBody)")
                } else {
                    print("Unable to parse response body")
                }
                self.isConfirm = httpResponse.statusCode == 200
                return httpResponse.statusCode == 200
            } catch {
                print("Fetch failed: \(error.localizedDescription)")
                return false
            }
        } else {
            self.isConfirm = false
            return false
        }
    }
    func setNickname(nickname: String) async -> Bool {
        if checkNicknameForm(nickname: nickname) {
            let serverURLString = Bundle.main.infoDictionary?["SERVER_URL"] as? String ?? ""
            guard let requestURL = URL(string: "https://\(serverURLString)/nickname/set") else {
                print("Invalid URL")
                return false
            }
            let accessToken = self.tokenModel.getToken("tempAccessToken") ?? ""
            var request = URLRequest(url: requestURL)
            request.httpMethod = "POST"
            request.addValue(accessToken, forHTTPHeaderField: "Authorization")
            request.addValue("text/plain", forHTTPHeaderField: "Content-Type")
            request.httpBody = nickname.data(using: .utf8)
            do {
                let (_, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response")
                    return false
                }
                let accessToken = httpResponse.headers["Authorization"] ?? ""
                let refreshToken = httpResponse.headers["Refresh-Token"] ?? ""
                let accessExpire = httpResponse.headers["Access-Expiration-Time"] ?? ""
                let refreshExpire = httpResponse.headers["Refresh-Expiration-Time"] ?? ""
                self.tokenModel.saveAllToken(access: accessToken, refresh: refreshToken)
                self.tokenModel.saveToken(accessExpire, type: "accessExpire")
                self.tokenModel.saveToken(refreshExpire, type: "refreshExpire")
                return httpResponse.statusCode == 200
            } catch {
                print("Fetch failed: \(error.localizedDescription)")
                return false
            }
        } else {
            return false
        }
    }
}
