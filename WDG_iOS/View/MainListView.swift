//
//  MainListView.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 10/27/23.
//

import SwiftUI

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
    @State private var selectedSortOption = "최신순"
    let sortOptions = ["최신순", "좋아요순"] // 정렬 옵션 목록
    var body: some View {
        HStack {
            WDGLogoView(size: 24, spacing: -4, mode: true)
            Spacer()
            VStack {
                Spacer()
                Text(locationModel.locationName)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .font(.title2)
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
