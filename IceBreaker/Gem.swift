//
//  Gem.swift
//  IceBreaker
//
//  Created by Brandon Torres on 9/30/19.
//  Copyright © 2019 Funcade  LLC. All rights reserved.
//

import Foundation

func <<T: RawRepresentable>(a: T, b: T) -> Bool where T.RawValue: Comparable {
    return a.rawValue < b.rawValue
}

enum GemType: Int, Comparable {
    case None = 0
    case Gem1
    case Gem2
    case Gem3
    case Gem4
    case Gem5
    case SuperGemLine
    case SuperGemBomb
    case SuperGemColor
}

// At the moment this is just a wrapper around the GemType enum to be able to serialize it easily
class Gem: NSObject, NSCoding {
    func encode(with coder: NSCoder) {
    }
    
    var type: GemType
    
    struct PropertyKey {
        static let typeKey = "type"
    }
    
    init(type: GemType) {
        self.type = type
    }
    
    required init(coder aDecoder: NSCoder) {
        type = GemType(rawValue: aDecoder.decodeInteger(forKey: PropertyKey.typeKey))!
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encode(type.rawValue, forKey: PropertyKey.typeKey)
    }
    
    override var description: String {
        return String(type.rawValue)
    }
    
    // MARK: Hashable
    override var hash: Int {
        return type.hashValue
    }
}

// MARK: Equatable
func ==(lhs: Gem, rhs: Gem) -> Bool {
    return lhs.type == rhs.type
}
