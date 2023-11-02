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
            if authKakao.isLoggedIn && authKakao.isNewAccount {
                SetNicknameView(authKakao: authKakao)
            } else if authKakao.isLoggedIn {
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
                    SettingsView(authKakao: authKakao)
                        .tabItem {
                            Image(systemName: "person")
                        }
                }
                .accentColor(.black)
            } else {
                // 사용자가 로그인하지 않은 경우 LoginView 표시
                LoginView(authKakao: authKakao)
                    .alert(isPresented: $authKakao.loginFailedAlert) {
                        Alert(
                            title: Text("로그인에 실패하였습니다."),
                            message: Text("다시 시도해주세요.")
                        )
                    }
            }
        }
    }
}

struct ContentViewPreviews: PreviewProvider {
    static func loggedInAuthKakao() -> AuthKakao {
        let authKakao = AuthKakao()
        authKakao.isLoggedIn = true
        authKakao.isNewAccount = false
        return authKakao
    }
    static var previews: some View {
        ContentView(authKakao: loggedInAuthKakao())
    }
}
