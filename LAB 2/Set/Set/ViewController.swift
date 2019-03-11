//
//  ViewController.swift
//  Set
//
//  Created by Jessica Lam on 2/21/19.
//  Copyright © 2019 Jessica Lam. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    lazy var game = Game()
    let figures = ["▲","●","■"]
    let colours = [#colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1),#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1),#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)]
    
    @IBOutlet var cardButtons: [UIButton]!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var setMessage: UILabel!
    
    @IBAction func touchCard(_ sender: UIButton) {
        if let cardNumber = cardButtons.index(of: sender) {
            game.chooseCard(at: cardNumber)
            updateViewFromModel()
        }
    }
    
    @IBAction func dealThreeMoreCards(_ sender: UIButton) {
        if (game.currentCards.count + 3) <= cardButtons.count {
            game.deal()
            updateViewFromModel()
        }
    }
    
    @IBAction func restartGame(_ sender: UIButton) {
        game = Game()
        updateViewFromModel()
    }
    
    private func updateViewFromModel() {
        scoreLabel.text = "Score: \(game.scoreCount)"
        
        let itIsSet = game.isSet
        
        if itIsSet != nil {
            if itIsSet! {
                setMessage.text = "Good job you made a set 😄"
            } else {
                setMessage.text = "Oh no you mismatched 😢"
            }
        } else {
            setMessage.text = ""
        }
        
        for index in cardButtons.indices {
            let button = cardButtons[index]
            button.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            button.alpha = 1
            
            if index < game.currentCards.count {
                let card = game.currentCards[index]
                let color = colours[card.color.rawValue-1]
                
                var attributes: [NSAttributedStringKey : Any] = [
                    .strokeColor: color,
                    .foregroundColor: color,
                    ]
                switch card.shade {
                case .first:
                    attributes[.strokeWidth] = 4 //outline
                    attributes[.foregroundColor] = color
                case .second:
                    attributes[.strokeWidth] = -1 //fully shaded
                    attributes[.foregroundColor] = color
                case .third: //lightly shaded
                    attributes[.strokeWidth] = -1 //half shaded
                    attributes[.foregroundColor] = color.withAlphaComponent(0.15)
                }
                
                let title = String(repeating: figures[card.shape.rawValue-1], count: card.number.rawValue)
                let attributedTitle = NSMutableAttributedString(string: title, attributes: attributes)
                button.setAttributedTitle(attributedTitle, for: .normal)
                
                if game.attemptingToMatchCards.contains(card) || game.selectedCards.contains(card) {
                    button.layer.borderWidth = 3.0
                    if itIsSet != nil {
                        if itIsSet! {
                            button.layer.borderColor = #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1)
                        } else {
                            button.layer.borderColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
                        }
                    } else {
                        button.layer.borderColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
                    }
                } else {
                    button.layer.borderWidth = 0
                }
                
            } else {
                button.alpha = 0
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewFromModel()
    }
}

