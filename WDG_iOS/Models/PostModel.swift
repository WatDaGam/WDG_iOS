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
    var myPosts: [Message] = []
    init() {
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
    func getMyPosts() -> [Message] {
        return self.myPosts
    }
    func removePost(id: Int) {
        self.posts.removeAll { $0.id == id }
    }
    func getStoryList(accessToken: String, lati: Double?, longi: Double?) async -> Bool {
        let jsonDict: [String: Any] = ["lati": lati ?? 0, "longi": longi ?? 0]
        let serverURLString = Bundle.main.infoDictionary?["SERVER_URL"] as? String ?? ""
        guard let requestURL = URL(string: "https://\(serverURLString)/storyList/renew") else {
            print("Invalid URL")
            return false
        }
        var request = URLRequest(url: requestURL)
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
            if httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    self.posts = self.parseStories(jsonData: data) ?? []
                }
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
    func getMyStoryList(accessToken: String) async -> Bool {
        let serverURLString = Bundle.main.infoDictionary?["SERVER_URL"] as? String ?? ""
        guard let requestURL = URL(string: "https://\(serverURLString)/myStory") else {
            print("Invalid URL")
            return false
        }
        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        request.addValue(accessToken, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type") // JSON 데이터임을 명시
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return false
            }
            if httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    self.myPosts = self.parseStories(jsonData: data) ?? []
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
        let serverURLString = Bundle.main.infoDictionary?["SERVER_URL"] as? String ?? ""
        guard let requestURL = URL(string: "https://\(serverURLString)/story/upload") else {
            print("Invalid URL")
            return false
        }
        var request = URLRequest(url: requestURL)
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
        let serverURLString = Bundle.main.infoDictionary?["SERVER_URL"] as? String ?? ""
        guard let requestURL = URL(
            string: "https://\(serverURLString)/like/plus?storyId=" + String(id)
        ) else {
            print("Invalid URL")
            return false
        }
        var request = URLRequest(url: requestURL)
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
    func reportStory(accessToken: String, id: Int) async -> Int {
        let serverURLString = Bundle.main.infoDictionary?["SERVER_URL"] as? String ?? ""
        guard let requestURL = URL(
            string: "https://\(serverURLString)/report?storyId=" + String(id)
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
    @EnvironmentObject var snackbarController : SnackbarController
    @Binding var alertType: AlertType?
    @Binding var selectedTab: Int
    @Binding var reportPostId: Int
    @Binding var blockId: Int
    @State private var onClicked: Int = 0
    @State private var isAnimating: Bool = false
    @State private var isLike: Bool = false
    @State private var isPresented: Bool = false
    @State private var isMenuActive = false
    var post: Message
    var myStory: Bool
    private let postMenuOption: [String] = ["신고하기", "차단하기"]
    var body: some View {
        let currentLocation = locationModel.location ?? CLLocation(
            latitude: 37.5666612, longitude: 126.9783785
        )
        let distanceText = formattedDistance(from: post.location, to: currentLocation.coordinate)
        let distanceInMeter = calcDistanceInMeter(from: post.location, to: currentLocation.coordinate)
        switch onClicked {
        case 0:
            Button(action: {
                if selectedTab == 0 && distanceInMeter < 30 || selectedTab != 0 && self.myStory {
                    onClicked = 1
                } else {
                    snackbarController.showSnackBar(
                        message: "메세지를 확인하려면 30m 이내로 접근해주세요",
                        label: nil,
                        action: nil
                    )
                }
            }, label: {
                HStack {
                    let isVisible = selectedTab == 0 && distanceInMeter < 30 || selectedTab != 0 && self.myStory
                    let messageWithoutNewLines = post.message.replacingOccurrences(of: "\n", with: "")
                    let displayText = messageWithoutNewLines.count < 10 ? "\(messageWithoutNewLines)" : "\(String(messageWithoutNewLines.prefix(10)))..."
                    Text(isVisible ? displayText : "\(post.nickname) 왔다감")
                        .font(.system(size: 20).bold())
                        .foregroundColor(isVisible ? Color.black : Color.gray)
                    Text("  \(timeAgoSinceDate(post.date))")
                        .font(.system(size: 12))
                        .foregroundColor(Color.gray)
                    Spacer()
                    VStack(alignment: .trailing) {
                        HStack {
                            Image(systemName: isLike ? "heart.fill" : "heart")
                                .foregroundColor(isVisible ? Color.black : Color.gray)
                            Text("\(post.likes)")
                                .foregroundColor(isVisible ? Color.black : Color.gray)
                        }
                        Spacer()
                        HStack {
                            Image(systemName: "location")
                                .foregroundColor(isVisible ? Color.black : Color.gray)
                            Text(distanceText).fixedSize(horizontal: true, vertical: false)
                                .foregroundColor(isVisible ? Color.black : Color.gray)
                        }
                    }
                    .padding(.vertical)
                }
                .padding(.horizontal)
                .fixedSize(horizontal: false, vertical: true)
                .frame(height: 90)
                .background(.white)
                .colorScheme(.light)
            })
        case 1:
            Button(action: {
                if !isMenuActive {
                    onClicked = 0
                } else {
                    isMenuActive = false
                }
            }, label: {
                VStack(spacing: 20) {
                    HStack {
                        Text("\(post.location.latitude) \(post.location.longitude)")
                            .font(.caption2)
                            .foregroundColor(Color.black)
                        Spacer()
                        if selectedTab == 0 && self.myStory == false {
                            Menu {
                                ForEach(postMenuOption, id: \.self) { option in
                                    Button(option) {
                                        if option == "신고하기" {
                                            reportPostId = post.id
                                            alertType = .isReport
                                        } else if option == "차단하기" {
                                            blockId = post.userId
                                            alertType = .isBlock
                                        }
                                    }
                                    .padding(.trailing, 10)
                                }
                            } label: {
                                Image(systemName: "ellipsis")
                                    .foregroundColor(.black)
                                    .imageScale(.medium)
                                    .font(.system(size: 24))
                                    .padding(.top, 10)
                                    .padding(.trailing, 10)
                            }
                            .onTapGesture {
                                // 메뉴가 열릴 때 isMenuActive를 true로 설정
                                isMenuActive = true
                            }
                        }
                    }
                    .padding(.bottom, -10)
                    HStack {
                        Text(
                            self.myStory || distanceInMeter < 30 ? post.message : "거리가 멀어 메세지를 확인하실 수 없습니다."
                        )
                        .foregroundColor(
                            self.myStory || distanceInMeter < 30 ? Color.black : Color.gray
                        )
                        Spacer()
                    }
                    Spacer()
                    HStack(alignment: .bottom) {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                        Text(distanceText)
                            .fontWeight(.semibold)
                            .fixedSize(horizontal: true, vertical: false)
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("\(convertDateToString(date: post.date))")
                                .font(.system(size: 14))
                            Text("\(post.nickname) 왔다감")
                                .font(.system(size: 14))
                            HStack {
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
                                        Image(systemName: "heart")
                                            .foregroundColor(.black)
                                    }
                                })
                                Text("\(post.likes)")
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .frame(height: 200)
                .background(.white)
                .colorScheme(.light)
            })
            .foregroundColor(Color.black)
            .contentShape(Rectangle()) // 전체 영역을 클릭 가능하게 설정
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
    func convertDateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        return dateFormatter.string(from: date)
    }
    func timeAgoSinceDate(_ date: Date, numericDates: Bool = true) -> String {
        let calendar = Calendar.current
        let now = Date()
        let earliest = now < date ? now : date
        let latest = (earliest == now) ? date : now
        
        let components: DateComponents = calendar.dateComponents([.minute, .hour, .day, .weekOfYear, .month, .year, .second], from: earliest, to: latest)
        
        if (components.year! >= 2) {
            return "\(components.year!)년 전"
        } else if (components.year! >= 1) {
            if (numericDates){
                return "1년 전"
            } else {
                return "작년"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!)개월 전"
        } else if (components.month! >= 1) {
            if (numericDates){
                return "1개월 전"
            } else {
                return "지난 달"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!)주 전"
        } else if (components.weekOfYear! >= 1) {
            if (numericDates){
                return "1주 전"
            } else {
                return "지난 주"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!)일 전"
        } else if (components.day! >= 1) {
            if (numericDates){
                return "1일 전"
            } else {
                return "어제"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!)시간 전"
        } else if (components.hour! >= 1) {
            if (numericDates){
                return "1시간 전"
            } else {
                return "한 시간 전"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!)분 전"
        } else if (components.minute! >= 1) {
            if (numericDates){
                return "1분 전"
            } else {
                return "방금 전"
            }
        } else if (components.second! >= 3) {
            return "\(components.second!)초 전"
        } else {
            return "방금 전"
        }
    }
    
}

//struct PostPreviews: PreviewProvider {
//    @State static var alertType: AlertType?
//    @State static var reportPostId: Int = 0
//    @State static var blockId: Int = 0
//    @State static var selectedTab: Int = 0
//    static var previews: some View {
//        let tokenModel = TokenModel()
//        let authModel = AuthModel(tokenModel: tokenModel)
//        let postModel = PostModel()
//        let locationModel = LocationModel(
//            tokenModel: tokenModel,
//            authModel: authModel,
//            postModel: postModel
//        )
//        VStack {
//            Spacer()
//            Divider()
//            Post(
//                alertType: $alertType,
//                selectedTab: $selectedTab,
//                reportPostId: $reportPostId,
//                blockId: $blockId,
//                post: postModel.posts[0]
//            )
//            .environmentObject(locationModel)
//            Divider()
//            Spacer()
//        }
//    }
//}
