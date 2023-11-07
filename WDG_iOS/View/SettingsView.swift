//
//  SettingsView.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 10/28/23.
//

import SwiftUI

enum SettingsNavigationDestination {
    case profile
    // 다른 네비게이션 목적지를 추가할 수 있습니다.
}

struct SettingsView: View {
    @EnvironmentObject var authModel: AuthModel
    @EnvironmentObject var locationModel: LocationModel
    @State private var alertType: AlertType?
    @State private var selectedNavigation: SettingsNavigationDestination?
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
    // 네비게이션 바의 외관을 설정하는 초기화자 추가
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.black // 검정색 배경 설정
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white] // 타이틀 텍스트 색상을 흰색으로 설정
        // 네비게이션 바의 기본 외관을 설정
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        // 네비게이션 바의 버튼 아이템 색상을 설정
        UINavigationBar.appearance().tintColor = .white
    }
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                List {
                    NavigationLink("프로필", value: SettingsNavigationDestination.profile)
                    Button("내 작성 목록", action: { print("my list clicked!") })
                    Button("로그아웃", action: { alertType = .logout })
                    Button("회원탈퇴", action: { alertType = .removeAccount })
                }
                .listStyle(.plain)
            }
            .navigationBarTitle("마이페이지", displayMode: .inline)
            .navigationDestination(for: SettingsNavigationDestination.self) { destination in
                switch destination {
                case .profile:
                    ProfileView()
                        .environmentObject(locationModel)
                }
            }
            .alert(item: $alertType) { type in
                switch type {
                case .logout:
                    return Alert(
                        title: Text("로그아웃"),
                        message: Text("로그아웃 시 로그인 화면으로 이동합니다."),
                        primaryButton: .destructive(Text("예")) {
                            authModel.handleLogout()
                        },
                        secondaryButton: .cancel(Text("아니오"))
                    )
                case .removeAccount:
                    return Alert(
                        title: Text("회원탈퇴"),
                        message: Text("회원탈퇴 시 모든 데이터가 삭제됩니다."),
                        primaryButton: .destructive(Text("탈퇴")) {
                            Task {
                                await authModel.deleteAccount()
                            }
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
        let postModel = PostModel()
        SettingsView()
            .environmentObject(postModel)
    }
}
