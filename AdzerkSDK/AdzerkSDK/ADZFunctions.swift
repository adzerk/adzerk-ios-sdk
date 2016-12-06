//
//  ADZFunctions.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 8/14/15.
//  Copyright (c) 2015 Adzerk. All rights reserved.
//

import Foundation

// return a new array with optionals removed, change type to !
func compact<T>(_ source: [T?]) -> [T] {
    return source.filter { $0 != nil }.map { $0! }
}

func groupBy<T, K: Hashable>(_ source: [T], keyMethod: (T) -> K) -> [K: T] {
    var dict = [K: T]()
    for item in source {
        let key = keyMethod(item)
        if dict[key] != nil {
            print("Warning: duplicate value for key \(key)")
        }
        dict[key] = item
    }
    return dict
}
