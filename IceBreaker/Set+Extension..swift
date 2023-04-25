//
//  Set+Extension..swift
//  IceBreaker
//
//  Created by Brandon Torres on 9/30/19.
//  Copyright © 2019 Funcade  LLC. All rights reserved.
//

import Foundation
import UIKit

extension Set {

    mutating func nonUpdatingInsert(member: Element) {
        if !self.contains(member) {
            self.insert(member)
        }
    }
    
    mutating func nonUpdatingUnionInPlace<S : SequenceType>(sequence: S) where S.Generator.Element == Element {
        for item in sequence {
            if !self.contains(item) {
                self.insert(item)
            }
        }
    }
}
