//
//  SetNicknameView.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 10/30/23.
//

import SwiftUI

struct NicknameInfo {
    var message: String
    var color: Color
    var image: String
}

struct SetNicknameView: View {
    enum Field: Hashable { case nickname }
    @StateObject var setNickname: SetNicknameViewModel = SetNicknameViewModel()
    @State private var nickname: String = ""
    @FocusState private var focusField: Field?
    @ObservedObject var authKakao: AuthKakao
    init(authKakao: AuthKakao) {
        self.authKakao = authKakao
    }
    @State private var attempts: Int = 0
    @State private var mode: Bool = false
    @State private var isConfirm: Bool = false
    @State private var isValidNickname: Int = 0
    private var infoList: [String] = ["default", "fail", "success"]
    private var nicknameInfoDict: [String: NicknameInfo] = [
        "default": NicknameInfo(message: "닉네임은 2자부터 10자까지 설정할 수 있습니다.", color: Color.gray, image: "info.circle"),
        "fail": NicknameInfo(message: "닉네임을 사용하실 수 없습니다.", color: Color.red, image: "xmark.circle"),
        "success": NicknameInfo(message: "닉네임을 사용하실 수 있습니다.", color: Color.green, image: "checkmark.circle")
    ]
    var body: some View {
        NavigationView {
            VStack {
                WDGLogoView(mode: $mode)
                VStack {
                    HStack {
                        TextField("", text: $nickname)
                            .onChange(of: nickname) { oldValue, newValue in
                                if newValue.count > 10 { nickname = oldValue }
                                if nickname.isEmpty { isValidNickname = 0 }
                                isConfirm = false
                            }
                            .font(.system(size: 20, weight: .bold))
                            .focused($focusField, equals: .nickname)
                            .keyboardType(.asciiCapable)
                            .foregroundColor(.black)
                            .placeholder(when: nickname.isEmpty) {
                                Text("닉네임을 입력하세요.").foregroundColor(.gray)
                            }
                            .padding(.vertical, 10)
                            .overlay(Rectangle().frame(height: 2).padding(.top, 35))
                            .foregroundColor(.black)
                        Text("왔다감!")
                            .foregroundColor(.black)
                            .font(.system(size: 20))
                    }
                    .padding(.horizontal, 70)
                    HStack {
                        Image(systemName: nicknameInfoDict[infoList[isValidNickname]]?.image ?? "info.circle")
                            .foregroundColor(nicknameInfoDict[infoList[isValidNickname]]?.color ?? Color.gray)
                        Text(nicknameInfoDict[infoList[isValidNickname]]?.message ?? "")
                            .foregroundColor(nicknameInfoDict[infoList[isValidNickname]]?.color ?? Color.gray)
                            .font(.system(size: 14))
                    }
                    .modifier(Shake(animatableData: CGFloat(attempts)))
                    .frame(maxWidth: .infinity)
                    .padding(.top, -15)
                }
                Spacer()
                if isConfirm {
                    Button(action: {
                        authKakao.isNewAccount = !setNickname.setNickname(nickname: nickname)
                    }) {
                        Text("가입하기")
                            .font(Font.custom("Noto Sans", size: 20))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)  // 버튼의 너비를 화면 전체로 확장
                    .frame(height: 40)  // 버튼의 높이 설정
                    .background(.blue)
                    .padding(.bottom, 0)
                } else {
                    Button(action: {
                        isValidNickname = setNickname.checkNickname(nickname: nickname) ? 2 : 1
                        if infoList[isValidNickname] == "success" { isConfirm = true }
                        else {
                            withAnimation {
                                self.attempts += 1
                            }
                        }
                    }) {
                        Text("확인")
                            .font(Font.custom("Noto Sans", size: 20))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)  // 버튼의 너비를 화면 전체로 확장
                    .frame(height: 40)  // 버튼의 높이 설정
                    .background(.blue)
                    .padding(.bottom, 0)
                }
            }
            .navigationBarItems(leading: Button(
                action: {
                    // 토큰 삭제도 해줘야함
                    authKakao.isLoggedIn = false
                }, label: { Text("취소") })
            )
            .onAppear { focusField = .nickname }
        }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
}

struct SetNicknameViewPreviews: PreviewProvider {
    static var previews: some View {
        let authKakao: AuthKakao = AuthKakao()
        SetNicknameView(authKakao: authKakao)
    }
}
