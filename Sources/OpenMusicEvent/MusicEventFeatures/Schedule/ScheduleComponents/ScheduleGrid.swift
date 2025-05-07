//
//  File.swift
//  
//
//  Created by Woodrow Melling on 5/22/23.
//

import Foundation
import SwiftUI

public struct ScheduleGrid<Content: View>: View {
    public init(@ViewBuilder content: () -> Content = { EmptyView() }) {
        self.content = content()
    }

    var content: Content

    @State var width: CGFloat = 0
    
    public var body: some View {
        ZStack {
        
            HStack {
                ScheduleHourLabelsView()
                    .zIndex(0)
                    .offset(y: -7)


                ZStack {
                    ScheduleHourLines()
                        .zIndex(0)
                    
                    content
                        .zIndex(10)
                        .coordinateSpace(name: "Timeline")
                }
                
            }
            .onPreferenceChange(HourLabelsWidthPreferenceKey.self) { width = $0 }
            
            
//            TimeIndicatorView()
        }
        .ignoresSafeArea(edges: .trailing)

    }
}



extension View {
    func heightReader<T: PreferenceKey>(updating key: T.Type) -> some View where T.Value == CGFloat {
        self.background {
            
            GeometryReader { geometry in
                Color.clear
                    .preference(key: T.self, value: geometry.size.height)
            }
        }
    }
    
    func widthReader<T: PreferenceKey>(updating key: T.Type) -> some View where T.Value == CGFloat {
        self.background {
            
            GeometryReader { geometry in
                Color.clear
                    .preference(key: T.self, value: geometry.size.width)
            }
        }
    }
    
    func widthReader<T: PreferenceKey>(updating key: T.Type) -> some View where T.Value == CGSize {
        self.background {
            
            GeometryReader { geometry in
                Color.clear
                    .preference(key: T.self, value: geometry.size)
            }
        }
    }

}


#Preview {
    ScrollView {

        ScheduleGrid()
    }
}
