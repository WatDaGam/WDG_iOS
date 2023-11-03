//
//  ContentView.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 10/28/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authModel: AuthModel
    @EnvironmentObject var tokenModel: TokenModel
    var body: some View {
        Group {
            if authModel.isLoggedIn && authModel.isNewAccount {
                SetNicknameView()
            } else if authModel.isLoggedIn {
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
                LoginView()
            }
        }
        .alert(isPresented: $authModel.loginFailedAlert) {
            Alert(
                title: Text("로그인에 실패하였습니다."),
                message: Text("다시 시도해주세요.")
            )
        }
        .alert(isPresented: $tokenModel.isValidToken.inverted) {
            Alert(
                title: Text("로그인이 만료되었습니다."),
                message: Text("다시 로그인해주세요.")
            )
        }
    }
}

extension Binding where Value == Bool {
    /// A binding to the inverse of the bool value.
    var inverted: Binding<Bool> {
        Binding<Bool>(
            get: { !self.wrappedValue },
            set: { self.wrappedValue = !$0 }
        )
    }
}
