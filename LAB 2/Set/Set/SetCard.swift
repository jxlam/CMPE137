//
//  SetCard.swift
//  Set
//
//  Created by Jessica Lam on 2/22/19.
//  Copyright © 2019 Jessica Lam. All rights reserved.
//

import Foundation

struct Card: Equatable, CustomStringConvertible {
    
    let color: Option
    let shape: Option
    let shade: Option
    let number: Option
    
    var description: String {
        return "\(number)-\(color)-\(shape)-\(shade)"
        
    }
    
    static func ==(fSide: Card, sSide: Card) -> Bool {
        return fSide.description == sSide.description
    }
    
    enum Option: Int, CustomStringConvertible {
        case first = 1
        case second
        case third
        
        static var all: [Option] {
            return [.first, .second, .third]
            
        }
        var description: String {
            return String(self.rawValue)
            
        }
        var idx: Int {
            return (self.rawValue - 1)
            
        }
    }
    
    static func isSet(cards: [Card]) -> Bool {
        guard cards.count == 3 else {
            return false
            
        }
        let sum = [
            cards.reduce(0, { $0 + $1.number.rawValue }),
            cards.reduce(0, { $0 + $1.shade.rawValue }),
            cards.reduce(0, { $0 + $1.color.rawValue }),
            cards.reduce(0, { $0 + $1.shape.rawValue })
        ]
        return (sum.reduce(true, { $0 && ($1 % 3  == 0) } ))
    }
    
}
