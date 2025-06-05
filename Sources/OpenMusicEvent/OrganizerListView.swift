//
//  OrganizerListView.swift
//  open-music-event
//
//  Created by Woodrow Melling on 6/3/25.
//


//
//  OrganizerListView.swift
//  open-music-event
//
//  Created by Woodrow Melling on 5/7/25.
//

import SkipFuse
import SkipFuseUI
import OMECoreModels
import Dependencies
//import ImageCaching


struct OrganizerListView: View {

    @Observable
    class ViewModel {
        public init() {}
//
//        @ObservationIgnored
//        @FetchAll(Organizer.all.order(by: \.name))
        var organizers: [Organizer] = []

        func didTapAddOrganizerButton() {
            unimplemented()
        }
    }

    @State var store = ViewModel()

    public var body: some View {
        List(store.organizers, id: \.url) { org in
            NavigationLink {
                Row(org: org)
            } label: {
                Text("Organizer Detail")
            }
        }
        .listStyle(.plain)
        .navigationTitle("Organizers")
        .toolbar {
            Button("Add Organizer", systemImage: "plus") {
                store.didTapAddOrganizerButton()
            }
        }
    }

    struct Row: View {
        var org: Organizer

        var body: some View {
            HStack {
//                Organizer.ImageView(organizer: org)
//                    .frame(width: 60, height: 60)
//                    .aspectRatio(contentMode: .fit)
//
                    Text(org.name)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
