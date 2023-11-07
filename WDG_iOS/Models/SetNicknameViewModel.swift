//
//  SetNicknameViewModel.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 10/31/23.
//

import Foundation

class SetNicknameViewModel: ObservableObject {
    private var tokenModel: TokenModel = TokenModel()
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
            guard let reissuanceURL = URL(string: "http://52.78.126.48:8080/nickname/check") else {
                print("Invalid URL")
                return false
            }
            let accessToken = self.tokenModel.getToken("accessToken") ?? ""
            var request = URLRequest(url: reissuanceURL)
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
                return httpResponse.statusCode == 200
            } catch {
                print("Fetch failed: \(error.localizedDescription)")
                return false
            }
        } else {
            return false
        }
    }
    func setNickname(nickname: String) async -> Bool {
        if checkNicknameForm(nickname: nickname) {
            guard let reissuanceURL = URL(string: "http://52.78.126.48:8080/nickname/set") else {
                print("Invalid URL")
                return false
            }
            let accessToken = self.tokenModel.getToken("accessToken") ?? ""
            var request = URLRequest(url: reissuanceURL)
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
