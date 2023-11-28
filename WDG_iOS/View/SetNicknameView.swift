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
    @EnvironmentObject var authModel: AuthModel
    @State private var attempts: Int = 0
    @State private var isCancle: Bool = false
    @State private var isConfirm: Bool = false
    @State private var isValidNickname: Int = 0
    private var infoList: [String] = ["default", "fail", "success"]
    private var nicknameInfoDict: [String: NicknameInfo] = [
        "default": NicknameInfo(
            message: "닉네임은 2자부터 10자까지 설정할 수 있습니다.", color: Color.gray, image: "info.circle"
        ),
        "fail": NicknameInfo(
            message: "닉네임을 사용하실 수 없습니다.", color: Color.red, image: "xmark.circle"
        ),
        "success": NicknameInfo(
            message: "닉네임을 사용하실 수 있습니다.", color: Color.green, image: "checkmark.circle"
        )
    ]
//    init(authModel: AuthModel) {
//        _authModel = ObservedObject(wrappedValue: authModel)
//    }
    var body: some View {
        NavigationView {
            VStack {
                WDGLogoView(size: 68, spacing: -10, mode: false)
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
                        Task {
                            let result = await self.setNickname.setNickname(nickname: nickname)
                            self.isValidNickname = result ? 2 : 1
                            self.authModel.isNewAccount = !result
                        }
                    }, label: {
                        Text("가입하기")
                            .font(Font.custom("Noto Sans", size: 20))
                            .foregroundColor(.white)
                    })
                    .frame(maxWidth: .infinity)  // 버튼의 너비를 화면 전체로 확장
                    .frame(height: 50)  // 버튼의 높이 설정
                    .background(.blue)
                    .padding(.bottom, 0)
                } else {
                    Button(action: {
                        Task {
                            self.isValidNickname = await self.setNickname.checkNickname(nickname: nickname) ? 2 : 1
                            if self.infoList[isValidNickname] == "success" {
                                self.isConfirm = true
                            } else {
                                withAnimation {
                                    self.attempts += 1
                                }
                            }
                        }
                    }, label: {
                        Text("확인")
                            .font(Font.custom("Noto Sans", size: 20))
                            .foregroundColor(.white)
                    })
                    .frame(maxWidth: .infinity)  // 버튼의 너비를 화면 전체로 확장
                    .frame(height: 50)  // 버튼의 높이 설정
                    .background(.blue)
                    .padding(.bottom, 0)
                }
            }
            .navigationBarItems(leading: Button(
                action: {
                    // 경고창을 표시
                    isCancle = true
                }, label: { Text("취소") })
            )
            .alert(isPresented: $isCancle) {
                Alert(
                    title: Text("회원가입 취소"),
                    message: Text("취소 시 정보가 저장되지 않습니다."),
                    primaryButton: .destructive(Text("예")) {
                        // "예"를 선택했을 때의 동작
                        // 토큰 삭제 및 로그아웃 처리
                        Task {
                            await self.authModel.deleteAccount()
                        }
                    },
                    secondaryButton: .cancel(Text("아니오"))
                )
            }
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
        let tokenModel = TokenModel()
        let authModel = AuthModel(tokenModel: tokenModel)
        SetNicknameView()
            .environmentObject(authModel)
    }
}
