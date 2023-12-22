//
//  LoginView.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 10/27/23.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var authModel: AuthModel
    @State private var logoOffset: CGFloat = 150
    @State private var endAnimation: Bool = false
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            VStack(spacing: 300) {
                WDGLogoView(size: 68, spacing: -10, mode: true)
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
                VStack(spacing: 10) {
                    if endAnimation {
                        Button(action: {
                            authModel.handleKakaoLogin()
                        }, label: {
                            Image("KakaoLoginButtonImage")
                                .resizable() // 이미지를 크기 조정 가능하게 만듭니다.
                                .aspectRatio(contentMode: .fit) // 원본 이미지의 비율을 유지합니다.
                                .frame(height: 69)
                        })
                        signInWithAppleButton()
                    }
                }
            }
        }
    }
    private func signInWithAppleButton() -> some View {
        SignInWithAppleButton(
            .continue,
            onRequest: { _ in },
            onCompletion: { result in
                // 인증 결과 처리
                switch result {
                case .success(let authorization):
                    // 성공적인 인증 후 처리
                    print(authorization)
                    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                        guard let identityTokenData = appleIDCredential.identityToken,
                              let identityTokenString = String(data: identityTokenData, encoding: .utf8) else {
                            return
                        }
                        guard let identityTokenAuth = appleIDCredential.authorizationCode,
                              let identityTokenAuthString = String(data: identityTokenAuth, encoding: .utf8) else {
                            return
                        }
                        print(appleIDCredential.user, identityTokenString, identityTokenAuthString)
                        authModel.handleAppleLogin(userId: identityTokenString)
                    }
                case .failure(let error):
                    // 인증 실패 시 처리
                    print("Authentication failed: \(error.localizedDescription)")
                }
            }
        )
        .signInWithAppleButtonStyle(.white)
        .frame(width: 280, height: 70)
    }

}

struct WDGLogoView: View {
    var size: CGFloat
    var spacing: CGFloat
    var mode: Bool
    var body: some View {
        HStack(spacing: spacing) {
            Text("W")
                .font(Font.custom("Dela Gothic One", size: size))
                .foregroundColor(mode ? .white : .black)
            Text("D")
                .font(Font.custom("Dela Gothic One", size: size))
                .foregroundColor(mode ? .white : .black)
            Text("G")
                .font(Font.custom("Dela Gothic One", size: size))
                .foregroundColor(mode ? .white : .black)
        }
    }
}
