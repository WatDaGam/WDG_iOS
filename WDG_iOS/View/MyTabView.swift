//
//  MyTabView.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 11/10/23.
//

import SwiftUI

struct MyTabView: View {
    @Binding var selectedTab: Int
    @Binding var scrollProxy: ScrollViewProxy?
    var namespace: Namespace.ID
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                if self.selectedTab == 0 { scrollToTop() }
                self.selectedTab = 0
            }, label: {
                Image(systemName: "list.bullet")
                    .resizable()
                    .frame(width: 30, height: 30)
            })
            Spacer()
            Spacer()
            Button(action: {
                self.selectedTab = 1
            }, label: {
                Image(systemName: "square.and.pencil")
                    .resizable()
                    .frame(width: 30, height: 30)
            })
            Spacer()
            Spacer()
            Button(action: {
                self.selectedTab = 2
            }, label: {
                Image(systemName: "person")
                    .resizable()
                    .frame(width: 30, height: 30)
            })
            Spacer()
        }
        .padding(.horizontal)
        .frame(height: 80)
        .foregroundColor(.black)
        .background(.white)
        .colorScheme(.light)
    }
    func scrollToTop() {
        withAnimation {
            scrollProxy?.scrollTo(namespace)
        }
    }
}

struct MyTabViewPreviews: PreviewProvider {
    @State static var selectedTab: Int = 0
    @State static var scrollProxy: ScrollViewProxy?
    @Namespace static var mainListTop
    static var previews: some View {
        MyTabView(
            selectedTab: $selectedTab,
            scrollProxy: $scrollProxy,
            namespace: mainListTop
        )
    }
}
