import UIKit

class ViewController: UIViewController {
    private lazy var game = Concentration(numberOfPairsOfCards:numberOfPairsOfCards)
    var numberOfPairsOfCards: Int {
        return (cardButtons.count + 1) / 2
    }
    private(set) var flipCount = 0 {
        didSet {
            flipCountLabel.text = "Flips: \(flipCount)"
        }
    }
    
    @IBOutlet private weak var flipCountLabel: UILabel!
    
    @IBOutlet private var cardButtons: [UIButton]!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var restart: UIButton!
    
    @IBAction func newGame(){
        game.reset()
        indexTheme = emojiTheme.count.arc4random
        updateViewFromModel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indexTheme = emojiTheme.count.arc4random
        updateViewFromModel()
    }
    
    @IBAction private func touchCard(_ sender: UIButton) {
        flipCount += 1
        if let cardNumber = cardButtons.index(of: sender){
            game.chooseCard(at: cardNumber)
            updateViewFromModel()
        } else{
            print("Chosen Card was not in cardButton")
        }
    }
    
    private func updateViewFromModel(){
        for index in cardButtons.indices {
            let button = cardButtons[index]
            let card = game.cards[index]
            if card.isFaceUp {
                button.setTitle(emoji(for:card), for: UIControlState.normal)
                button.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            }
            else {
                button.setTitle("", for: UIControlState.normal)
                button.backgroundColor = card.isMatched ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0) : #colorLiteral(red: 1, green: 0.8617115617, blue: 0.9409283996, alpha: 1) 
            }
        }
        scoreLabel.text = "Score: \(game.score)"
        flipCountLabel.text = "Flips: \(game.flipCount)"
    }
    
    private struct Theme {
        var name: String
        var emojis: [String]
    }
    
    private var emojiTheme: [Theme] = [
        /*Theme(name: "template for new emoji theme",
              emojis: ["","","","","","","","","","","","",""]),*/
        Theme(name: "Heart",
              emojis: ["💖","❤️","🧡","💚","💙","💜","💕","💝","💘","💗","💓","💔","❣️"]),
        Theme(name: "Food",
              emojis: ["🌭","🍗","🍔","🍝","🍣","🥟","🥓","🌮","🍜","🍕","🥩","🍳","🥖"]),
        Theme(name: "Plant",
              emojis: ["🌵","🌱","🌿","☘️","🌳","🍃","🍄","🌴","🎋","🌾","🌻","🥀","💐"]),
        Theme(name: "Sweet",
              emojis: ["🍫","🍩","🍪","🍮","🍦","🍨","🍰","🍡","🍯","🍬","🍭","🥧","🍧"]),
        Theme(name: "Weather",
              emojis: ["🌝","🌚","🌞","🌙","🌈","✨","⚡️","💫","⛈","🌤","🌊","💨","🔥"])
    ]
    
    private var indexTheme = 0{
        didSet{
            print (indexTheme, emojiTheme[indexTheme].name)
            emoji = [Int: String]()
            emojiChoices = emojiTheme[indexTheme].emojis
        }
    }
    private var emojiChoices = [String]()
    
    
    private var emoji = [Int: String]()
    
    private func emoji(for card: Card) -> String {
        if emoji[card.identifier] == nil, emojiChoices.count > 0 {
            emoji[card.identifier] = emojiChoices.remove(at:emojiChoices.count.arc4random)
            //let randomIndex = Int(arc4random_uniform(UInt32(emojiChoices.count)))
            //emoji[card.identifier] = emojiChoices.remove(at: randomIndex)
        }
        return emoji[card.identifier] ?? "?"
    }
    
    

}

extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(self)))
        }else{
            return 0
        }
    }
}

