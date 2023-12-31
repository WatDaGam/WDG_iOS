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
    @Binding var alertType: AlertType?
    @Binding var messageForm: Message
    var latitude: Double
    var longitude: Double
    var locationName: String
    @FocusState private var isInputActive: Bool
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Text(locationName)
                    Spacer()
//                    Text("\(latitude) \(longitude)")
                }
                .padding(.horizontal)
                .font(.subheadline)
                .foregroundColor(.gray)
                VStack {
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $message)
                            .focused($isInputActive)
                            .onReceive(message.publisher.collect()) {
                                self.message = String($0.prefix(100))
                            }
                            .padding(.horizontal, 4)
                        if message.isEmpty {
                            Text("여기에 메시지를 입력하세요")
                                .foregroundColor(Color.gray)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .onTapGesture {
                                    isInputActive = true
                                }
                        }
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    .font(.title)
                    .foregroundColor(.black)
                    Spacer()
                }
                HStack(alignment: .bottom) {
                    Text("부적절하거나 불쾌감을 줄 수 있는 컨텐츠를 게시할 경우 제재를 받을 수 있습니다.")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    Spacer()
                    VStack(alignment: .trailing, spacing: 5) {
                        Text("\(message.count)/100")
                            .padding(.leading)
                            .foregroundColor(.black)
                        Button(action: {
                            messageForm.location = LocationType(latitude: latitude, longitude: longitude)
                            messageForm.message = message
                            messageForm.date = Date()
                            alertType = .postUpload
                        }, label: {
                            Text("남기기")
                        })
                        .frame(width: 80)
                        .frame(height: 50)
                        .background(Color(hex: "#D9D9D9"))
                        .foregroundColor(.black)
                        .font(.headline)
                        .cornerRadius(10)
                    }
                }
                .frame(maxWidth: .infinity)
//                .foregroundColor(.white)
                .padding(.horizontal)
                Spacer()
            }
            .background(Color.white)
            .colorScheme(.light)
        }
        .onAppear {
            isInputActive = true
        }
    }
}

struct PostViewPreviews: PreviewProvider {
    @State static var latitude: Double = 37.5666612
    @State static var longitude: Double = 126.9783785
    @State static var selectedTab: Int = 1
    @State static var alertType: AlertType?
    @State static var messageForm: Message = Message(
        id: 0,
        userId: 0,
        nickname: "myNickname",
        message: "",
        date: Date(),
        location: LocationType(latitude: 37.56, longitude: 126.97),
        likes: 0
    )
    static var previews: some View {
        PostView(
            alertType: $alertType,
            messageForm: $messageForm,
            latitude: latitude,
            longitude: longitude,
            locationName: "고양동"
        )
    }
}
