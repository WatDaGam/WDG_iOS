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
    @Binding var alertType: AlertType?
    @StateObject var setNickname: SetNicknameViewModel = SetNicknameViewModel()
    @EnvironmentObject var authModel: AuthModel
    @EnvironmentObject var tokenModel: TokenModel
    @EnvironmentObject var postModel: PostModel
    @EnvironmentObject var locationModel: LocationModel
    @FocusState private var focusField: Bool
    @State private var nickname: String = ""
    @State private var attempts: Int = 0
    @State private var isCancle: Bool = false
    @State private var isConfirm: Bool = false
    @State private var isValidNickname: Int = 0
    @State private var isAgreement: Bool = false
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
    init(alertType: Binding<AlertType?>) {
        _alertType = alertType
    }
    var body: some View {
        if isAgreement {
            VStack {
                HStack {
                    Button(action: {
                        alertType = .isCancleSignIn
                    }, label: {
                        Text("취소")
                            .foregroundColor(.blue)
                    })
                    .padding(.leading, 20)
                    Spacer()
                }
                WDGLogoView(size: 68, spacing: -10, mode: false)
                VStack {
                    HStack {
                        TextField("", text: $nickname)
                            .onReceive(nickname.publisher.collect()) { newValue in
                                let newNickname = String(newValue.prefix(10))
                                if newNickname.count > 10 {
                                    nickname = newNickname
                                }
                                if newNickname.isEmpty {
                                    isValidNickname = 0
                                }
                                isConfirm = false
                            }
                            .font(.system(size: 20, weight: .bold))
                            .focused($focusField)
                            .keyboardType(.default)
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
                if self.setNickname.getIsConfirm() {
                    Button(action: {
                        Task {
                            let result = await self.setNickname.setNickname(nickname: nickname)
                            self.isValidNickname = result ? 2 : 1
                            self.authModel.isNewAccount = !result
                            if result {
                                await self.postModel.getStoryList(
                                    accessToken: self.tokenModel.getToken("accessToken") ?? "",
                                    lati: self.locationModel.currentLocation?.coordinate.latitude,
                                    longi: self.locationModel.currentLocation?.coordinate.longitude
                                )
                            }
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
                            self.isValidNickname = await self.setNickname.checkNickname(
                                nickname: nickname
                            ) ? 2 : 1
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
            .onAppear {
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + 0.2, execute: {
                        focusField = true
                    }
                )
            }
        } else {
            VStack {
                HStack {
                    Button(action: {
                        alertType = .isCancleSignIn
                    }, label: {
                        Text("취소")
                            .foregroundColor(.blue)
                    })
                    .padding(.leading, 20)
                    Spacer()
                }
                WDGLogoView(size: 68, spacing: -10, mode: false)
                    .padding(.bottom, 10)
                Text("왔다감에 오신것을 환영합니다!")
                    .font(.system(size: 24, weight: .bold))
                Spacer()
                Text("유의 사항을 확인해주세요.")
                    .padding(.bottom, 20)
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                        Text("위치 정보의 안전한 사용")
                            .font(.system(size: 16))
                    }
                    Text("우리 앱은 위치 정보를 사용합니다. 개인의 위치 정보를 공유하지 않도록 주의해 주세요‼️")
                        .font(.system(size: 14))
                        .padding(.bottom, 10)
                    HStack {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                        Text("개인 정보 보호")
                            .font(.system(size: 16))
                    }
                    Text("개인 신상 정보나 타인의 개인정보를 포함하는 내용은 게시하지 말아주세요.🙅‍♀️🙅‍♂️")
                        .font(.system(size: 14))
                        .padding(.bottom, 10)
                    HStack {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                        Text("존중과 예의를 지켜주세요.")
                            .font(.system(size: 16))
                    }
                    Text("모든 사용자가 존중받고 안전하게 느낄 수 있도록, 예의 바른 언어 사용을 부탁드려요.🙏")
                        .font(.system(size: 14))
                        .padding(.bottom, 10)
                    HStack {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                        Text("신고 및 차단")
                            .font(.system(size: 16))
                    }
                    Text("부적절한 게시글 및 사용자가 보이면 신고 및 차단 기능을 이용해보세요.🚨")
                        .font(.system(size: 14))
                }

                .frame(width: UIScreen.main.bounds.width * 0.8)
                Spacer()
                Button(action: {
                    isAgreement = true
                }, label: {
                    Text("동의합니다.")
                        .font(Font.custom("Noto Sans", size: 20))
                        .foregroundColor(.white)
                })
                .frame(maxWidth: .infinity)  // 버튼의 너비를 화면 전체로 확장
                .frame(height: 50)  // 버튼의 높이 설정
                .background(.blue)
                .padding(.bottom, 0)
            }
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

//struct SetNicknameViewPreviews: PreviewProvider {
//    @State static var alertType: AlertType?
//    static var previews: some View {
//        let tokenModel = TokenModel()
//        let authModel = AuthModel(tokenModel: tokenModel)
//        SetNicknameView(alertType: $alertType)
//            .environmentObject(authModel)
//    }
//}
