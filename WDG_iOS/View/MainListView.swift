//
//  MainListView.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 10/27/23.
//

import SwiftUI

struct MainListView: View {
    @StateObject var authKakao: AuthKakao = AuthKakao()
    var body: some View {
        Group {
            if authKakao.isLoggedIn {
                // 사용자가 로그인한 경우 표시될 뷰
                VStack {
                    Text("Main List")
                    Button("KAKAO LOGOUT", action: {
                        authKakao.handleKakaoLogout()
                    })
                }
            } else {
                // 사용자가 로그인하지 않은 경우 LoginView 표시
                LoginView(authKakao: authKakao)
            }
        }
    }
}
