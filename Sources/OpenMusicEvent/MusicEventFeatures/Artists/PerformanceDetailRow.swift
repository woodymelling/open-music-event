//
//  PerformanceRow.swift
//  open-music-event
//
//  Created by Woodrow Melling on 5/11/25.
//

import SwiftUI
import SharingGRDB


public struct PerformanceDetailRow: View {

    init(performance: ArtistDetailView.ViewModel.PerformanceDetail) {
        self.performance = performance

        _stageColorHex = FetchOne(
            wrappedValue: 0,
            Stage.find(performance.stageID).select { $0.color }
        )
    }

    var performance: ArtistDetailView.ViewModel.PerformanceDetail

    var timeIntervalLabel: String {
        (performance.startTime..<performance.endTime)
            .formatted(.performanceTime)
    }

    @FetchOne
    var stageColorHex: Int

    var color: Color? {
        Color(hex: UInt(stageColorHex))
    }

    public var body: some View {
        HStack(spacing: 10) {
            StagesIndicatorView(stageIDs: [performance.stageID])
                .frame(width: 5)

            StageIconView(stageID: performance.stageID)
                .frame(square: 60)

            if let title = self.performance.customTitle {
                VStack(alignment: .leading) {
                    Text(title)

                    Text(timeIntervalLabel + " " + performance.startTime.formatted(.daySegment))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {

                VStack(alignment: .leading) {
                    Text(timeIntervalLabel)

                    Text(performance.startTime, format: .daySegment)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 5)
        .frame(height: 60)
    }
}


public struct StagesIndicatorView: View {
    public init(stageID: Stage.ID) {
        self.init(stageIDs: [stageID])
    }

    public init(stageIDs: [Stage.ID]) {
        _colorHexes = FetchAll(
            Stage.all
            .where { $0.id.in(stageIDs) }
            .select { $0.color }
        )
    }

    var angleHeight: CGFloat = 5 / 2


    @FetchAll
    var colorHexes: [Int]

    var colors: [Color] {
        colorHexes.map { Color(hex: UInt($0)) }
    }

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
//
//#if os(iOS)
//
//public class StageIndicatorUIView: UIView {
//    var stages: [Stage] = []
//
//    let angleHeight: CGFloat = 2.0
//
//    public override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        clearsContextBeforeDrawing = true
//        backgroundColor = .clear
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    public func setStages(stages: [Stage]) {
//        self.stages = stages
//        self.setNeedsDisplay()
//    }
//
//    func setStage(stage: Stage) {
//        self.setStages(stages: [stage])
//    }
//
//    public override func draw(_ rect: CGRect) {
//
//        for (i, stage) in stages.enumerated() {
//            let width = rect.width
//            let height = rect.height / CGFloat(stages.count)
//            let startY = height * CGFloat(i)
//            let endY = height * CGFloat(i + 1)
//
//            let path = UIBezierPath()
//
//            // Draw top "horizontal" line
//            if i == 0 {
//                path.move(to: CGPoint(x: 0, y: 0))
//                path.addLine(to: CGPoint(x: width, y: 0))
//            } else {
//                path.move(to: CGPoint(x: 0, y: startY - angleHeight))
//                path.addLine(to: CGPoint(x: width, y: startY + angleHeight))
//            }
//
//            // Draw bottom
//            if i == stages.count - 1 {
//                path.addLine(to: CGPoint(x: width, y: rect.height))
//                path.addLine(to: CGPoint(x: 0, y: rect.height))
//            } else {
//                path.addLine(to: CGPoint(x: width, y: endY + angleHeight))
//                path.addLine(to: CGPoint(x: 0, y: endY - angleHeight))
//            }
//
//            path.close()
//
//            let color = UIColor(stage.color)
//            color.set()
//
//            path.fill()
//        }
//    }
//
//}
//#endif

//struct StagesIndicatorView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            StagesIndicatorView(stageIDs: Event.testival.stages.map(\.id))
//            StagesIndicatorView(stageIDs: [Event.testival.stages.first!.id])
//        }
//        .environment(\.eventColorScheme, Event.testival.colorScheme!)
//        .frame(width: 5, height: 60)
//        .previewLayout(.sizeThatFits)
//
//
//    }
//}
