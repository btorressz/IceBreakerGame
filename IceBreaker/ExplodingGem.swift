//
//  ExplodingGem.swift
//  IceBreaker
//
//  Created by Brandon Torres on 9/30/19.
//  Copyright © 2019 Funcade  LLC. All rights reserved.
//

import Foundation

enum ExplosionCause {
    case Normal
    case SuperGemLine(index: GemIndex)
    case SuperGemBomb(index: GemIndex)
    case SuperGemColor(index: GemIndex)
}

// Specialized struct, it's identity depends only on it's position
struct ExplodingGem: Hashable {
    let index: GemIndex
    let type: GemType
    let cause: ExplosionCause
    var processed: Bool
    
    init(index: GemIndex, type: GemType, cause: ExplosionCause, processed: Bool) {
        self.index = index
        self.type = type
        self.cause = cause
        self.processed = processed
    }
    
    init(index: GemIndex, type: GemType, cause: ExplosionCause) {
        self.init(index: index, type:type, cause: cause, processed: false)
    }
    
    // MARK: Hashable
    var hashValue: Int {
        return index.hashValue
    }
}

// MARK: Equatable
func ==(lhs: ExplodingGem, rhs: ExplodingGem) -> Bool {
    return lhs.index == rhs.index
}
