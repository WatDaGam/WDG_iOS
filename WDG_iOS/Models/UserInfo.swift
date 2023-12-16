//
//  UserInfo.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 11/20/23.
//

import Foundation
import SwiftUI

struct UserInfoResponse: Codable {
    let storyNum: Int
    let nickname: String
    let likeNum: Int
    let reportedStories: [String]?
}

class UserInfo: ObservableObject {
    private var nickname: String = ""
    private var storyNum: Int = 0
    private var likeNum: Int = 0
    private var reportedStories: [String] = []
    var tokenModel: TokenModel
    var authModel: AuthModel
    init(tokenModel: TokenModel, authModel: AuthModel) {
        self.tokenModel = tokenModel
        self.authModel = authModel
    }
    func getUserNickname() -> String { return self.nickname }
    func getUserStoryNum() -> Int { return self.storyNum }
    func getUserLikeNum() -> Int { return self.likeNum }
    func getReportedStories() -> [String] { return self.reportedStories }
    func getUserInfo(alertType: Binding<AlertType?>) async -> Bool {
        await tokenModel.validateToken(authModel: authModel)
        let serverURLString = Bundle.main.infoDictionary?["SERVER_URL"] as? String ?? ""
        guard let requestURL = URL(string: "https://\(serverURLString)/userInfo") else {
            print("Invalid URL")
            return false
        }
        let accessToken = self.tokenModel.getToken("accessToken") ?? ""
        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        request.addValue(accessToken, forHTTPHeaderField: "Authorization")
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return false
            }

            if httpResponse.statusCode == 200 {
                let decoder = JSONDecoder()
                let userInfoResponse = try decoder.decode(UserInfoResponse.self, from: data)
                let reportedStories = userInfoResponse.reportedStories ?? []

                DispatchQueue.main.async {
                    self.nickname = userInfoResponse.nickname
                    self.storyNum = userInfoResponse.storyNum
                    self.likeNum = userInfoResponse.likeNum

                    if !reportedStories.isEmpty {
                        alertType.wrappedValue = .reportAlert
                        self.reportedStories = reportedStories
                    }
                }
                return true
            } else {
                print("Request failed with status code: \(httpResponse.statusCode)")
                return false
            }
        } catch {
            print("Fetch failed: \(error.localizedDescription)")
            return false
        }
    }
}
