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
    let location: [Int]
    
}
