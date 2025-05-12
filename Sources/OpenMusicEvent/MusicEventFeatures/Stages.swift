//
//  StagesLegend.swift
//  open-music-event
//
//  Created by Woodrow Melling on 5/9/25.
//

import SwiftUI
import SharingGRDB
import ImageCaching

struct StagesLegend: View {
    @FetchAll(Current.stages.select{ $0.id } )
    var stages: [Stage.ID]

    var body: some View {
        HStack {
            ForEach(stages, id: \.self) {
                StageIconView(stageID: $0)
                    .frame(square: 50)
            }
        }
    }
}


#Preview() {
    try! prepareDependencies {
        $0.musicEventID = 0
        $0.defaultDatabase = try appDatabase()
    }
    return StagesLegend()
}


extension Stage {
    static var placeholder: Stage {
        Stage.init(
            id: -1,
            musicEventID: nil,
            name: "",
            iconImageURL: nil,
            color: .clear
        )
    }
}
public struct StageIconView: View {
    public init(stageID: Stage.ID) {
        _stage = FetchOne(wrappedValue: .placeholder, Stage.find(stageID))
    }

    @FetchOne
    var stage: Stage

    var stageColor: Color {
        .accentColor
    }

    @Environment(\.colorScheme) var colorScheme

    public var body: some View {
        CachedAsyncIcon(
            url: stage.iconImageURL,
            placeholder: {
                DefaultStageIcon(stage: stage)
        })
        .foregroundStyle(colorScheme == .light ? stageColor : .white)
    }
}

struct DefaultStageIcon: View {
    var stage: Stage

    var symbol: String {
        stage.name
            .split(separator: " ")
            .filter { !$0.contains("The") }
            .compactMap { $0.first.map(String.init) }
            .joined()
    }

    var body: some View {
        ZStack {
            Text(symbol)
                .font(.system(size: 300, weight: .heavy))
                .minimumScaleFactor(0.001)
                .padding()
        }
    }
}


public struct CachedAsyncIcon<Content: View>: View {
    public init(
        url: URL?,
        contentMode: SwiftUI.ContentMode = .fill,
        @ViewBuilder placeholder: @escaping () -> Content
    ) {
        self.url = url
        self.contentMode = contentMode
        self.placeholder = placeholder
    }


    var url: URL?
    var contentMode: SwiftUI.ContentMode
    @ViewBuilder var placeholder: () -> Content

    @State var hasTransparency = true

    public var body: some View {
        CachedAsyncImage(url: url) {
            $0.resizable()
                .renderingMode(hasTransparency ? .template : .original)
                .aspectRatio(contentMode: .fit)
                .frame(alignment: .center)

        } placeholder: {
            placeholder()
        }
    }
}

extension URLCache {

    static let iconCache = URLCache(memoryCapacity: 512_000_000, diskCapacity: 10_000_000_000)
}

