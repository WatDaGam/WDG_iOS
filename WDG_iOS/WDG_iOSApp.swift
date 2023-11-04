//
//  WDG_iOSApp.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 10/27/23.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

@main
struct WDG_iOSApp: App {
    @UIApplicationDelegateAdaptor var appDelegate : AppDelegate
    var body: some Scene {
        let tokenModel = TokenModel()
        let authModel = AuthModel(tokenModel: tokenModel)
        WindowGroup {
            ContentView()
                .environmentObject(authModel)
                .environmentObject(tokenModel)
        }
    }
}
