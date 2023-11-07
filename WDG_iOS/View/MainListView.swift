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
    var body: some View {
        VStack {
            Header()
            List {
                ForEach(postModel.posts) { post in
                    Post(post: post)
                }
            }
            .listStyle(.plain)
        }
    }
}

struct Header: View {
    var body: some View {
        HStack {
            WDGLogoView(size: 34, spacing: -5, mode: true)
//            Image(systemName: "heart")
            Spacer()
            VStack {
                Spacer()
                Text("서초동")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .font(.title2)
                Spacer()
                Text("대충 위치")
                    .foregroundColor(.white)
                    .font(.caption)
                Spacer()
            }
            Spacer()
            WDGLogoView(size: 34, spacing: -5, mode: false)
        }
        .frame(height: 80)
        .background(Rectangle().foregroundColor(.black))
    }
}

struct MainListViewPreviews: PreviewProvider {
    static var previews: some View {
        let postModel = PostModel()
        MainListView()
            .environmentObject(postModel)
    }
}
