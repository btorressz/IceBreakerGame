//
//  GemIndex.swift
//  IceBreaker
//
//  Created by Brandon Torres on 9/30/19.
//  Copyright © 2019 Funcade  LLC. All rights reserved.
//

import Foundation

struct GemIndex:Hashable {
    
    let x:Int
    let y:Int
    func encode(with coder: NSCoder) {}
    //MARK: Hashable
    var hashValue:Int {
        return x + 100 + y
    }
    // MARK: Equatable
    static func ==(lhs: GemIndex, rhs: GemIndex) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}
