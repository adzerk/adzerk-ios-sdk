//
//  VikingGenerator.swift
//  SampleApp
//
//  Created by Ben Scheirman on 8/18/15.
//  Copyright (c) 2015 Adzerk. All rights reserved.
//

import Foundation

struct Viking {
    let name: String
    let quote: String
    let imageUrl: URL
}

// Taken from the Android sample app.
class VikingGenerator {
    static func generateVikings(_ count: Int) -> [Viking] {
        var vikings: [Viking] = []
        
        for _ in 0..<count {
            vikings.append(randomViking())
        }
        
        return vikings
    }
    
    static func randomViking() -> Viking {
        return Viking(name: randomName(), quote: randomQuote(), imageUrl: randomHeadshot())
    }
    
    static func randomName() -> String {
        let names = [
                "Hervor Ivar",
                "Marta Holta-Thorir",
                "Pernilla Sumarlida",
                "Hallkatla Soxol",
                "Hildigunnr Thrain",
                "Nina Gunnor",
                "Beate Hord",
                "Arnkatla Throst",
                "Anette Rennir",
                "Thorhildr Jorund",
                "Ingibjorg Eldiarn",
                "Dyrfinna Hroald",
                "Jarngeror Hastein",
                "Groa Armod",
                "Aegileif Orm",
                "Astra Askel",
                "Thurior Kolr",
                "Arnbjorg Thorbjorn",
                "Camilla Hedin",
                "Yrr Dag",
                "Eirny Ingimund",
                "Nina Sigmund",
                "Ketilrior Vandil",
                "Astrid Hafgrim",
                "Bera Herbjorn"
            ]
        return names[randomInt(names.count)]
    }
    
    static func randomQuote() -> String {
        let quotes = [
            "Always rise to an early meal, but eat your fill before a feast.",
            "Never walk away from home ahead of your axe and sword.",
            "No lamb for the lazy wolf.",
            "Repay laughter with laughter but betrayal with treachery.",
            "Words of praise will never perish nor a noble name.",
            "One should not ask more than would be thought fitting.",
            "I demolish my bridges behind me - then there is no choice but forward",
            "The difficult is what takes a little time; the impossible is what takes a little longer.",
            "There seldom is a single wave.",
            "A bad rower blames the oar.",
            "Only dead fish follow the stream.",
            "A fair wind at our back is best.",
            "One must howl with the wolves one is among.",
            "If you cannot bite, never show your teeth.",
            "His hands are clean who warns another.",
            "Many go to the goat-house to get wool.",
            "One man's tale is but half a tale.",
            "Be not a braggart for if any work done be praise-worthy, others will sing your praises for you."
        ]
        return quotes[randomInt(quotes.count)]
    }
    
    static func randomHeadshot() -> URL {
        let max = 88;
        let urlString = "http://api.randomuser.me/portraits/med/women/\(randomInt(max)).jpg"
        return URL(string: urlString)!
    }
    
    static func randomInt(_ max: Int) -> Int {
        return Int(arc4random_uniform(UInt32(max)))
    }
}
