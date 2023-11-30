//
//  PostModel.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 11/6/23.
//

import Foundation
import Combine
import SwiftUI
import CoreLocation

struct StoryResponse: Codable {
    let stories: [Story]
}

struct Story: Codable {
    let createdAt: Double
    let nickname: String
    let lati: Double
    let id: Int
    let longi: Double
    let userId: Int?
    let content: String
    let likeNum: Int
    var date: Date {
        return Date(timeIntervalSince1970: createdAt / 1000) // 밀리초를 초로 변환
    }
}

struct LikePlusResponse: Codable {
    let likeNum: Int
}

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'" // ISO 8601 형식
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

class PostModel: ObservableObject {
    @Published var posts: [Message] = []  // 빈 배열로 초기화
    init() {
        self.createDummyPosts()
    }
    func addPosts(message: Message) {
        self.posts.insert(message, at: 0)
    }
    func setPosts(messages: [Message]) {
        self.posts = messages
    }
    func getPosts() -> [Message] {
        return self.posts
    }
    func getStoryList(accessToken: String, lati: Double?, longi: Double?) async -> Bool {
        let jsonDict: [String: Any] = ["lati": lati ?? 0, "longi": longi ?? 0]
        guard let userInfoURL = URL(string: "http://43.200.68.255:8080/storyList/renew") else {
            print("Invalid URL")
            return false
        }
        var request = URLRequest(url: userInfoURL)
        request.httpMethod = "POST"
        request.addValue(accessToken, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type") // JSON 데이터임을 명시
        // JSON 데이터로 인코딩
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: jsonDict, options: [])
        } catch {
            print("Error: JSON 데이터 변환 실패")
            return false
        }
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
                DispatchQueue.main.async {
                    self.posts = self.parseStories(jsonData: data) ?? []
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
    func parseStories(jsonData: Data) -> [Message]? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full) // 날짜 포맷 설정
        do {
            let storyResponse = try decoder.decode(StoryResponse.self, from: jsonData)
            return storyResponse.stories.map { story in
                // Story 구조체 인스턴스를 Message 구조체로 변환
                Message(
                    id: story.id, // 새로운 UUID 생성
                    userId: story.userId ?? -1,
                    nickname: story.nickname,
                    message: story.content,
                    date: story.date,
                    location: LocationType(latitude: story.lati, longitude: story.longi),
                    likes: story.likeNum
                )
            }
        } catch {
            print("Error parsing JSON: \(error)")
            return nil
        }
    }
    func uploadStory(accessToken: String, content: String, lati: Double?, longi: Double?) async -> Bool {
        let jsonDict: [String: Any] = ["content": content, "lati": lati ?? 0, "longi": longi ?? 0]
        guard let userInfoURL = URL(string: "http://43.200.68.255:8080/story/upload") else {
            print("Invalid URL")
            return false
        }
        var request = URLRequest(url: userInfoURL)
        request.httpMethod = "POST"
        request.addValue(accessToken, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type") // JSON 데이터임을 명시
        // JSON 데이터로 인코딩
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: jsonDict, options: [])
        } catch {
            print("Error: JSON 데이터 변환 실패")
            return false
        }
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
    func likeStory(accessToken: String, id: Int) async -> Bool {
        guard let userInfoURL = URL(
            string: "http://43.200.68.255:8080/like/plus?storyId=" + String(id)
        ) else {
            print("Invalid URL")
            return false
        }
        var request = URLRequest(url: userInfoURL)
        request.httpMethod = "POST"
        request.addValue(accessToken, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "accept") // JSON 데이터임을 명시
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("Request failed with status code: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                return false
            }
            let newLikeNum = parseLikeNum(jsonData: data)
            if newLikeNum != -1 {
                DispatchQueue.main.async {
                    self.updateLikeNum(for: id, likeNum: newLikeNum)
                }
                return true
            }
            return false
        } catch {
            print("Fetch failed: \(error.localizedDescription)")
            return false
        }
    }
    func parseLikeNum(jsonData: Data) -> Int {
        let decoder = JSONDecoder()
        do {
            let response = try decoder.decode(LikePlusResponse.self, from: jsonData)
            return response.likeNum
        } catch {
            print("Error parsing JSON: \(error)")
            return -1
        }
    }
    private func updateLikeNum(for id: Int, likeNum: Int) {
        if let index = posts.firstIndex(where: { $0.id == id }) {
            posts[index].likes = likeNum
        }
    }
    func createDummyPosts() {
        var dummyMessages = [Message]()
        for id in 1...20 {
            // 무작위 날짜 생성 (최근 3년 내)
            let randomDays = Int.random(in: 0...(365 * 3))
            let randomDate = Calendar.current.date(byAdding: .day, value: -randomDays, to: Date())!
            // 대한민국 서울 기준으로 무작위 위경도 생성
            let latitude = Double.random(in: 37.4...37.7)
            let longitude = Double.random(in: 126.8...127.2)
            // 더미 메시지 생성
            let message = Message(
                id: id + 1000000,
                userId: id + 1000000,
                nickname: ["정찬웅", "yback", "sangkkim12"].randomElement()!,  // 더 안전한 접근 방법
                message: "Sample message \(Int.random(in: 1...100))",
                date: randomDate,
                location: LocationType(latitude: latitude, longitude: longitude),
                likes: Int.random(in: 0...200)
            )
            dummyMessages.append(message)
        }
        self.posts = dummyMessages
    }
    func sortByDate() { self.posts.sort(by: {$0.date > $1.date}) }
    func sortByLikes() { self.posts.sort(by: {$0.likes > $1.likes}) }
}

struct Post: View {
    @EnvironmentObject var locationModel: LocationModel
    @EnvironmentObject var tokenModel: TokenModel
    @EnvironmentObject var authModel: AuthModel
    @EnvironmentObject var postModel: PostModel
    @State private var onClicked: Int = 0
    @State private var isAnimating: Bool = false
    @State private var isLike: Bool = false
    var post: Message
    private let postMenuOption: [String] = ["신고하기"]
    var body: some View {
        let currentLocation = locationModel.location ?? CLLocation(
            latitude: 37.5666612, longitude: 126.9783785
        )
        let distanceText = formattedDistance(from: post.location, to: currentLocation.coordinate)
        let distanceInMeter = calcDistanceInMeter(from: post.location, to: currentLocation.coordinate)
        switch onClicked {
        case 0:
            HStack {
                Text("\(post.nickname) 왔다감")
                    .font(.system(size: 20).bold())
                    .foregroundColor(distanceInMeter < 30 ? Color.black : Color.gray)
                Spacer()
                VStack(alignment: .trailing) {
                    HStack {
                        Image(systemName: "heart")
                            .foregroundColor(distanceInMeter < 30 ? Color.black : Color.gray)
                        Text("\(post.likes)")
                            .foregroundColor(distanceInMeter < 30 ? Color.black : Color.gray)
                    }
                    Spacer()
                    HStack {
                        Image(systemName: "location")
                            .foregroundColor(distanceInMeter < 30 ? Color.black : Color.gray)
                        Text(distanceText).fixedSize(horizontal: true, vertical: false)
                            .foregroundColor(distanceInMeter < 30 ? Color.black : Color.gray)
                    }
                }
                .padding(.vertical)
            }
            .padding(.horizontal)
            .fixedSize(horizontal: false, vertical: true)
            .frame(height: 90)
            .foregroundColor(.white)
            .onTapGesture {
//                if distanceInMeter < 30 {
                    onClicked = 1
//                }
//                else {
//                    ViewControllerWrapper()
//                }
            }
        case 1:
            VStack(spacing: 20) {
                HStack {
                    Text("\(post.nickname) 왔다감")
                        .font(.system(size: 20).bold())
                        .foregroundColor(distanceInMeter < 30 ? Color.black : Color.gray)
                    VStack {
                        Spacer()
                        Text("\(post.location.latitude) \(post.location.longitude)")
                            .font(.caption2)
                    }
                    .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                    Spacer()
                    if distanceInMeter < 30 {
                        Menu {
                            ForEach(postMenuOption, id: \.self) { option in
                                Button(option) {
                                    if option == "신고하기" {
                                        print("신고하기 누름")
                                    }
                                }
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.black)
                        }
                    }
                }
                HStack {
                    Text(distanceInMeter < 30 ? post.message : "거리가 멀어 메세지를 확인하실 수 없습니다.")
                        .foregroundColor(distanceInMeter < 30 ? Color.black : Color.gray)
                    Spacer()
                }
                Spacer()
                HStack {
                    Image(systemName: "location")
                    Text(distanceText).fixedSize(horizontal: true, vertical: false)
                    Spacer()
                    Button(action: {
                        self.isAnimating = true
                        Task {
                            await tokenModel.validateToken(authModel: authModel)
                            await postModel.likeStory(
                                accessToken: tokenModel.getToken("accessToken") ?? "", 
                                id: post.id
                            )
                        }
                        // Lottie 애니메이션 길이에 맞춰 시간 조절
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            self.isAnimating = false
                        }
                        self.isLike = true
                    }, label: {
                        if isAnimating {
                            LottieView(name: "LottieLike", loopMode: .playOnce) // 애니메이션이 활성화된 경우
                                .frame(width: 20, height: 20)
                        } else {
                            Image(systemName: isLike ? "heart.fill" : "heart") // 애니메이션이 비활성화된 경우
                                .foregroundColor(isLike ? .red : .black)
                        }
                    })
                    Text("\(post.likes)")
                }
            }
            .padding(.horizontal)
            .frame(height: 200)
            .onTapGesture {
                onClicked = 0
            }
        default:
            Text("default")
        }
    }
    func calcDistanceInMeter(from location1: LocationType, to location2: CLLocationCoordinate2D) -> Double {
        let coordinate1 = CLLocation(latitude: location1.latitude, longitude: location1.longitude)
        let coordinate2 = CLLocation(latitude: location2.latitude, longitude: location2.longitude)
        return coordinate1.distance(from: coordinate2)
    }
    func formattedDistance(from location1: LocationType, to location2: CLLocationCoordinate2D) -> String {
        let coordinate1 = CLLocation(latitude: location1.latitude, longitude: location1.longitude)
        let coordinate2 = CLLocation(latitude: location2.latitude, longitude: location2.longitude)
        let distanceInMeters = coordinate1.distance(from: coordinate2)
        if distanceInMeters > 1000 {
            let distanceInKilometers = distanceInMeters / 1000
            return String(format: "%.1fkm", distanceInKilometers)
        } else {
            return String(format: "%.0fm", distanceInMeters)
        }
    }
}

struct PostPreviews: PreviewProvider {
    static var previews: some View {
        let tokenModel = TokenModel()
        let authModel = AuthModel(tokenModel: tokenModel)
        let postModel = PostModel()
        let locationModel = LocationModel(
            tokenModel: tokenModel,
            authModel: authModel,
            postModel: postModel
        )
        VStack {
            Spacer()
            Divider()
            Post(post: postModel.posts[0])
                .environmentObject(locationModel)
            Divider()
            Spacer()
        }
    }
}
