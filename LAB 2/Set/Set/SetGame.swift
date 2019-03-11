//
//  SetGame.swift
//  Set
//
//  Created by Jessica Lam on 2/22/19.
//  Copyright © 2019 Jessica Lam. All rights reserved.
//

import Foundation

struct Game {
    var scoreCount = 0
    
    struct Constants {
        static let numberOfCards = 12
        static let set = 3
        static let notSet = 4
        static let deselect = 1
    }
    
    var currentCards = [Card]()
    var selectedCards = [Card]()
    var removedCards = [Card]()
    var attemptingToMatchCards = [Card]()
    
    lazy var deck = CardDeck()
    
    var isSet: Bool? {
        get {
            guard attemptingToMatchCards.count == 3 else { return nil }
            return Card.isSet(cards: attemptingToMatchCards)
        }
        set {
            if newValue != nil {
                if newValue! {
                    scoreCount += Constants.set
                } else {
                    scoreCount -= Constants.notSet
                }
                attemptingToMatchCards = selectedCards
                selectedCards.removeAll()
            } else {
                attemptingToMatchCards.removeAll()
            }
        }
    }
    
    
    var cardSetsThatMakeSet:[[Int]] {
        var setsThatMakeSet = [[Int]]()
        if currentCards.count > 2 {
            for i in 0..<currentCards.count {
                for j in (i+1)..<currentCards.count {
                    for k in (j+1)..<currentCards.count {
                        let cardsToCheck = [currentCards[i], currentCards[j], currentCards[k]]
                        if Card.isSet(cards: cardsToCheck) {
                            setsThatMakeSet.append([i, j, k])
                        }
                    }
                }
            }
        }
        if let gameIsSet = isSet, gameIsSet {
            let matchIndices = currentCards.indices(of: attemptingToMatchCards)
            return setsThatMakeSet.map{ Set($0)}
                .filter{$0.intersection(Set(matchIndices)).isEmpty}
                .map{Array($0)}
        }
        return setsThatMakeSet
    }
    
    
    init() {
        assert(Constants.numberOfCards > 0, "You must have at least one card")
        for _ in 1...Constants.numberOfCards {
            if let card = deck.draw() {
                currentCards += [card]
            }
        }
        
    }
    
    mutating func chooseCard(at index: Int) {
        assert(currentCards.indices.contains(index), "Game.chooseCard(at: \(index)): chosen index not in the cards")
        let chosenCard = currentCards[index]
        
        if isSet != nil {
            if isSet! {Remove3Cards()}
            isSet = nil
        }
        
        if !removedCards.contains(chosenCard) && !attemptingToMatchCards.contains(chosenCard) {
            if selectedCards.count == 2, !selectedCards.contains(chosenCard) {
                selectedCards += [chosenCard]
                isSet = Card.isSet(cards: selectedCards)
            } else {
                assert(!removedCards.contains(chosenCard))
                selectedCards.toggle(element: chosenCard)
                if selectedCards.count == 0 {
                    scoreCount -= Constants.deselect
                }
            }
        }
    }
    
    mutating func deal() {
        if let deal3Cards =  take3FromDeck() {
            currentCards += deal3Cards
        }
    }
    
    mutating func Remove3Cards() {
        currentCards.remove(elements: attemptingToMatchCards)
        removedCards += attemptingToMatchCards
        attemptingToMatchCards.removeAll()
    }
    
    private mutating func take3FromDeck() -> [Card]? {
        var threeCards = [Card]()
        for _ in 0...2 {
            if let card = deck.draw() {
                threeCards += [card]
            } else {
                return nil
            }
        }
        return threeCards
    }
    
}

extension Array where Element : Equatable {
    
    mutating func toggle(element: Element){
        if let from = self.index(of:element)  {
            self.remove(at: from)
        } else {
            self.append(element)
        }
    }
    
    mutating func remove(elements: [Element]) {
        self = self.filter { !elements.contains($0) }
    }
    
    func indices(of elements: [Element]) ->[Int]{
        guard self.count >= elements.count, elements.count > 0 else {return []}
        return elements.map{self.index(of: $0)}.compactMap{$0}
    }
    
}
