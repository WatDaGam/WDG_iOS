//
//  UserInfo.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 11/20/23.
//

import Foundation

struct UserInfoResponse: Codable {
    let storyNum: Int
    let nickname: String
    let likeNum: Int
}

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
        guard let userInfoURL = URL(string: "http://43.200.68.255:8080/userInfo") else {
            print("Invalid URL")
            return false
        }
        let accessToken = self.tokenModel.getToken("accessToken") ?? ""
        var request = URLRequest(url: userInfoURL)
        request.httpMethod = "GET"
        request.addValue(accessToken, forHTTPHeaderField: "Authorization")
        do {
            let decoder = JSONDecoder()
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return false
            }
            if httpResponse.statusCode == 200 {
                let userInfoResponse = try decoder.decode(UserInfoResponse.self, from: data)
                DispatchQueue.main.async {
                    self.nickname = userInfoResponse.nickname
                    self.storyNum = userInfoResponse.storyNum
                    self.likeNum = userInfoResponse.likeNum
                }
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
