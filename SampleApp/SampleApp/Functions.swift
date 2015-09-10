//
//  Functions.swift
//  SampleApp
//
//  Created by Ben Scheirman on 8/20/15.
//  Copyright (c) 2015 Adzerk. All rights reserved.
//

import Foundation


extension Array {
    // borrowed from haskell, group array into subgroups of n elements
    func splitEvery(n: Int) -> [[Element]] {
        var result = [[Element]]()
        
        var group = [Element]()
        var counter = 0
        for item in self {
            group.append(item)
            if counter++ > n {
                counter = 0
                result.append(group)
                group = []
            }
        }

        return result
    }
}

// Interleave B into A every N elements
func interleave<A, B>(a: [A], _ b: [B], every n: Int) -> [Any] {
    var result = [Any]()
    var bSequence = b.generate()
    let chunkedAs = a.splitEvery(n)
    for group in chunkedAs {
        for item in group {
            result.append(item)
        }
        
        if let inter = bSequence.next() {
            result.append(inter)
        }
    }
    
    return result
}