//
//  ContentView.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 10/28/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authModel: AuthModel
    @EnvironmentObject var tokenModel: TokenModel
    @EnvironmentObject var locationModel: LocationModel
    @State var latitude: Double = 0
    @State var longitude: Double = 0
    @State var selectedTab: Int = 0
    var body: some View {
        VStack {
            if authModel.isNewAccount && authModel.isLoggedIn {
                SetNicknameView()
            } else if authModel.isLoggedIn {
                VStack {
                    if selectedTab == 0 {
                        MainListView(latitude: $latitude, longitude: $longitude)
                            .environmentObject(locationModel)
                    } else if selectedTab == 1 {
                        PostView(latitude: latitude, longitude: longitude, locationName: "test")
                            .environmentObject(locationModel)
                    } else {
                        SettingsView()
                    }
                    Spacer()
                    Divider()
                    MyTabView(selectedTab: $selectedTab)
                }
            } else {
                // 사용자가 로그인하지 않은 경우 LoginView 표시
                LoginView()
            }
        }
        .alert(isPresented: $authModel.loginFailedAlert) {
            Alert(
                title: Text("로그인에 실패하였습니다."),
                message: Text("다시 시도해주세요.")
            )
        }
        .alert(isPresented: $tokenModel.isValidToken.inverted) {
            Alert(
                title: Text("로그인이 만료되었습니다."),
                message: Text("다시 로그인해주세요.")
            )
        }
    }
}

struct MyTabView: View {
    @Binding var selectedTab: Int
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                self.selectedTab = 0
            }) {
                Image(systemName: "list.bullet")
                    .resizable()
                    .frame(width: 30, height: 30)
            }
            Spacer()
            Spacer()
            Button(action: {
                self.selectedTab = 1
            }) {
                Image(systemName: "square.and.pencil")
                    .resizable()
                    .frame(width: 30, height: 30)
            }
            Spacer()
            Spacer()
            Button(action: {
                self.selectedTab = 2
            }) {
                Image(systemName: "person")
                    .resizable()
                    .frame(width: 30, height: 30)
            }
            Spacer()
        }
        .padding(.horizontal)
        .frame(height: 80)
        .background(Rectangle().foregroundColor(.white))
        .foregroundColor(.black)
    }
}

extension Binding where Value == Bool {
    /// A binding to the inverse of the bool value.
    var inverted: Binding<Bool> {
        Binding<Bool>(
            get: { !self.wrappedValue },
            set: { self.wrappedValue = !$0 }
        )
    }
}

struct ContentPreview: PreviewProvider {
    static var previews: some View {
        let tokenModel = TokenModel()
        let authModel = AuthModel(tokenModel: tokenModel)
        let postModel = PostModel()
        let locationModel = LocationModel()
        authModel.isLoggedIn = true
        return ContentView()
            .environmentObject(authModel)
            .environmentObject(tokenModel)
            .environmentObject(postModel)
            .environmentObject(locationModel)
    }
}
