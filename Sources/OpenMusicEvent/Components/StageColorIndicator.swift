//
//  StagesIndicatorView.swift
//  open-music-event
//
//  Created by Woodrow Melling on 5/14/25.
//

import SwiftUI
import CoreModels

public extension Stage {
    struct IndicatorView: View {
        public init(colors: [Color]) {
            self.colors = colors
        }

        public init(color: Color) {
            self.init(colors: [color])
        }

        var angleHeight: CGFloat = 5 / 2

        var colors: [Color]

        public var body: some View {
            Canvas { context, size in
                let segmentHeight = size.height / CGFloat(colors.count)
                for (index, color) in colors.enumerated() {
                    let index = CGFloat(index)

                    context.fill(
                        Path { path in
                            let topLeft = CGPoint(
                                x: 0,
                                y: index * segmentHeight - angleHeight
                            )

                            let topRight = CGPoint(
                                x: size.width,
                                y: index > 0 ?
                                    index * segmentHeight + angleHeight :
                                    index * segmentHeight
                            )

                            let bottomLeft = CGPoint(
                                x: 0,
                                y: index == colors.indices.last.flatMap { CGFloat($0) } ?
                                    index * segmentHeight + segmentHeight :
                                    index * segmentHeight + segmentHeight - angleHeight
                            )

                            let bottomRight = CGPoint(
                                x: size.width,
                                y: index * segmentHeight + segmentHeight + angleHeight
                            )

                            path.move(to: topLeft)
                            path.addLine(to: topRight)
                            path.addLine(to: bottomRight)
                            path.addLine(to: bottomLeft)
                        },
                        with: .color(color)
                    )
                }
            }
        }
    }

}
