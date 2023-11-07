//
//  MainListView.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 10/27/23.
//

import SwiftUI
import CoreLocation

struct MainListView: View {
    @EnvironmentObject var authModel: AuthModel
    @EnvironmentObject var tokenModel: TokenModel
    @EnvironmentObject var postModel: PostModel
    @EnvironmentObject var locationModel: LocationModel
    var body: some View {
        VStack {
            Header(locationModel : locationModel)
                .environmentObject(postModel)
            List {
                ForEach(postModel.posts) { post in
                    Post(post: post)
                        .environmentObject(locationModel)
                }
            }
            .listStyle(.plain)
        }
    }
}

struct Header: View {
    @ObservedObject var locationModel: LocationModel
    @EnvironmentObject var postModel: PostModel
    @State private var selectedSortOption: String
    @State private var showingLocationSettingsAlert: Bool
    let sortOptions: [String]
    private var locationManager: CLLocationManager
    init(locationModel: LocationModel) {
        _locationModel = ObservedObject(initialValue: locationModel)
        _selectedSortOption = State(initialValue: "최신순")
        _showingLocationSettingsAlert = State(initialValue: false)
        sortOptions = ["최신순", "좋아요순"]
        locationManager = CLLocationManager()
    }
    var body: some View {
        HStack {
            WDGLogoView(size: 24, spacing: -4, mode: true)
            Spacer()
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
            Spacer()
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
        .padding(.horizontal)
        .frame(height: 80)
        .background(Rectangle().foregroundColor(.black))
    }
}

struct MainListViewPreviews: PreviewProvider {
    static var previews: some View {
        let postModel = PostModel()
        let locationModel = LocationModel()
        MainListView()
            .environmentObject(postModel)
            .environmentObject(locationModel)
    }
}
