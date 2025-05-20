//
//  EntityImageViews.swift
//  open-music-event
//
//  Created by Woodrow Melling on 5/19/25.
//

//
//  OrganizationDetails.swift
//  event-viewer
//
//  Created by Woodrow Melling on 3/25/25.
//

import Foundation
import Observation
import SwiftUI
import Dependencies
import OSLog
import ImageCaching
import SharingGRDB


extension Organization {
    struct ImageView: View {
        let organization: Organization

        var body: some View {
            CachedAsyncImage(
                requests: [
                    ImageRequest(
                        url: organization.imageURL,
                        processors: [.resize(width: 440)]
                    ).withPipeline(.images)
                ]
            ) {
                $0.resizable().renderingMode(.template)
            } placeholder: {
                #if !SKIP
                AnimatedMeshView()
                    .overlay(Material.thinMaterial)
                    .opacity(0.25)
                #else
                ProgressView().frame(square: 440)
                #endif

            }
            .frame(maxWidth: .infinity)
        }
    }
}

extension MusicEvent {
    struct ImageView: View {
        var event: MusicEvent

        var body: some View {
            CachedAsyncImage(
                requests: [
                    ImageRequest(
                        url: event.imageURL,
                        processors: [
                            .resize(size: CGSize(width: 60, height: 60))
                        ]
                    )
                    .withPipeline(.images)
                ]
            ) {
                $0
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 60, height: 60)
            .clipped()
        }
    }
}


extension Artist {
    struct ImageView: View {
        @FetchOne
        var imageURL: URL?

        init(imageURL: URL? = nil) {
            self._imageURL = FetchOne(wrappedValue: imageURL)
        }

        init(artistID: Artist.ID) {
            self._imageURL = FetchOne(wrappedValue: nil, Artist.find(artistID).select { $0.imageURL })
        }

        var body: some View {
            GeometryReader { geo in
                CachedAsyncImage(
                    requests: [
                        ImageRequest(
                            url: imageURL,
                            processors: [
                                .resize(size: geo.size)
                            ]
                        )
                        .withPipeline(.images)
                    ]
                ) {
                    $0.resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "person.fill")
                        .resizable()
                        .frame(square: 30)
                }
            }
            .clipped()
        }
    }
}
