//
//  PostView.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 10/28/23.
//

import SwiftUI
import CoreLocation

struct PostView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var message: String = ""
    @Binding private var postAlertType: PostAlertType?
    var latitude: Double
    var longitude: Double
    var locationName: String
    public init(
        postAlertType: Binding<PostAlertType?>, latitude: Double, longitude: Double, locationName: String
    ) {
        _postAlertType = postAlertType
        self.latitude = latitude
        self.longitude = longitude
        self.locationName = locationName
    }
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            VStack {
                PostHeader(postAlertType: $postAlertType)
                HStack {
                    Text(locationName)
                    Spacer()
                    Text("\(latitude) \(longitude)")
                }
                .padding(.horizontal)
                .font(.subheadline)
                .foregroundColor(.gray)
                VStack {
                    TextEditor(text: $message)
                        .onReceive(message.publisher.collect()) {
                            self.message = String($0.prefix(50))
                        }
                        .frame(maxHeight: .infinity, alignment: .top)
                        .font(.title)
                        .foregroundColor(.black)
                    Spacer()
                }
                .frame(maxHeight: .infinity)
                .padding(.horizontal)
                HStack {
                    Spacer()
                    VStack(spacing: 5) {
                        Text("\(message.count)/50")
                            .padding(.leading)
                        Button(action: {
                            postAlertType = .post
                        }, label: {
                            Text("남기기")
                        })
                        .frame(width: 65)
                        .frame(height: 45)
                        .background(.gray)
                        .foregroundColor(.black)
                        .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                Spacer()
            }
            .background(Rectangle().foregroundColor(.white))
        }
//        .alert(item: $alertType) { type in
//            switch type {
//            case .cancle:
//                return Alert(
//                    title: Text("취소"),
//                    message: Text("취소 시 작성중인 게시글은 저장되지 않습니다."),
//                    primaryButton: .destructive(Text("예")) {
//                    },
//                    secondaryButton: .cancel(Text("아니오"))
//                )
//            case .post:
//                return Alert(
//                    title: Text("게시"),
//                    message: Text("현재 작성중인 글이 게시됩니다."),
//                    primaryButton: .destructive(Text("게시")) {
//                        //                        Task {
//                        //                            await authModel.deleteAccount()
//                        //                        }
//                    },
//                    secondaryButton: .cancel(Text("취소"))
//                )
//            }
//        }
    }
}

struct PostHeader: View {
    @Binding var postAlertType: PostAlertType?
    var body: some View {
        HStack {
            Button(action: {
                print("cancle click")
                postAlertType = .cancle
            }, label: {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("취소")
                        .padding(-5)
                }
            })
            Spacer()
        }
        .foregroundColor(.white)
        .padding(.horizontal)
        .frame(height: 60)
        .frame(maxWidth: .infinity)
        .background(Rectangle().foregroundColor(.black))
    }
}

struct PostViewPreviews: PreviewProvider {
    @State static var latitude: Double = 37.5666612
    @State static var longitude: Double = 126.9783785
    @State static var selectedTab: Int = 1
    @State static var postAlertType: PostAlertType?
    static var previews: some View {
        PostView(
            postAlertType: $postAlertType,
            latitude: latitude,
            longitude: longitude,
            locationName: "고양동"
        )
    }
}
