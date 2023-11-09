//
//  PostView.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 10/28/23.
//

import SwiftUI
import CoreLocation

enum PostAlertType: Identifiable {
    case cancle
    case post
    var id: Int {
        switch self {
        case .cancle:
            return 0
        case .post:
            return 1
        }
    }
}

struct PostView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var message: String = ""
    @State private var alertType: PostAlertType?
    @State private var geocodedAddress: String = "위치 확인 중..."
    @EnvironmentObject var locationModel: LocationModel
    var latitude: Double
    var longitude: Double
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            VStack {
                PostHeader(alertType: $alertType)
                HStack {
                    Text(geocodedAddress)
                    Spacer()
                    Text("\(latitude) \(longitude)")
                }
                .onAppear {
                    DispatchQueue.main.async { // 메인 스레드에서 상태 업데이트
                    print("PostView onAppear 시작")
                    let location = CLLocation(latitude: latitude, longitude: longitude)
                    locationModel.getReverseGeocode(location: location) { address in
                            print("Reverse geocode 완료: \(address)")
                            self.geocodedAddress = address
                        }
                    }
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
                            alertType = .post
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
        .alert(item: $alertType) { type in
            switch type {
            case .cancle:
                return Alert(
                    title: Text("취소"),
                    message: Text("취소 시 작성중인 게시글은 저장되지 않습니다."),
                    primaryButton: .destructive(Text("예")) {
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    secondaryButton: .cancel(Text("아니오"))
                )
            case .post:
                return Alert(
                    title: Text("게시"),
                    message: Text("현재 작성중인 글이 게시됩니다."),
                    primaryButton: .destructive(Text("게시")) {
                        //                        Task {
                        //                            await authModel.deleteAccount()
                        //                        }
                    },
                    secondaryButton: .cancel(Text("취소"))
                )
            }
        }
    }
}

struct PostHeader: View {
    @Binding var alertType: PostAlertType?
    var body: some View {
        HStack {
            Button(action: {
                alertType = .cancle
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
//
//struct PostViewPreviews: PreviewProvider {
//    @State static var latitude: Double = 37.5666612
//    @State static var longitude: Double = 126.9783785
//    static var previews: some View {
//        PostView(latitude: latitude, longitude: longitude)
//    }
//}
