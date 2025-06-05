//
//  OME.swift
//  open-music-event
//
//  Created by Woodrow Melling on 6/3/25.
//

//import Sharing
import SkipFuse
import SkipFuseUI
import Dependencies
import OMECoreModels
//import Sharing
//import SharingGRDB
//import ImageCaching
//import OMECoreModels
import IssueReporting

public enum OME {
    public static func prepareDependencies() {
        #if os(Android)
        IssueReporters.current.append(AndroidIssueReporter())
        #endif

        withErrorReporting("Preparing Database") {
            try Dependencies.prepareDependencies {
                $0.defaultDatabase = try appDatabase()
            }
        }
    }

    public struct AppEntryPoint: View {
//        @ObservationIgnored
//        @Shared(.eventID) var eventID

        @Observable
        class AppModel {

        }

        public var body: some View {
//            if let eventID {
//                MusicEventViewer(id: eventID)
//                    .environment(\.exitEvent) {
//                        $eventID.withLock { $0 = nil }
//                    }
//            } else {
                NavigationStack {
                     OrganizerListView()
                }
//            }
        }
    }

//    public struct WhiteLabeledEntryPoint: View {
//        public init(url: Organizer.ID) {
//            self.url = url
//        }
//
//        @ObservationIgnored
//        @Shared(.eventID) var eventID
//
//        var url: Organizer.ID
//
//        public var body: some View {
//            Group {
//                if eventID == nil {
//                    OrganizerDetailView(url: self.url)
//                }
//
//                if let eventID {
//                    MusicEventViewer(id: eventID)
//                        .environment(\.exitEvent) {
//                            $eventID.withLock { $0 = nil }
//                        }
//                }
//            }
//            .animation(.default, value: eventID)
//        }
//    }

}


extension OME {
    static let subsystem = "bundle.ome.open-music-event"
}
//extension EnvironmentValues {
//    @Entry var exitEvent: () -> Void = { unimplemented() }
//}

#if os(iOS)
#Preview {
    let _ = try! prepareDependencies {
      $0.defaultDatabase = try appDatabase()
    }

    OME.AppEntryPoint()
}
#endif

#if os(Android)
struct AndroidIssueReporter: IssueReporter {
    let logger = Logger(subsystem: OME.subsystem, category: "Issues")

    func reportIssue(
        _ message: @autoclosure () -> String?,
        fileID: StaticString,
        filePath: StaticString,
        line: UInt,
        column: UInt
    ) {
        let message = message()
        logger.warning("""
        Issue: \(message ?? "no message")
        FileID: \(fileID)
        FilePath: \(filePath)
        Line: \(line), Column: \(column)
        """)
    }

    func reportIssue(
        _ error: any Error,
        _ message: @autoclosure () -> String?,
        fileID: StaticString,
        filePath: StaticString,
        line: UInt,
        column: UInt
    ) {
        let message = message()
        logger.error("""
        Error: \(error.localizedDescription)
        Issue: \(message ?? "no message")
       """)
//                FileID: \(fileID)
//        FilePath: \(filePath)
//        Line: \(line), Column: \(column)
// 
    }
}
#endif
