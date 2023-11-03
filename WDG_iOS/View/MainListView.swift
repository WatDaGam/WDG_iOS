//
//  MainListView.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 10/27/23.
//

import SwiftUI

struct MainListView: View {
    @ObservedObject var authModel: AuthModel
    var body: some View {
        VStack {
            Button(action: {
                authModel.validateToken()
            }, label: {
                Text("토큰 재발급 테스트")
            })
        }
    }
}
