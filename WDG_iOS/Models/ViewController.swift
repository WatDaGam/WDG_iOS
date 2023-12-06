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

//class ViewController: UIViewController {
//    private var snackBarLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.backgroundColor = .darkGray // 스낵바 배경색
//        label.textColor = .white // 텍스트 색상
//        label.font = UIFont.preferredFont(forTextStyle: .body)
//        label.textAlignment = .center
//        label.text = "스낵바 메시지"
//        label.layer.cornerRadius = 8 // 모서리 둥글게
//        label.clipsToBounds = true // 모서리 둥글기 적용
//        return label
//    }()
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .white
//        setupSnackBar()
//    }
//    func setupSnackBar() {
//        view.addSubview(snackBarLabel)
//        NSLayoutConstraint.activate([
//            snackBarLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            snackBarLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            snackBarLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
//            snackBarLabel.heightAnchor.constraint(equalToConstant: 50) // 스낵바 높이
//        ])
//    }
//    //    let button: UIButton = {
//    //        let button = UIButton(type: .system)
//    //        button.setTitle("Show", for: .normal)
//    //        button.addTarget(ViewController.self, action: #selector(buttonTapped), for: .touchUpInside)
//    //        return button
//    //    }()
//    //    let label = UILabel()
//    
//    //    override func viewDidLoad() {
//    //        super.viewDidLoad()
//    //        setupLabel()
//    //    }
//    
//    //    func setupLabel() {
//    //        label.text = "기본 텍스트"
//    //        label.textAlignment = .center
//    //        self.view.addSubview(label)
//    //        button.snp.makeConstraints {
//    //            $0.center.equalTo(self.view)
//    //        }
//    //        label.translatesAutoresizingMaskIntoConstraints = false
//    //        NSLayoutConstraint.activate([
//    //            label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
//    //            label.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
//    //        ])
//    //    }
//    
//    //    func updateData(_ data: String) {
//    //        label.text = data
//    //    }
//    
//    //    override func viewDidLoad() {
//    //        super.viewDidLoad()
//    //        self.view.addSubview(button)
//    //        button.snp.makeConstraints {
//    //            $0.center.equalTo(self.view)
//    //        }
//    //    }
//    //    @objc func buttonTapped(_ sender: UIButton) {
//    //        print("tapped")
//    //        AppSnackBar.make(
//    //            in: self.view,
//    //            message: "The Internet connection appears to be offline.",
//    //            duration: .lengthLong
//    //        ).setAction(
//    //            with: "Retry",
//    //            action: { }
//    //        ).show()
//    //    }
//}

class ViewController: UIViewController {
    private var snackBarLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        // 기타 초기 설정
    }

    func showSnackBar(with message: String) {
        // 기존 스낵바가 이미 표시되어 있으면 제거
        snackBarLabel?.removeFromSuperview()

        // 새 스낵바 생성
        let label = UILabel()
        label.backgroundColor = .darkGray
        label.textColor = .white
        label.textAlignment = .center
        label.text = message
        label.alpha = 0
        label.layer.cornerRadius = 8
        label.clipsToBounds = true

        // 뷰에 추가
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            label.heightAnchor.constraint(equalToConstant: 50)
        ])

        // 애니메이션으로 스낵바 보이기
        UIView.animate(withDuration: 0.5, animations: {
            label.alpha = 1
        }) { _ in
            // 일정 시간 후 스낵바 숨기기
            UIView.animate(withDuration: 0.5, delay: 2, options: [], animations: {
                label.alpha = 0
            }) { _ in
                label.removeFromSuperview()
            }
        }

        // 참조 유지
        snackBarLabel = label
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
