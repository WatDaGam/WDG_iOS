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
                Image(systemName: selectedTab == 0 ? "list.bullet.circle.fill" : "list.bullet")
                    .resizable()
                    .frame(width: selectedTab == 0 ? 25 : 20, height: selectedTab == 0 ? 25 : 20)
            })
            Spacer()
            Spacer()
            Button(action: {
                self.selectedTab = 1
            }, label: {
                Image(systemName: "square.and.pencil")
                    .resizable()
                    .frame(width: 25, height: 25)
            })
            Spacer()
            Spacer()
            Button(action: {
                self.selectedTab = 2
            }, label: {
                Image(systemName: selectedTab == 2 ? "person.fill" : "person")
                    .resizable()
                    .frame(width: 25, height: 25)
            })
            Spacer()
        }
        .padding(.horizontal)
        .frame(height: 70)
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
