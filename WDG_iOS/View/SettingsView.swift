//
//  SettingsView.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 10/28/23.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var authKakao: AuthKakao
    var body: some View {
        NavigationView {  // NavigationView를 추가
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)  // 전체 화면에 흰색 배경 적용
                List {
                    Button("프로필", action: { print("profile clicked!") })
                    Button("내 작성 목록", action: { print("my list clicked!") })
                    Button("로그아웃", action: { authKakao.handleKakaoLogout() })
                }
                .listStyle(.plain)  // 리스트 스타일을 평범한 스타일로 설정
            }
            .navigationBarTitle("마이페이지", displayMode: .inline)  // 상단 헤더 타이틀 설정
        }
    }
}

struct SettingsViewPreviews: PreviewProvider {
    static var previews: some View {
        let authKakao: AuthKakao = AuthKakao()
        SettingsView(authKakao: authKakao)
    }
}
