//
//  Schedule.swift
//  OpenFestival
//
//  Created by Woodrow Melling on 1/11/25.
//

import Foundation
import OrderedCollections

extension Set {
    func sorted(by key: (Element) -> some Comparable) -> OrderedSet<Element> {
        OrderedSet(self.sorted(by: { key($0) < key($1) }))
    }
}



