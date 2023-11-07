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
        let postModel = PostModel()
        WindowGroup {
            ContentView()
                .environmentObject(authModel)
                .environmentObject(tokenModel)
                .environmentObject(postModel)
        }
    }
}

struct AppPreview: PreviewProvider {
    static var previews: some View {
        let tokenModel = TokenModel()
        let authModel = AuthModel(tokenModel: tokenModel)
        let postModel = PostModel()
        ContentView()
            .environmentObject(authModel)
            .environmentObject(tokenModel)
            .environmentObject(postModel)
    }
}
