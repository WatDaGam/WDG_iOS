//
//  MainListView.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 10/27/23.
//

import SwiftUI

struct MainListView: View {
    @EnvironmentObject var authModel: AuthModel
    @EnvironmentObject var tokenModel: TokenModel
    var body: some View {
        VStack {
            Button(action: {
                Task {
                    await tokenModel.validateToken(authModel: authModel)
                }
            }, label: {
                Text("토큰 재발급 테스트")
            })
        }
    }
}
