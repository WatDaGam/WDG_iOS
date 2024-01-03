//
//  SettingsView.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 10/28/23.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authModel: AuthModel
    @EnvironmentObject var locationModel: LocationModel
    @Binding var alertType: AlertType?
    @Binding var selectedTab: Int
    var body: some View {
        VStack {
//            BannerContentView(navigationTitle: "settings", adUnitID: "ca-app-pub-3940256099942544/6300978111")
//            Divider()
            List {
                Button("내가 쓴 글", action: { selectedTab = 3 })
                Button("차단목록", action: { selectedTab = 4 })
                Button("로그아웃", action: { alertType = .logout })
                Button("회원탈퇴", action: { alertType = .removeAccount })
            }
            .listStyle(.plain)
            Spacer()
        }
    }
}

struct SettingsViewPreviews: PreviewProvider {
    @State static var selectedTab: Int = 2
    @State static var alertType: AlertType?
    static var previews: some View {
        let postModel = PostModel()
        SettingsView(
            alertType: $alertType,
            selectedTab: $selectedTab
        )
            .environmentObject(postModel)
    }
}
