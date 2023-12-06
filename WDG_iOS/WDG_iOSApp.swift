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
import SwiftUI_Snackbar

@main
struct WDG_iOSApp: App {
    @UIApplicationDelegateAdaptor var appDelegate : AppDelegate
    var body: some Scene {
        let tokenModel = TokenModel()
        let authModel = AuthModel(tokenModel: tokenModel)
        let postModel = PostModel()
        let locationModel = LocationModel(tokenModel: tokenModel, authModel: authModel, postModel: postModel)
        let userInfo = UserInfo(tokenModel: tokenModel, authModel: authModel)
        let snackbarController = SnackbarController()
        WindowGroup {
            SnackBarHost {
                ContentView()
                    .environmentObject(authModel)
                    .environmentObject(tokenModel)
                    .environmentObject(postModel)
                    .environmentObject(locationModel)
                    .environmentObject(userInfo)
            }
            .environmentObject(snackbarController)
        }
    }
}

struct AppPreview: PreviewProvider {
    static var previews: some View {
        let tokenModel = TokenModel()
        let authModel = AuthModel(tokenModel: tokenModel)
        let postModel = PostModel()
        let locationModel = LocationModel(tokenModel: tokenModel, authModel: authModel, postModel: postModel)
        let userInfo = UserInfo(tokenModel: tokenModel, authModel: authModel)
        let snackbarController = SnackbarController()
        SnackBarHost {
            ContentView()
                .environmentObject(authModel)
                .environmentObject(tokenModel)
                .environmentObject(postModel)
                .environmentObject(locationModel)
                .environmentObject(userInfo)
                .environmentObject(snackbarController)
        }
    }
}
