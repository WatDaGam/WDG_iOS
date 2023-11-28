//
//  ContentView.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 10/28/23.
//

import SwiftUI

enum AlertType: Identifiable {
    case logout
    case removeAccount
    case postCancle
    case postUpload
    var id: Int {
        switch self {
        case .logout:
            return 0
        case .removeAccount:
            return 1
        case .postUpload:
            return 2
        case .postCancle:
            return 3
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var authModel: AuthModel
    @EnvironmentObject var tokenModel: TokenModel
    @EnvironmentObject var locationModel: LocationModel
    @EnvironmentObject var postModel: PostModel
    @EnvironmentObject var userInfo: UserInfo
    @Namespace var mainListTop
    @State var scrollProxy: ScrollViewProxy?
    @State var alertType: AlertType?
    @State var latitude: Double = 0
    @State var longitude: Double = 0
    @State var selectedTab: Int = 0
    @State var messageForm: Message = Message(
        id: 0,
        nickname: "myNickname",
        message: "",
        date: Date(),
        location: LocationType(latitude: 37.56, longitude: 126.97),
        likes: 0
    )
    var body: some View {
        VStack {
            if authModel.isNewAccount && authModel.isLoggedIn {
                SetNicknameView()
                    .environmentObject(authModel)
            } else if authModel.isLoggedIn {
                VStack {
                    switch selectedTab {
                    case 0:
                        mainListNavbarView()
                        MainListView(
                            latitude: $latitude,
                            longitude: $longitude,
                            scrollProxy: $scrollProxy,
                            namespace: mainListTop
                        )
                        .environmentObject(locationModel)
                        .environmentObject(postModel)
                        .onAppear {
                            Task {
                                await userInfo.getUserInfo()
                            }
                        }
                    case 1:
                        postNavbarView()
                        PostView(
                            alertType: $alertType,
                            messageForm: $messageForm,
                            latitude: locationModel.getCurrentLocation().coordinate.latitude,
                            longitude: locationModel.getCurrentLocation().coordinate.longitude,
                            locationName: locationModel.getLocationName()
                        )
                        .environmentObject(locationModel)
                    case 2:
                        settingsNavbarView()
                        SettingsView(
                            alertType: $alertType,
                            selectedTab: $selectedTab
                        )
                        .onAppear {
                            Task {
                                await userInfo.getUserInfo()
                            }
                        }
                    case 3:
                        profileNavbarView()
                        ProfileView(
                            nickname: userInfo.getUserNickname(),
                            numberOfPosts: userInfo.getUserStoryNum(),
                            numberOfLikes: userInfo.getUserLikeNum()
                        )
                    default:
                        EmptyView()
                    }
                    Divider()
                    if selectedTab != 1 {
                        MyTabView(
                            selectedTab: $selectedTab,
                            scrollProxy: $scrollProxy,
                            namespace: mainListTop
                        )
                    }
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
        .alert(item: $alertType) { type in
            switch type {
            case .logout:
                return Alert(
                    title: Text("로그아웃"),
                    message: Text("로그아웃 시 로그인 화면으로 이동합니다."),
                    primaryButton: .destructive(Text("예")) {
                        authModel.handleLogout()
                    },
                    secondaryButton: .cancel(Text("아니오"))
                )
            case .removeAccount:
                return Alert(
                    title: Text("회원탈퇴"),
                    message: Text("회원탈퇴 시 모든 데이터가 삭제됩니다."),
                    primaryButton: .destructive(Text("탈퇴")) {
                        Task {
                            await authModel.deleteAccount()
                        }
                    },
                    secondaryButton: .cancel(Text("취소"))
                )
            case .postCancle:
                return Alert(
                    title: Text("취소"),
                    message: Text("취소 시 작성중인 게시글은 저장되지 않습니다."),
                    primaryButton: .destructive(Text("예")) {
                        selectedTab = 0
                    },
                    secondaryButton: .cancel(Text("아니오"))
                )
            case .postUpload:
                return Alert(
                    title: Text("남기기"),
                    message: Text("현재 작성중인 글이 게시됩니다."),
                    primaryButton: .destructive(Text("게시")) {
                        Task {
                            await tokenModel.validateToken(authModel: authModel)
                            await postModel.uploadStory(
                                accessToken: tokenModel.getToken("accessToken") ?? "",
                                content: messageForm.message,
                                lati: messageForm.location.latitude,
                                longi: messageForm.location.longitude
                            )
                            await postModel.getStoryList(
                                accessToken: tokenModel.getToken("accessToken") ?? "",
                                lati: locationModel.getCurrentLocation().coordinate.latitude,
                                longi: locationModel.getCurrentLocation().coordinate.longitude
                            )
                        }
                        selectedTab = 0
                    },
                    secondaryButton: .cancel(Text("취소"))
                )
            }
        }
    }
    @ViewBuilder
    private func mainListNavbarView() -> some View {
        NavbarView(
            left: { WDGLogoView(size: 24, spacing: -4, mode: true) },
            center: {
                MainNavbarCenter(
                    locationModel : locationModel,
                    latitude: $latitude,
                    longitude: $longitude
                )
            },
            right: {
                MainNavbarRight(postModel: postModel)
            }
        )
    }
    @ViewBuilder
    private func postNavbarView() -> some View {
        NavbarView(
            left: {
                Button(action: {
                    print("cancle click")
                    alertType = .postCancle
                }, label: {
                    HStack {
                        Image(systemName: "chevron.left")
                    }
                })
                .foregroundColor(.white)
            },
            center: {
                Text("\(userInfo.getUserNickname()) 왔다감")
                    .foregroundStyle(.white)
            },
            right: {}
        )
    }
    @ViewBuilder
    private func settingsNavbarView() -> some View {
        NavbarView(
            left: {},
            center: {
                Text("마이페이지")
                    .foregroundStyle(.white)
            },
            right: {}
        )
    }
    @ViewBuilder
    private func profileNavbarView() -> some View {
        NavbarView(
            left: {
                Button(action: {
                    selectedTab = 2
                }, label: {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(.white)
                }) },
            center: {
                Text(userInfo.getUserNickname())
                    .foregroundColor(.white)
            },
            right: {}
        )
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
        let locationModel = LocationModel(tokenModel: tokenModel, authModel: authModel, postModel: postModel)
        authModel.isLoggedIn = true
        return ContentView()
            .environmentObject(authModel)
            .environmentObject(tokenModel)
            .environmentObject(postModel)
            .environmentObject(locationModel)
    }
}
