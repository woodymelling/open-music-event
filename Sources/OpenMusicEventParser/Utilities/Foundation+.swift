//
//  File.swift
//  
//
//  Created by Woodrow Melling on 6/3/24.
//

import Foundation

extension Collection {
    var hasElements: Bool {
        !self.isEmpty
    }
}

extension Optional where Wrapped: Collection {
    var isNilOrEmpty: Bool {
        switch self {
        case .none: true
        case .some(let wrapped): wrapped.isEmpty
        }
    }

    var hasElements: Bool {
        !isNilOrEmpty
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
