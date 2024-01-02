//
//  ProfileView.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 11/4/23.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var postModel: PostModel
    @EnvironmentObject var locationModel: LocationModel
    @Binding var alertType: AlertType?
    @Binding var reportPostId: Int
    var nickname: String
    var numberOfPosts: Int
    var numberOfLikes: Int
    //    var numberOfFollowers: Int = 43214
    //    var numberOfFollowings: Int = 13
    var backButton : some View {  // 뒤로가기 버튼
        Button {
            self.presentationMode.wrappedValue.dismiss()
        } label: {
            HStack {
                Image(systemName: "chevron.left") // 화살표 Image
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.white)
            }
        }
    }
    var postList: some View {
        List {
            ForEach(postModel.getMyPosts()) { post in
                Post(alertType: $alertType, reportPostId: $reportPostId, post: post, myStory: true)
                    .environmentObject(locationModel)
            }
        }
        .listStyle(.plain)
    }
    var body: some View {
        VStack {
            HStack(spacing: 20) {
                ProfileStatsView(stat: numberOfPosts, statTitle: "왔다감")
                ProfileStatsView(stat: numberOfLikes, statTitle: "좋아요")
            }
            .padding(.vertical, 30)
            Divider()
//            HStack { // 향후 이미지를 버튼으로 변경 예정
//                Spacer() // 이미지를 중앙으로 밀기 위해 추가
//                Image(systemName: "signpost.right")
//                Spacer() // Divider와 다른 이미지 사이에 공간을 만들기 위해 추가
//                Divider()
//                    .frame(height: 40) // Divider의 높이를 설정
//                Spacer() // 다른 이미지와 Divider 사이에 공간을 만들기 위해 추가
//                Image(systemName: "heart")
//                Spacer() // 이미지를 중앙으로 밀기 위해 추가
//            }
//            .frame(height: 30) // HStack의 높이를 설정
//            Divider()
            postList
            Spacer()
        }
    }
}

struct ProfileStatsView: View {
    var stat: Int // @Binding을 제거했습니다.
    var statTitle: String // @Binding을 제거했습니다.
    var body: some View {
        VStack {
            Text("\(stat)")
                .bold()
                .font(.system(size: 24))
            Text(statTitle)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    @State static var alertType: AlertType?
    @State static var reportPostId: Int = 0
    static var previews: some View {
        let tokenModel = TokenModel()
        let authModel = AuthModel(tokenModel: tokenModel)
        let postModel = PostModel()
        let locationModel = LocationModel(tokenModel: tokenModel, authModel: authModel, postModel: postModel)
        ProfileView(alertType: $alertType, reportPostId: $reportPostId, nickname: "test", numberOfPosts: 10, numberOfLikes: 10)
            .environmentObject(postModel)
            .environmentObject(locationModel)
    }
}
