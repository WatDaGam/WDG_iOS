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
            BannerContentView(navigationTitle: "settings", adUnitID: "ca-app-pub-7132344735506626/9039057664")
            Divider()
            List {
                Button("프로필", action: { selectedTab = 3 })
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
