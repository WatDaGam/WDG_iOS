//
//  SetNicknameView.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 10/30/23.
//

import SwiftUI

struct SetNicknameView: View {
    enum Field: Hashable { case nickname }
    @State private var nickname: String = ""
    @FocusState private var focusField: Field?
    @ObservedObject var authKakao: AuthKakao
    @State private var mode: Bool = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack(spacing: 50) {
                WDGLogoView(mode: $mode)
                HStack {
                    TextField("", text: $nickname)
                        .onChange(of: nickname) { newValue in
                            if newValue.count > 10 {
                                nickname = String(newValue.prefix(10))
                            }
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

                Button(action: {
                    authKakao.isNewAccount = false
                }) {
                    Text("확인")
                        .font(Font.custom("Noto Sans", size: 20))
                        .foregroundColor(.white)
                        .background(Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 80, height: 40)
                            .background(.primary)
                            .cornerRadius(15))
                }
                .padding(.top, 35)
            }
            .padding(.bottom, 30)
            .navigationBarItems(leading: Button("취소") {
                presentationMode.wrappedValue.dismiss()
            })
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

//struct SetNicknameViewPreviews: PreviewProvider {
//    static var previews: some View {
//        SetNicknameView()
//    }
//}
