//
//  ViewController.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 11/29/23.
//

import UIKit
import SwiftUI
import SnapKit
import SnackBar

class ViewController: UIViewController {
    let button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Show", for: .normal)
        button.addTarget(ViewController.self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(button)
        button.snp.makeConstraints {
            $0.center.equalTo(self.view)
        }
    }
    @objc func buttonTapped(_ sender: UIButton) {
        AppSnackBar.make(
            in: self.view,
            message: "The Internet connection appears to be offline.",
            duration: .lengthLong
        ).setAction(
            with: "Retry",
            action: { }
        ).show()
    }
}

class AppSnackBar: SnackBar {
    override var style: SnackBarStyle {
        var style = SnackBarStyle()
        style.background = .red
        style.textColor = .green
        return style
    }
}

struct ViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ViewController {
        // ViewController 인스턴스 생성
        return ViewController()
    }
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        // SwiftUI 뷰 업데이트 시 실행할 코드
    }
}

struct ViewControllerWrapper_Previews: PreviewProvider {
    static var previews: some View {
        ViewControllerWrapper()
    }
}
