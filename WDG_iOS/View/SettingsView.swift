//
//  SettingsView.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 10/28/23.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var authModel: AuthModel
    @State private var alertType: AlertType?
    enum AlertType: Identifiable {
        case logout
        case removeAccount
        var id: Int {
            switch self {
            case .logout:
                return 0
            case .removeAccount:
                return 1
            }
        }
    }
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                List {
                    Button("프로필", action: { print("profile clicked!") })
                    Button("내 작성 목록", action: { print("my list clicked!") })
                    Button("로그아웃", action: { alertType = .logout })
                    Button("회원탈퇴", action: { alertType = .removeAccount })
                }
                .listStyle(.plain)
            }
            .navigationBarTitle("마이페이지", displayMode: .inline)
            .alert(item: $alertType) { type in
                switch type {
                case .logout:
                    return Alert(
                        title: Text("로그아웃"),
                        message: Text("로그아웃 시 로그인 화면으로 이동합니다."),
                        primaryButton: .destructive(Text("예")) {
                            authModel.handleKakaoLogout()
                        },
                        secondaryButton: .cancel(Text("아니오"))
                    )
                case .removeAccount:
                    return Alert(
                        title: Text("회원탈퇴"),
                        message: Text("회원탈퇴 시 모든 데이터가 삭제됩니다."),
                        primaryButton: .destructive(Text("탈퇴")) {
                            authModel.deleteAccountWithKakao()
                        },
                        secondaryButton: .cancel(Text("취소"))
                    )
                }
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
