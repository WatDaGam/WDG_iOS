//
//  PostModel.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 11/6/23.
//

import Foundation
import Combine
import SwiftUI

class PostModel: ObservableObject {
    @Published var posts: [Message] = []  // 빈 배열로 초기화
    init() {
        createDummyPosts()  // 생성자에서 더미 포스트 생성
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
            // 더미 메시지 생성
            let message = Message(
                nickname: ["정찬웅", "yback", "sangkkim12"].randomElement()!,  // 더 안전한 접근 방법
                message: "Sample message \(Int.random(in: 1...100))",
                date: randomDate,
                location: [latitude, longitude],
                likes: Int.random(in: 0...200)
            )
            dummyMessages.append(message)
        }
        self.posts = dummyMessages
    }
}

struct Post: View {
    var post: Message
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 30) {
                Text(post.nickname)
                    .font(.headline)
                Text(post.message)
                    .font(.subheadline)
            }
            .padding()
            Spacer()
            VStack(alignment: .trailing, spacing: 30) {
                HStack {
                    Image(systemName: "heart")
                    Text("\(post.likes)")
                }
                HStack {
                    Image(systemName: "location")
                    Text("\(Int.random(in: 1...100) * 10)m")
                }
            }
            .padding()
        }
        .frame(height: 100)
        .listRowInsets(EdgeInsets())
    }
}
