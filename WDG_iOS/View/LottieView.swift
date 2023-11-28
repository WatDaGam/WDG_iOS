//
//  LottieView.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 11/22/23.
//

import SwiftUI
import Lottie
import UIKit

struct LottieView: UIViewRepresentable {
    let name: String
    let loopMode: LottieLoopMode

    func updateUIView(_ uiView: UIViewType, context: Context) {

    }

    func makeUIView(context: Context) -> Lottie.LottieAnimationView {
        let animationView = LottieAnimationView(name: name)
        animationView.play()
        animationView.loopMode = loopMode
        animationView.contentMode = .scaleAspectFit
        return animationView
    }
}
