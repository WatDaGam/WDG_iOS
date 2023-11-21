//
//  UserInfo.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 11/20/23.
//

import Foundation

class UserInfo: ObservableObject {
    private var nickname: String = ""
    private var storyNum: Int = 0
    private var likeNum: Int = 0
    var tokenModel: TokenModel
    var authModel: AuthModel
    init(tokenModel: TokenModel, authModel: AuthModel) {
        self.tokenModel = tokenModel
        self.authModel = authModel
    }
    func getUserNickname() -> String { return self.nickname }
    func getUserStoryNum() -> Int { return self.storyNum }
    func getUserLikeNum() -> Int { return self.likeNum }
    func getUserInfo() async -> Bool {
        await tokenModel.validateToken(authModel: authModel)
        guard let userInfoURL = URL(string: "http://3.35.136.131:8080/userInfo") else {
            print("Invalid URL")
            return false
        }
        let accessToken = self.tokenModel.getToken("accessToken") ?? ""
        var request = URLRequest(url: userInfoURL)
        request.httpMethod = "GET"
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
                let responseNickname = httpResponse.allHeaderFields["nickname"] as? String ?? ""
                let responseStoryNum = (httpResponse.allHeaderFields["storyNum"] as? String).flatMap(Int.init) ?? 0
                let responseLikeNum = (httpResponse.allHeaderFields["likeNum"] as? String).flatMap(Int.init) ?? 0
                if responseNickname != "" {
                    DispatchQueue.main.async {
                        self.nickname = responseNickname
                        self.storyNum = responseStoryNum
                        self.likeNum = responseLikeNum
                    }
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
