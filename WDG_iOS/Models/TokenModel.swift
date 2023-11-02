//
//  TokenModel.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 11/2/23.
//

import Foundation

class TokenModel {
    let keychain = KeychainSwift()
    func saveToken(_ token: String, type: String) {
        keychain.set(token, forKey: type)
    }
    func getToken(_ type: String) -> String? {
        return keychain.get(type)
    }
    func deleteToken(_ type: String) {
        keychain.delete(type)
    }
}
