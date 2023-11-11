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
    @Binding var messageForm: Message
    var latitude: Double
    var longitude: Double
    var locationName: String
    public init(
        postAlertType: Binding<PostAlertType?>,
        messageForm: Binding<Message>,
        latitude: Double,
        longitude: Double,
        locationName: String
    ) {
        _postAlertType = postAlertType
        _messageForm = messageForm
        self.latitude = latitude
        self.longitude = longitude
        self.locationName = locationName
    }
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            VStack {
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
                            messageForm.location = LocationType(latitude: latitude, longitude: longitude)
                            messageForm.message = message
                            messageForm.date = Date()
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
    }
}

struct PostViewPreviews: PreviewProvider {
    @State static var latitude: Double = 37.5666612
    @State static var longitude: Double = 126.9783785
    @State static var selectedTab: Int = 1
    @State static var postAlertType: PostAlertType?
    @State static var messageForm: Message = Message(
        nickname: "myNickname",
        message: "",
        date: Date(),
        location: LocationType(latitude: 37.56, longitude: 126.97),
        likes: 0
    )
    static var previews: some View {
        PostView(
            postAlertType: $postAlertType,
            messageForm: $messageForm,
            latitude: latitude,
            longitude: longitude,
            locationName: "고양동"
        )
    }
}
