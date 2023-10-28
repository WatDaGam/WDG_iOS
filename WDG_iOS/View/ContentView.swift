//
//  ContentView.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 10/28/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var authKakao: AuthKakao = AuthKakao()
    var body: some View {
        Group {
            //            if authKakao.isLoggedIn {
            if true { // 임시 개발용
                // 사용자가 로그인한 경우 표시될 뷰
                TabView {
                    MainListView()
                        .tabItem {
                            Image(systemName: "list.bullet")
                        }
                    PostView()
                        .tabItem {
                            Image(systemName: "square.and.pencil")
                        }
                    SettingsView()
                        .tabItem {
                            Image(systemName: "person")
                        }
                }
                .accentColor(.black)
            } else {
                // 사용자가 로그인하지 않은 경우 LoginView 표시
                LoginView(authKakao: authKakao)
            }
        }
    }
}

//#Preview {
//    ContentView()
//}
