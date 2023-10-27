//
//  LoginView.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 10/27/23.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var authKakao: AuthKakao = AuthKakao()
    @State private var logoOffset: CGFloat = 150
    @State private var endAnimation: Bool = false
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            VStack(spacing: 300) {
                WDGLogoView()
                    .offset(y: logoOffset)
                    .onAppear {
                        withAnimation(
                            Animation.easeInOut(duration: 2.0)
                                .delay(1.0) // 1초 동안 대기
                        ) {
                            logoOffset = 0 // 애니메이션이 끝날 때의 오프셋
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            endAnimation = true
                        }
                    }
                VStack {
                    if endAnimation {
                        Button(action: {
                            authKakao.handleKakaoLogin()
                        }, label: {
                            Image("KakaoLoginButtonImage")
                        })
                    }
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
