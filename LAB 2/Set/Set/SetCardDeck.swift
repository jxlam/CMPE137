//
//  SetCardDeck.swift
//  Set
//
//  Created by Jessica Lam on 2/22/19.
//  Copyright © 2019 Jessica Lam. All rights reserved.
//

import Foundation

struct CardDeck {
    
    var cards = [Card]()
    
    init() {
        for color in Card.Option.all {
            for shape in Card.Option.all {
                for shade in Card.Option.all {
                    for number in Card.Option.all {
                        cards.append(Card(color: color, shape: shape, shade: shade, number: number))
                    }
                }
            }
        }
    }
    
    mutating func draw() -> Card? {
        if cards.count > 0 {
            return cards.remove(at: cards.count.arc4random)
        } else {
            return nil
        }
    }
    
}

extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}
