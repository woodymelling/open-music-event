//
//  NavigationBarExtensionViewModifier.swift
//  OpenFestival
//
//  Created by Woodrow Melling on 1/5/25.
//

import SwiftUI

extension View {
    func navigationBarExtension<ExtensionContent: View>(
        dragsWithScroll: Bool = false,
        @ViewBuilder extensionContent: () -> ExtensionContent
    ) -> some View {
        self.modifier(
            NavigationBarExtensionViewModifier(
                dragsWithScroll: dragsWithScroll,
                extensionContent: extensionContent
            )
        )
    }
}

struct NavigationBarExtensionViewModifier<ExtensionContent: View>: ViewModifier {
    init(dragsWithScroll: Bool, @ViewBuilder extensionContent: () -> ExtensionContent) {
        self.dragsWithScroll = dragsWithScroll
        self.extensionContent = extensionContent()
    }

    var extensionContent: ExtensionContent
    var dragsWithScroll: Bool = false

    @State var yPosition: CGFloat = 0

    func body(content: Content) -> some View {
        content.safeAreaInset(edge: .top) {
            extensionContent
                .frame(maxWidth: .infinity)
                .background(Material.bar.opacity(min(1, max(0, yPosition))))
                .offset(dragsWithScroll ? CGSize(width: 0, height: max(0, -yPosition)) : .zero)
        }
        .onScrollGeometryChange(
            for: CGFloat.self,
            of: { geo in
                let trueOffset = geo.contentOffset.y + geo.contentInsets.top
                return if dragsWithScroll {
                    min(1, trueOffset)
                } else {
                    min(1, max(0, trueOffset))
                }
            },
            action: { oldValue, newValue in
                yPosition = newValue
            }
        )
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}
