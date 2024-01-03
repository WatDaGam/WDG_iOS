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
    let reportedStoryNum: Int?
    let userId: Int
}

struct BlockInfo: Identifiable {
    let id: Int
    let nickname: String
}

class UserInfo: ObservableObject {
    private var nickname: String = ""
    private var storyNum: Int = 0
    private var likeNum: Int = 0
    private var reportedStoryNum: Int = 0
    private var blockList: [BlockInfo] = []
    private var myId: Int = 0
    var tokenModel: TokenModel
    var authModel: AuthModel
    init(tokenModel: TokenModel, authModel: AuthModel) {
        self.tokenModel = tokenModel
        self.authModel = authModel
    }
    func removeBlockListById(id: Int) -> Void {
        self.blockList.removeAll { $0.id == id }
    }
    func getMyId() -> Int { return self.myId }
    func getBlockList() -> [BlockInfo] { return self.blockList }
    func getUserNickname() -> String { return self.nickname }
    func getUserStoryNum() -> Int { return self.storyNum }
    func getUserLikeNum() -> Int { return self.likeNum }
    func getReportedStoryNum() -> Int { return self.reportedStoryNum }
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
            print(data)
            if httpResponse.statusCode == 200 {
                let decoder = JSONDecoder()
                let userInfoResponse = try decoder.decode(UserInfoResponse.self, from: data)
                let reportedStoryNum = userInfoResponse.reportedStoryNum ?? 0
                print(userInfoResponse)
                print(reportedStoryNum)
                DispatchQueue.main.async {
                    self.myId = userInfoResponse.userId
                    self.nickname = userInfoResponse.nickname
                    self.storyNum = userInfoResponse.storyNum
                    self.likeNum = userInfoResponse.likeNum

                    if reportedStoryNum != 0 {
                        alertType.wrappedValue = .reportAlert
                        self.reportedStoryNum = reportedStoryNum
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
    func getBlockList() async -> Bool {
        await tokenModel.validateToken(authModel: authModel)
        let serverURLString = Bundle.main.infoDictionary?["SERVER_URL"] as? String ?? ""
        guard let requestURL = URL(string: "https://\(serverURLString)/blockList") else {
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
            print(data)
            if httpResponse.statusCode == 200 {
                let decoder = JSONDecoder()
//                let blockResponse = try decoder.decode(UserInfoResponse.self, from: data)
//                let reportedStoryNum = userInfoResponse.reportedStoryNum ?? 0
//                print(userInfoResponse)
//                print(reportedStoryNum)
//                DispatchQueue.main.async {
//                    self.blockList = userInfoResponse.nickname
//                }
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
    func addBlockUser(accessToken: String, id: Int) async -> Int {
        let serverURLString = Bundle.main.infoDictionary?["SERVER_URL"] as? String ?? ""
        guard let requestURL = URL(
            string: "https://\(serverURLString)/block?userId=" + String(id)
        ) else {
            print("Invalid URL")
            return -1
        }
        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        request.addValue(accessToken, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "accept") // JSON 데이터임을 명시
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                return -1
            }
            print(httpResponse.statusCode)
            return httpResponse.statusCode
        } catch {
            print("Fetch failed: \(error.localizedDescription)")
            return -1
        }
    }
    func removeBlockUser(accessToken: String, id: Int) async -> Int {
        let serverURLString = Bundle.main.infoDictionary?["SERVER_URL"] as? String ?? ""
        guard let requestURL = URL(
            string: "https://\(serverURLString)/block/remove?userId=" + String(id)
        ) else {
            print("Invalid URL")
            return -1
        }
        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        request.addValue(accessToken, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "accept") // JSON 데이터임을 명시
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                return -1
            }
            print(httpResponse.statusCode)
            return httpResponse.statusCode
        } catch {
            print("Fetch failed: \(error.localizedDescription)")
            return -1
        }
    }
}
