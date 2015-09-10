//
//  ADZFunctions.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 8/14/15.
//  Copyright (c) 2015 Adzerk. All rights reserved.
//

import Foundation


// return a new array with optionals removed, change type to !
func compact<T>(source: [T?]) -> [T] {
    return source.filter { $0 != nil }.map { $0! }
}

// Swift 1.2's flatMap doesn't work with optionals. Can remove when on Swift 2 and replace with plain flatMap :)
// filterMap removes optionals, then applies the transform
func filterMap<T, U>(source: [T?], transform: T -> U ) -> [U] {
    return compact(source).map(transform)
}

func groupBy<T, K: Hashable>(source: [T], keyMethod: T -> K) -> [K: T] {
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