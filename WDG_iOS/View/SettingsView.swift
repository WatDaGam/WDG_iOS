//
//  SettingsView.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 10/28/23.
//

import SwiftUI

struct SettingsView: View {
    @StateObject var authKakao: AuthKakao = AuthKakao()
    var body: some View {
        VStack {            
            Text("Settings")
            Button("KAKAO LOGOUT", action: {
                authKakao.handleKakaoLogout()
            })
        }
    }
}

//#Preview {
//    SettingsView()
//}
