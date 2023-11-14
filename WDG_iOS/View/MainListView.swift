//
//  MainListView.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 10/27/23.
//

import SwiftUI
import CoreLocation

struct MainListView: View {
    @EnvironmentObject var postModel: PostModel
    @EnvironmentObject var locationModel: LocationModel
    @Binding var latitude: Double
    @Binding var longitude: Double
    @Binding var scrollProxy: ScrollViewProxy?
    var namespace: Namespace.ID
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                Color.clear
                    .frame(height: 0)
                    .id(namespace)
                VStack {
                    ForEach(postModel.posts) { post in
                        Post(post: post)
                            .environmentObject(locationModel)
                        Divider()
                    }
                }
                .listStyle(.plain)
            }
            .onAppear {
                print("proxy: \(proxy)")
                scrollProxy = proxy // ScrollViewProxy를 저장합니다.
            }
        }
    }
}

struct MainNavbarCenter:View {
    @ObservedObject var locationModel: LocationModel
    @State private var showingLocationSettingsAlert: Bool
    @Binding var latitude: Double
    @Binding var longitude: Double
    private var locationManager: CLLocationManager
    init(locationModel: LocationModel, latitude: Binding<Double>, longitude: Binding<Double>) {
        _locationModel = ObservedObject(initialValue: locationModel)
        _showingLocationSettingsAlert = State(initialValue: false)
        locationManager = CLLocationManager()
        _latitude = latitude
        _longitude = longitude
    }
    var body: some View {
        VStack {
            Spacer()
            Button(action: {
                if locationManager.authorizationStatus == .denied {
                    showingLocationSettingsAlert = true
                }
            }, label: {
                Text(locationModel.locationName)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .font(.title3)
            })
            .alert(isPresented: $showingLocationSettingsAlert) {
                Alert(
                    title: Text("위치 서비스 필요"),
                    message: Text("위치 서비스를 사용하려면 설정에서 권한을 허용해 주세요."),
                    primaryButton: .default(Text("설정으로 이동")) {
                        // Take the user to the app settings
                        if let settingUrl = URL(string: UIApplication.openSettingsURLString),
                           UIApplication.shared.canOpenURL(settingUrl) {
                            UIApplication.shared.open(settingUrl, options: [:], completionHandler: nil)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
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
    static var previews: some View {
        let postModel = PostModel()
        let locationModel = LocationModel()
        @Namespace var mainListTop
        MainListView(
            latitude: $latitude,
            longitude: $longitude,
            scrollProxy: $scrollProxy,
            namespace: mainListTop
        )
            .environmentObject(postModel)
            .environmentObject(locationModel)
    }
}
