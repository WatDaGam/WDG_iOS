//
//  SettingsView.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 10/28/23.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var authModel: AuthModel
    @State private var isLogout: Bool = false
    @State private var isRemove: Bool = false
    var body: some View {
        NavigationView {  // NavigationView를 추가
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)  // 전체 화면에 흰색 배경 적용
                List {
                    Button("프로필", action: { print("profile clicked!") })
                    Button("내 작성 목록", action: { print("my list clicked!") })
                    Button("로그아웃", action: { isLogout = true })
                    Button("회원탈퇴", action: { isRemove = true })
                }
                .listStyle(.plain)  // 리스트 스타일을 평범한 스타일로 설정
            }
            .navigationBarTitle("마이페이지", displayMode: .inline)  // 상단 헤더 타이틀 설정
            .alert(isPresented: $isLogout) {
                Alert(
                    title: Text("로그아웃"),
                    message: Text("로그아웃 시 로그인 화면으로 이동합니다."),
                    primaryButton: .destructive(Text("예")) {
                        // "예"를 선택했을 때의 동작
                        // 토큰 삭제 및 로그아웃 처리
                        authModel.handleKakaoLogout()
                    },
                    secondaryButton: .cancel(Text("아니오"))
                )
            }
            .alert(isPresented: $isRemove) {
                Alert(
                    title: Text("회원탈퇴"),
                    message: Text("회원탈퇴 시 모든 데이터가 삭제됩니다."),
                    primaryButton: .destructive(Text("탈퇴")) {
                        // "예"를 선택했을 때의 동작
                        // 토큰 삭제 및 로그아웃 처리
                        authModel.handleKakaoLogout()
                    },
                    secondaryButton: .cancel(Text("취소"))
                )
            }
        }
    }
}

struct SettingsViewPreviews: PreviewProvider {
    static var previews: some View {
        let authModel: AuthModel = AuthModel()
        SettingsView(authModel: authModel)
    }
}
