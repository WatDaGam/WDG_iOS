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
//    public init(
//        settingAlertType: Binding<SettingAlertType?>,
//        selectedTab: Binding<Int>,
//    ) {
//        _settingAlertType = settingAlertType
//        _selectedTab = selectedTab
//    }
    var body: some View {
        List {
            Button("프로필", action: { selectedTab = 3 })
            Button("로그아웃", action: { alertType = .logout })
            Button("회원탈퇴", action: { alertType = .removeAccount })
        }
        .listStyle(.plain)
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
