//
//  File.swift
//  
//
//  Created by Woodrow Melling on 7/3/24.
//

import Foundation
import Sharing

extension SharedKey where Self == InMemoryKey<Performance.ID?> {
    static var highlightedPerformance: Self {
        .inMemory("highlightingPerformance")
    }
}
