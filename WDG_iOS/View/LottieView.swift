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
    private let animationView: LottieAnimationView
    init(name: String, loopMode: LottieLoopMode) {
        self.name = name
        self.loopMode = loopMode
        self.animationView = LottieAnimationView(name: name)
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
    func makeUIView(context: Context) -> Lottie.LottieAnimationView {
        animationView.play()
        animationView.loopMode = loopMode
        animationView.contentMode = .scaleAspectFit
        return animationView
    }
    func play() {
        animationView.play()
    }

    func stop() {
        animationView.stop()
    }
}
