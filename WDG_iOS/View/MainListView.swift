//
//  MainListView.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 10/27/23.
//

import SwiftUI
import CoreLocation

struct MainListView: View {
    @EnvironmentObject var tokenModel: TokenModel
    @EnvironmentObject var authModel: AuthModel
    @EnvironmentObject var postModel: PostModel
    @EnvironmentObject var locationModel: LocationModel
    @Binding var alertType: AlertType?
    @Binding var latitude: Double
    @Binding var longitude: Double
    @Binding var scrollProxy: ScrollViewProxy?
    @Binding var reportPostId: Int
    @State private var currentScrollOffset: CGFloat = 0
    var namespace: Namespace.ID
    var body: some View {
        VStack {
//            BannerContentView(navigationTitle: "mainList", adUnitID: "ca-app-pub-3940256099942544/6300978111")
//            Divider()
            ScrollViewReader { proxy in
                ScrollView {
                    Color.clear
                        .frame(height: 0)
                        .id(namespace)
                    VStack {
                        ForEach(postModel.posts) { post in
                            Post(alertType: $alertType, reportPostId: $reportPostId, post: post)
                                .environmentObject(locationModel)
                                .environmentObject(tokenModel)
                                .environmentObject(authModel)
                                .environmentObject(postModel)
                            Divider()
                        }
                    }
                    .listStyle(.plain)
                    .background(.white)
                    .colorScheme(.light)
                }
                .onAppear {
                    scrollProxy = proxy // ScrollViewProxy를 저장합니다.
                }
                .onReceive(postModel.$posts) { _ in
                    // posts가 변경될 때 스크롤 위치를 유지
                    withAnimation {
                        proxy.scrollTo(currentScrollOffset, anchor: .top)
                    }
                }
                .refreshable {
                    Task {
                        await reloadData()
                    }
                }
            }
        }
    }
    func reloadData() async {
        // 여기에 새로고침 로직 구현
        // 예: 새로운 데이터 가져오기, 위치 정보 업데이트 등
        await tokenModel.validateToken(authModel: authModel)
        await postModel.getStoryList(
            accessToken: tokenModel.getToken("accessToken") ?? "",
            lati: locationModel.currentLocation?.coordinate.latitude ?? 37.56,
            longi: locationModel.currentLocation?.coordinate.longitude ?? 126.97
        )
    }
}

struct MainNavbarCenter:View {
    @ObservedObject var locationModel: LocationModel
    @Binding var latitude: Double
    @Binding var longitude: Double
    @Binding var alertType: AlertType?
    private var locationManager: CLLocationManager
    init(
        locationModel: LocationModel,
        latitude: Binding<Double>,
        longitude: Binding<Double>,
        alertType: Binding<AlertType?>
    ) {
        _locationModel = ObservedObject(initialValue: locationModel)
        locationManager = CLLocationManager()
        _latitude = latitude
        _longitude = longitude
        _alertType = alertType
    }
    var body: some View {
        VStack {
            Spacer()
            Button(action: {
                if locationManager.authorizationStatus == .denied {
                    alertType = .locationAuth
                }
            }, label: {
                Text(locationModel.locationName)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .font(.title3)
            })
            Spacer()
            if let location = locationModel.location {
                Text("\(location.coordinate.latitude) \(location.coordinate.longitude)")
                    .font(.subheadline)
                    .foregroundColor(.white)
            } else {
                Text("Locating...")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            Spacer()
        }
    }
}

struct MainNavbarRight: View {
    @State private var selectedSortOption: String = "최신순"
    let sortOptions: [String] = ["최신순", "좋아요순"]
    @ObservedObject var postModel: PostModel
    var body: some View {
        Menu {
            ForEach(sortOptions, id: \.self) { option in
                Button(option) {
                    selectedSortOption = option
                    if option == "최신순" {
                        postModel.sortByDate()
                    } else {
                        postModel.sortByLikes()
                    }
                }
            }
        } label: {
            Label(selectedSortOption, systemImage: "arrow.down")
                .font(.subheadline)
                .foregroundColor(.white)
        }
    }
}

struct MainListViewPreviews: PreviewProvider {
    @State static var latitude: Double = 37.5666612
    @State static var longitude: Double = 126.9783785
    @State static var scrollProxy: ScrollViewProxy?
    @State static var alertType: AlertType?
    @State static var reportPostId: Int = 0
    static var previews: some View {
        let tokenModel = TokenModel()
        let authModel = AuthModel(tokenModel: tokenModel)
        let postModel = PostModel()
        let locationModel = LocationModel(tokenModel: tokenModel, authModel: authModel, postModel: postModel)
        @Namespace var mainListTop
        MainListView(
            alertType: $alertType,
            latitude: $latitude,
            longitude: $longitude,
            scrollProxy: $scrollProxy,
            reportPostId: $reportPostId,
            namespace: mainListTop
        )
        .environmentObject(postModel)
        .environmentObject(locationModel)
    }
}
