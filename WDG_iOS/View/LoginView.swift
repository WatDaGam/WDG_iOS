//
//  LoginView.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 10/27/23.
//

import SwiftUI

struct LoginView: View {
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            WDGLogoView()
        }
    }
}

struct WDGLogoView: View {
    var body: some View {
        HStack(spacing: -10) {
            Text("W")
                .font(Font.custom("Dela Gothic One", size: 68))
                .foregroundColor(.white)
            Text("D")
                .font(Font.custom("Dela Gothic One", size: 68))
                .foregroundColor(.white)
            Text("G")
                .font(Font.custom("Dela Gothic One", size: 68))
                .foregroundColor(.white)
        }
    }
}

struct LoginView_Preview: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
