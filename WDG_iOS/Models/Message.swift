//
//  Message.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 10/28/23.
//

import Foundation

struct Message: Identifiable, Codable {
    let id: UUID
    let nickname: String
    var message: String
    var date: Date
    var likes: Int
    let location: [Double]
    init(id: UUID = UUID(), nickname: String, message: String, date: Date, location: [Double], likes: Int) {
        self.id = id
        self.nickname = nickname
        self.message = message
        self.date = date
        self.location = location
        self.likes = likes
    }
    static func createSampleMessage(
        nickname: String, message: String, date: Date, location: [Double], likes: Int) -> Message {
            return Message(nickname: nickname, message: message, date: date, location: location, likes: likes)
    }
}
