//
//  Message.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 10/28/23.
//

import Foundation

struct LocationType: Codable {
    var latitude: Double
    var longitude: Double
}

struct Message: Identifiable, Codable {
    let id: Int
    let userId: Int
    let nickname: String
    var message: String
    var date: Date
    var likes: Int
    var location: LocationType
    init(
        id: Int,
        userId: Int,
        nickname: String,
        message: String,
        date: Date,
        location: LocationType,
        likes: Int
    ) {
        self.id = id
        self.userId = userId
        self.nickname = nickname
        self.message = message
        self.date = date
        self.location = location
        self.likes = likes
    }
    static func createSampleMessage(
        id: Int,
        userId: Int,
        nickname: String,
        message: String,
        date: Date,
        location: LocationType,
        likes: Int
    ) -> Message {
        return Message(
            id: id,
            userId: userId,
            nickname: nickname,
            message: message,
            date: date,
            location: location,
            likes: likes
        )
    }
}
