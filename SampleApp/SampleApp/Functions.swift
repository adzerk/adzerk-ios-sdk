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
        for from in stride(from: 0, to: count, by: n) {
            let to = advance(from, n, count)
            let range = self[from..<to]
            result.append(Array(range))
        }
        return result
    }
}

// Interleave B into A every N elements
func interleave<A, B>(a: [A], b: [B], every n: Int) -> [Any] {
    var result = [Any]()
    var bSequence = b.generate()
    var chunkedAs = a.splitEvery(n)
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