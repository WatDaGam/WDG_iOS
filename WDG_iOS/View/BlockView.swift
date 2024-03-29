//
//  BlockView.swift
//  WDG_iOS
//
//  Created by Yong Min Back on 1/3/24.
//

import SwiftUI

struct BlockView: View {
    @EnvironmentObject var authModel: AuthModel
    @EnvironmentObject var locationModel: LocationModel
    @EnvironmentObject var postModel: PostModel
    @Binding var alertType: AlertType?
    @Binding var removeBlockId: Int
    var blockList: [BlockInfo]
    var body: some View {
        VStack {
            if blockList.isEmpty {
                Spacer()
                Text("차단한 사용자가 없습니다.")
                    .foregroundColor(.gray)
                Spacer()
            } else {
                List {
                    ForEach(blockList) { user in
                        HStack {
                            Text(user.writerName)
                            Spacer()
                            Button(action: {
                                alertType = .isUnBlock
                                removeBlockId = user.id
                            }, label: {
                                Text("해제")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .cornerRadius(20)
                                    .background(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.gray, lineWidth: 1)
                                    )
                            })
                        }
                    }
                }
                .listStyle(.plain)
            }
            Spacer()
        }
    }
}
