import Foundation

class Concentration {
    private(set) var cards = [Card]()
    private(set) var score = 0
    private var seen: Set<Int> = []
    private(set) var flipCount = 0
    private struct Points{
        static let match = 1
        static let mismatch = 1
    }
    
    private var indexOfOneAndOnlyFaceUpCard: Int? {
        get{
            var foundIndex:Int?
            for index in cards.indices {
                if cards[index].isFaceUp {
                    if foundIndex == nil{
                        foundIndex = index
                    } else{
                        return nil
                    }
                }
            }
            return foundIndex
        }
        
        set {
            for index in cards.indices{
                cards[index].isFaceUp = (index == newValue)
            }
        }
    }

    func chooseCard(at index: Int){
        assert(cards.indices.contains(index), "Concentration.chooseCard(at: \(index)): chosen index is not in cards")
        if !cards[index].isMatched{
            flipCount += 1
            if let matchIndex = indexOfOneAndOnlyFaceUpCard, matchIndex != index {
                if cards[matchIndex].identifier == cards [index].identifier{
                    cards[matchIndex].isMatched = true
                    cards[index].isMatched = true
                    score += Points.match
                }
                else{
                    if seen.contains(index){
                        score -= Points.mismatch
                    }
                    if seen.contains(matchIndex){
                        score -= Points.mismatch
                    }
                    seen.insert(index)
                    seen.insert(matchIndex)
                }
                
                cards[index].isFaceUp = true
            }
            else{
                indexOfOneAndOnlyFaceUpCard = index
            }
        }
    }
    
    func reset(){
        flipCount = 0
        score = 0
        seen = []
        for index in cards.indices{
            cards[index].isFaceUp = false
            cards[index].isMatched = false
        }
        cards.shuffle()
    }
    
    init(numberOfPairsOfCards: Int){
        assert(numberOfPairsOfCards > 0, "Concentration.init(\(numberOfPairsOfCards)): you must have at least one pair of cards")
        for _ in 1...numberOfPairsOfCards{
            let card = Card()
            cards += [card,card]
        }
        cards.shuffle()
    }
}

extension Array {
    mutating func shuffle(){
        if count < 2 {
            return
        }
        for i in indices.dropLast(){
            let diff = distance(from: i, to: endIndex)
            let j = index(i, offsetBy: diff.arc4random)
            swapAt(i, j)
        }
    }
}
