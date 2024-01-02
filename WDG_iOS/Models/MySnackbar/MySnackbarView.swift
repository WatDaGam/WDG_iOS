//
//  MySnackbarView.swift
//  WDG_iOS
//
//  Created by Yong Min Back on 1/2/24.
//

import SwiftUI

struct SnackBarView: View {
    
    let item : SnackBarItem
    
    public var body: some View {
        HStack{
            HStack {
                Text(item.message)
                    .foregroundColor(SnackbarOption.shared.textColor)
                    .font(.system(size: SnackbarOption.shared.textSize))
                Spacer()
                if(item.actionLabel != nil) {
                    Button(item.actionLabel!) {
                        item.action?.onPerformAction()
                    }
                    .foregroundColor(SnackbarOption.shared.labelColor)
                    .font(.system(size: SnackbarOption.shared.labelSize))
                }
            }.padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        }
        .frame(minHeight: 48)
        .background(SnackbarOption.shared.bgColor)
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .offset(y: -70)
    }
}

struct SnackBarView_Preview: PreviewProvider {
    static var previews: some View {
        SnackBarView(
            item: SnackBarItem(
                message: "very very very very very very very very very very very very long text",
                actionLabel: "label",
                duration: SnackbarDuration.Short,
                action: nil
            )
            )
        .environmentObject(SnackbarController())
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
}

