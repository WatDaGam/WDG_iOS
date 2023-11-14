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

class PostModel: ObservableObject {
    @Published var posts: [Message] = []  // 빈 배열로 초기화
    init() {
        createDummyPosts()  // 생성자에서 더미 포스트 생성
        sortByDate()
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
    func createDummyPosts() {
        var dummyMessages = [Message]()
        for _ in 1...20 {
            // 무작위 날짜 생성 (최근 3년 내)
            let randomDays = Int.random(in: 0...(365 * 3))
            let randomDate = Calendar.current.date(byAdding: .day, value: -randomDays, to: Date())!
            // 대한민국 서울 기준으로 무작위 위경도 생성
            let latitude = Double.random(in: 37.4...37.7)
            let longitude = Double.random(in: 126.8...127.2)
            print("무작위 위치: \(latitude), \(longitude)")
            // 더미 메시지 생성
            let message = Message(
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
    @State private var onClicked: Int = 0
    var post: Message
    var body: some View {
        switch onClicked {
        case 0:
            HStack {
                Text("\(post.nickname) 왔다감")
                    .font(.system(size: 20).bold())
                Spacer()
                Image(systemName: "location")
                if let location = locationModel.location {
                    let distanceText = formattedDistance(from: post.location, to: location.coordinate)
                    Text(distanceText).fixedSize(horizontal: true, vertical: false)
                } else {
                    let defaultLocation = CLLocation(latitude: 37.5666612, longitude: 126.9783785)
                    let distanceText = formattedDistance(from: post.location, to: defaultLocation.coordinate)
                    Text(distanceText).fixedSize(horizontal: true, vertical: false)
                }
                Image(systemName: "heart")
                Text("\(post.likes)")
            }
            .padding(.horizontal)
            .fixedSize(horizontal: false, vertical: true)
            .frame(height: 70)
            .onTapGesture {
                onClicked = 1
            }
        case 1:
            VStack(spacing: 20) {
                HStack {
                    Text("\(post.nickname) 왔다감")
                        .font(.system(size: 20).bold())
                    VStack {
                        Spacer()
                        Text("\(post.location.latitude) \(post.location.longitude)")
                            .font(.caption2)
//                            .foregroundColor(.gray)
                    }
                    .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                    Spacer()
                    Button(action: {
                        print("button clicked!")
                    }, label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.black)
                    })
                }
                HStack {
                    Text(post.message)
                    Spacer()
                }
                Spacer()
                HStack {
                    Image(systemName: "location")
                    if let location = locationModel.location {
                        let distanceText = formattedDistance(from: post.location, to: location.coordinate)
                        Text(distanceText).fixedSize(horizontal: true, vertical: false)
                    } else {
                        let defaultLocation = CLLocation(latitude: 37.5666612, longitude: 126.9783785)
                        let distanceText = formattedDistance(from: post.location, to: defaultLocation.coordinate)
                        Text(distanceText).fixedSize(horizontal: true, vertical: false)
                    }
                    Spacer()
                    Image(systemName: "heart")
                    Text("\(post.likes)")
                }
            }
            .padding(.horizontal)
            .frame(height: 200)
//            .onTapGesture {
//                onClicked = 0
//            }
        default:
            Text("default")
        }
    }
    func formattedDistance(from location1: LocationType, to coordinate2: CLLocationCoordinate2D) -> String {
        let coordinate1 = CLLocation(latitude: location1.latitude, longitude: location1.longitude)
        let coordinate2 = CLLocation(latitude: coordinate2.latitude, longitude: coordinate2.longitude)
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
        let postModel = PostModel()
        let locationModel = LocationModel()
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
