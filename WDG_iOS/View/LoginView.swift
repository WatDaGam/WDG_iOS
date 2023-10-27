//
//  LoginView.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 10/27/23.
//

import SwiftUI

struct LoginView: View {
    @StateObject var authKakao: AuthKakao = AuthKakao()
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            VStack(spacing: 300) {
                WDGLogoView()
                VStack(spacing: 20) {
                    Button("KAKAO LOGIN", action: {
                        authKakao.handleKakaoLogin()
                    })
                    Button("KAKAO LOGOUT", action: {})
                }
            }
        }
    }
}

struct WDGLogoView: View {
    var body: some View {
        HStack(spacing: -10) {
            Text("W")
                .font(Font.custom("Dela Gothic One", size: 68))
                .foregroundColor(.white)
            Text("D")
                .font(Font.custom("Dela Gothic One", size: 68))
                .foregroundColor(.white)
            Text("G")
                .font(Font.custom("Dela Gothic One", size: 68))
                .foregroundColor(.white)
        }
    }
}

//struct LoginView_Preview: PreviewProvider {
//    static var previews: some View {
//        LoginView()
//    }
//}
