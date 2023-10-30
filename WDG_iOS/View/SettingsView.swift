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
        VStack {
            Button("KAKAO LOGOUT", action: { authKakao.handleKakaoLogout() })
        }
    }
}
