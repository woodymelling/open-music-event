import SwiftUI
import SharingGRDB


struct MoreView: View {


    var body: some View {
        List {
            Button("See other Wicked Wood events") {
                @Shared(Current.musicEventID)
                var musicEventID

                $musicEventID.withLock { $0 = nil }
            }
        }
    }

}
