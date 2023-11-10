import SwiftUI

struct NavbarView<Left: View, Center: View, Right: View>: View {
    var left: Left?
    var center: Center?
    var right: Right?

    init(@ViewBuilder left: () -> Left? = { nil },
         @ViewBuilder center: () -> Center? = { nil },
         @ViewBuilder right: () -> Right? = { nil }) {
        self.left = left()
        self.center = center()
        self.right = right()
    }
    var body: some View {
        HStack {
            if let leftView = left {
                leftView
            }
            Spacer()
            if let centerView = center {
                centerView
            }
            Spacer()
            if let rightView = right {
                rightView
            }
        }
        .padding(.horizontal)
        .frame(height: 80)
        .background(Rectangle().foregroundColor(.black))
    }
}

struct NavbarViewPreviews: PreviewProvider {
    static var previews: some View {
        NavbarView(
            left: { WDGLogoView(size: 24, spacing: -4, mode: true) },
            center: { EmptyView() },
            right: { Text("Right") }
        )
    }
}
