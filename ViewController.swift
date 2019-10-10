//
//  ViewController.swift
//  Disperse
//
//  Created by Tim Gegg-Harrison, Nicole Anderson on 12/20/13.
//  Copyright © 2013 TiNi Apps. All rights reserved.
//

import UIKit

let CARDWIDTH: CGFloat = UIScreen.main.bounds.size.width / 4.0
let CARDHEIGHT: CGFloat = 214.0 * CARDWIDTH / 150.0

let CONTROLSIZE: CGFloat = UIScreen.main.bounds.size.width / 10.0
let CONTROLSPACE: CGFloat = (UIScreen.main.bounds.size.width - (5.0 * CONTROLSIZE)) / 6.0
let CONTROLLEFTOFFSET: CGFloat = (2.0 * CONTROLSPACE) + CONTROLSIZE
let CONTROLTOPOFFSET: CGFloat = UIScreen.main.bounds.size.height - 3.0 * CONTROLSIZE

class ViewController: UIViewController {
    
    private let MAXCARDS: Int = 10
    private let BLUE: UIColor = UIColor(red: 0.0, green: 0.0, blue: 0.609375, alpha: 1.0)
    private let RED: UIColor = UIColor(red: 0.733333, green: 0.0, blue: 0.0, alpha: 1.0)
    
    private let playButton = UIButton(type:  UIButton.ButtonType.custom)
    
    private let game: GameState = GameState()
    private var spades: Bool = true
    private var hearts: Bool = true
    private var diamonds: Bool = true
    private var clubs: Bool = true
    
    private let spadesImage: UIImageView = UIImageView()
    private let heartsImage: UIImageView = UIImageView()
    private let diamondsImage: UIImageView = UIImageView()
    private let clubsImage: UIImageView = UIImageView()
    
    private var blueSuits: Bool = true
    private var redSuits: Bool = true
    private var cards: [Bool] = [Bool]()
    
    private var score: UILabel = UILabel()
    private var quit: UIButton = UIButton()
    private var message: String = String()
    
    private var replayButton: UIButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spades = true
        hearts = true
        diamonds = true
        clubs = true
        
        blueSuits = true
        redSuits = true
        
        //Create image veiws for all images of size CONTROLSIZE x CONTROLSIZE
        //and enable User Interaction
        clubsImage.frame = CGRect(x: (CONTROLSPACE+CONTROLSIZE)*1, y:(2*CONTROLSIZE),width:CONTROLSIZE, height: CONTROLSIZE)
        clubsImage.isUserInteractionEnabled = true
        clubsImage.image = UIImage(named: "club.png")
        
        diamondsImage.frame = CGRect(x: (CONTROLSPACE+CONTROLSIZE)*2, y:(2*CONTROLSIZE),width:CONTROLSIZE, height: CONTROLSIZE)
        diamondsImage.image = UIImage(named: "diamond.png")
        diamondsImage.isUserInteractionEnabled = true
        
        heartsImage.frame = CGRect(x: (CONTROLSPACE+CONTROLSIZE)*3, y:(2*CONTROLSIZE),width:CONTROLSIZE, height: CONTROLSIZE)
        heartsImage.image = UIImage(named: "heart.png")
        heartsImage.isUserInteractionEnabled = true
        
        spadesImage.frame = CGRect(x: (CONTROLSPACE+CONTROLSIZE)*4, y:(2*CONTROLSIZE),width:CONTROLSIZE, height: CONTROLSIZE)
        spadesImage.image = UIImage(named: "spade.png")
        spadesImage.isUserInteractionEnabled = true
        
        
        playButton.frame = CGRect(x: CONTROLLEFTOFFSET+(CONTROLSPACE+CONTROLSIZE)*1, y: CONTROLTOPOFFSET, width: CONTROLSIZE, height: CONTROLSIZE)
        playButton.setImage(UIImage(named: "play"), for: UIControl.State.normal)
        playButton.isEnabled = false
        
        
        self.cards = [Bool].init()
        

        
        //add TapRecognizers to the suit images
        clubsImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewController.ImageTapped(_:))))
        diamondsImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewController.ImageTapped(_:))))
        heartsImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewController.ImageTapped(_:))))
        spadesImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewController.ImageTapped(_:))))
        
        score.frame = CGRect(x: 0, y: CONTROLTOPOFFSET-CONTROLSIZE, width: UIScreen.main.bounds.size.width, height: CONTROLSIZE)
        score.font = UIFont(name: "SCORE", size: CONTROLSIZE/2)
        score.textAlignment = NSTextAlignment.center
        score.text = " vs. "
        
        quit.frame = CGRect(x: CONTROLLEFTOFFSET+(CONTROLSPACE+CONTROLSIZE)*2, y: CONTROLTOPOFFSET, width: CONTROLSIZE, height: CONTROLSIZE)
        quit.setImage(UIImage(named: "quit.png"), for: UIControl.State.normal)
        
        replayButton.frame = CGRect(x: ((CONTROLSPACE*2)+CONTROLSIZE), y: CONTROLTOPOFFSET, width: CONTROLSIZE, height: CONTROLSIZE)
        replayButton.setImage(UIImage(named: "replay.png"), for: UIControl.State.normal)
        
        self.view = UIView(frame: UIScreen.main.bounds)
        self.view.addSubview(playButton)
        playButton.addTarget(self, action: #selector(ViewController.playButtonPressed), for: UIControl.Event.touchUpInside)
        self.view.addSubview(spadesImage)
        self.view.addSubview(clubsImage)
        self.view.addSubview(heartsImage)
        self.view.addSubview(diamondsImage)
        self.view.addSubview(score)
        self.view.addSubview(quit)
        quit.addTarget(self, action: #selector(ViewController.quitButtonPressed), for: UIControl.Event.touchUpInside)
        self.view.backgroundColor = UIColor.blue
        self.view.addSubview(replayButton)
        replayButton.addTarget(self, action: #selector(ViewController.replayButtonPressed), for: UIControl.Event.touchUpInside)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // The following 3 methods were "borrowed" from http://stackoverflow.com/questions/15710853/objective-c-check-if-subviews-of-rotated-uiviews-intersect and converted to Swift
    private func projectionOfPolygon(poly: [CGPoint], onto: CGPoint) ->  (min: CGFloat, max: CGFloat) {
        var minproj: CGFloat = CGFloat.greatestFiniteMagnitude
        var maxproj: CGFloat = -CGFloat.greatestFiniteMagnitude
        for point in poly {
            let proj: CGFloat = point.x * onto.x + point.y * onto.y
            if proj > maxproj {
                maxproj = proj
            }
            if proj < minproj {
                minproj = proj
            }
        }
        return (minproj, maxproj)
    }
    
    private func convexPolygon(poly1: [CGPoint], poly2: [CGPoint]) -> Bool {
        for i in 0..<poly1.count {
            // Perpendicular vector for one edge of poly1:
            let p1: CGPoint = poly1[i];
            let p2: CGPoint = poly1[(i+1) % poly1.count];
            let perp: CGPoint = CGPoint(x: p1.y - p2.y, y: p2.x - p1.x)
            // Projection intervals of poly1, poly2 onto perpendicular vector:
            let (minp1,maxp1): (CGFloat,CGFloat) = self.projectionOfPolygon(poly: poly1, onto: perp)
            let (minp2,maxp2): (CGFloat,CGFloat) = self.projectionOfPolygon(poly: poly2, onto: perp)
            // If projections do not overlap then we have a "separating axis" which means that the polygons do not intersect:
            if maxp1 < minp2 || maxp2 < minp1 {
                return false
            }
        }
        // And now the other way around with edges from poly2:
        for i in 0..<poly2.count {
            // Perpendicular vector for one edge of poly2:
            let p1: CGPoint = poly2[i];
            let p2: CGPoint = poly2[(i+1) % poly2.count];
            let perp: CGPoint = CGPoint(x: p1.y - p2.y, y:
                p2.x - p1.x)
            // Projection intervals of poly1, poly2 onto perpendicular vector:
            let (minp1,maxp1): (CGFloat,CGFloat) = self.projectionOfPolygon(poly: poly1, onto: perp)
            let (minp2,maxp2): (CGFloat,CGFloat) = self.projectionOfPolygon(poly: poly2, onto: perp)
            // If projections do not overlap then we have a "separating axis" which means that the polygons do not intersect:
            if maxp1 < minp2 || maxp2 < minp1 {
                return false
            }
        }
        return true
    }
    
    private func viewsIntersect(view1: UIView, view2: UIView) -> Bool {
        
        return self.convexPolygon(poly1: [view1.convert(view1.bounds.origin, to: nil), view1.convert(CGPoint(x: view1.bounds.origin.x + view1.bounds.size.width, y: view1.bounds.origin.y), to: nil), view1.convert(CGPoint(x: view1.bounds.origin.x + view1.bounds.size.width, y: view1.bounds.origin.y + view1.bounds.height), to: nil), view1.convert(CGPoint(x: view1.bounds.origin.x, y: view1.bounds.origin.y + view1.bounds.height), to: nil)], poly2: [view2.convert(view1.bounds.origin, to: nil), view2.convert(CGPoint(x: view2.bounds.origin.x + view2.bounds.size.width, y: view2.bounds.origin.y), to: nil), view2.convert(CGPoint(x: view2.bounds.origin.x + view2.bounds.size.width, y: view2.bounds.origin.y + view2.bounds.height), to: nil), view2.convert(CGPoint(x: view2.bounds.origin.x, y: view2.bounds.origin.y + view2.bounds.height), to: nil)])
    }
    
    private func cardIsOpenAtIndex(i: Int) -> Bool {
        var j: Int = i+1
        while j < game.board.count && (game.board[j].removed || !self.viewsIntersect(view1: game.board[i], view2: game.board[j])) {
            j += 1
        }
        return (j >= game.board.count)
    }
    
    private func highlightCards() {
        for i in 0..<game.board.count {
            let card: CardView = game.board[i]
            if ((card.suit == "s" && spades) || (card.suit == "h" && hearts) || (card.suit == "d" && diamonds) || (card.suit == "c" && clubs)) && !card.removed && self.cardIsOpenAtIndex(i: i) {
                card.highlight("g")
            }
            else {
                card.highlight("\0")
            }
        }
    }
    @objc func ImageTapped(_ recognizer: UITapGestureRecognizer){
        if game.blueTurn{
            spadesImage.isHidden = true
            heartsImage.isHidden = true
            diamondsImage.isHidden = true
            clubsImage.isHidden = true
            blueSuits = false
            
        }
        if !game.blueTurn{
            spadesImage.isHidden = true
            heartsImage.isHidden = true
            diamondsImage.isHidden = true
            clubsImage.isHidden = true
            redSuits = false
        }
    }
    //make sure isHidden is set to false on each turn
    private func setSuitIndicators() {
        if game.blueTurn {
            if !blueSuits{
                spades = true
                spadesImage.isHidden = true
                hearts = true
                heartsImage.isHidden = true
                diamonds = true
                diamondsImage.isHidden = true
                clubs = true
                clubsImage.isHidden = true
            }else{
                spades = true
                spadesImage.isHidden = false
                hearts = true
                heartsImage.isHidden = false
                diamonds = true
                diamondsImage.isHidden = false
                clubs = true
                clubsImage.isHidden = false
            }
        }
        if !game.blueTurn{
            if !redSuits{
                spades = true
                spadesImage.isHidden = true
                hearts = true
                heartsImage.isHidden = true
                diamonds = true
                diamondsImage.isHidden = true
                clubs = true
                clubsImage.isHidden = true
            }else{
                spades = true
                spadesImage.isHidden = false
                hearts = true
                heartsImage.isHidden = false
                diamonds = true
                diamondsImage.isHidden = false
                clubs = true
                clubsImage.isHidden = false
            }
        }
    }
    
    //remove suits image if suit is not available
    private func updateSuitIndicatorForCard(card: CardView) {
        if card.suit == "s" {
            spades = false
            spadesImage.isHidden = true
        }
        else if card.suit == "h" {
            hearts = false
            heartsImage.isHidden = true
        }
        else if card.suit == "d" {
            diamonds = false
            diamondsImage.isHidden = true
        }
        else {
            clubs = false
            clubsImage.isHidden = true
        }
    }
    
    private func setBackground() {
        if game.blueTurn {
            self.view.backgroundColor = BLUE
        }
        else {
            self.view.backgroundColor = RED
        }
    }
    
    private func createCards() {
        let numOfCards: Int = MAXCARDS + Int(arc4random_uniform(UInt32(MAXCARDS/2)))
        var cardValue: String = "b"
        var cardSuit: String = "c"
        var card: CardView
        game.board = [CardView]()
        for _ in 0..<numOfCards {
            card = CardView(suit: cardSuit, value: cardValue)
            game.board.append(card)
            if cardSuit == "c" {
                cardSuit = "d"
            }
            else if cardSuit == "d" {
                cardSuit = "h"
            }
            else if cardSuit == "h" {
                cardSuit = "s"
            }
            else {
                cardSuit = "c"
                if cardValue == "b" {
                    cardValue = "c"
                }
                else if cardValue == "c" {
                    cardValue = "d"
                }
                else if cardValue == "d" {
                    cardValue = "e"
                }
                else {
                    cardValue = "b"
                }
            }
        }
    }
    
    private func displayCard(card: CardView, index: Int, rotation: CGFloat, center: CGPoint) {
        card.index = index
        card.transform = CGAffineTransform(rotationAngle: rotation*CGFloat(Double.pi)/180.0)
        card.center = center
        card.removed = false
        card.isUserInteractionEnabled = true
        card.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(ViewController.playCard(_:))))
    }
    
    private func displayCards() {
        self.displayCard(card: game.board[0], index: 0, rotation: 0.0, center: CGPoint(x: UIScreen.main.bounds.size.width/2.0, y: UIScreen.main.bounds.size.height/2.0))
        for i in 1..<game.board.count {
            self.displayCard(card: game.board[i], index: i, rotation: CGFloat(arc4random_uniform(45)), center: CGPoint(x: UIScreen.main.bounds.size.width/2.0 + (arc4random_uniform(2)==0 ? -1.0 : 1.0)*CGFloat(arc4random_uniform(UInt32(CARDWIDTH))), y: UIScreen.main.bounds.size.height/2.0 + (arc4random_uniform(2)==0 ? -1.0 : 1.0)*CGFloat(arc4random_uniform(UInt32(CARDHEIGHT)))))
        }
    }
    
    private func shuffleCards() {
        var card: CardView
        for _ in 0...999 {
            let j: Int = Int(arc4random_uniform(UInt32(game.board.count)))
            let k: Int = Int(arc4random_uniform(UInt32(game.board.count)))
            card = game.board[j]
            game.board[j] = game.board[k]
            game.board[k] = card
        }
    }
    
    private func createBoard() {
        self.createCards()
        self.shuffleCards()
        self.displayCards()
    }
    
    private func displayBoard() {
        for card in game.board {
            if !card.removed {
                self.view.addSubview(card)
            }
        }
    }
    
    private func cleanUpBoard() {
        for card in game.board {
            if !card.removed {
                card.removeFromSuperview()
            }
        }
        game.board = [CardView]()
    }
    
    func enterNewGame() {
        game.blueTurn = true
        self.setBackground()
        self.cleanUpBoard()
        self.createBoard()
        self.displayBoard()
        self.setSuitIndicators()
        self.highlightCards()
        playButton.isEnabled = false
        if self.game.freshGame{
            self.getBlueName()
            
        }
        score.text = (self.game.blueName + " vs. " + self.game.redName + " " + String(self.game.blueScore) + "-" + String(self.game.redScore))
        replayButton.isEnabled = false
    }
    
    @objc func playCard(_ recognizer: UIPanGestureRecognizer) {
        let card: CardView = recognizer.view as! CardView
        if card.highlighted() && !card.removed {
            let translation: CGPoint = recognizer.translation(in: self.view)
            recognizer.view?.center = CGPoint(x: recognizer.view!.center.x + translation.x, y:
                recognizer.view!.center.y + translation.y)
            recognizer.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
            if recognizer.state == UIGestureRecognizer.State.ended {
                self.updateSuitIndicatorForCard(card: card)
                card.removed = true
                card.removeFromSuperview()
                self.highlightCards()
                playButton.isEnabled = true
                quit.isEnabled = true
            }
        }
    }
    
    @objc func playButtonPressed() {
        playButton.isEnabled = false
        game.blueTurn = !game.blueTurn
        self.setBackground()
        self.setSuitIndicators()
        self.highlightCards()
        self.checkForWin()
        replayButton.isEnabled = true
    }
    
    private func checkForWin() {
        //fill an array to show if there is a card present.
        for i in game.board{
            let card: CardView = i
            if card.removed{
                cards.append(false)
            }else{
                cards.append(true)
            }
        }
        //if card isn't present, remove from array
        for i:Bool in cards{
            if !i{
                cards.remove(at: 0)
            }
        }
        //if array is empty show who won
        if cards.isEmpty{
            if game.blueTurn {
                self.game.blueScore += 1
                if self.game.blueScore >= 2 {
                    let winAlert: UIAlertController = UIAlertController(title: "Winner", message: (self.game.blueName + " Won the the Game!"), preferredStyle:
                        UIAlertController.Style.alert)
                    winAlert.addAction(UIAlertAction(title: "OK", style:
                        UIAlertAction.Style.default, handler:
                        {(action: UIAlertAction!) -> Void in
                            self.presentingViewController?.dismiss(animated: false, completion: {() -> Void in
                                self.game.blueScore = 0
                                self.game.redScore = 0
                                self.game.freshGame = true
                            })
                    }))
                    self.present(winAlert, animated: true, completion:
                        {() -> Void in})
                }else{
                    let alert: UIAlertController = UIAlertController(title: "End of the round", message: (self.game.blueName + " Won the round!"), preferredStyle:
                        UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style:
                        UIAlertAction.Style.default, handler:
                        {(action: UIAlertAction!) -> Void in
                            self.enterNewGame()
                            
                    }))
                    self.present(alert, animated: true, completion:
                        {() -> Void in})
                }
            }
            if !game.blueTurn {
                self.game.redScore += 1
                if self.game.redScore >= 2 {
                    let winAlert: UIAlertController = UIAlertController(title: "Winner", message: (self.game.redName + " Won the the Game!"), preferredStyle:
                        UIAlertController.Style.alert)
                    winAlert.addAction(UIAlertAction(title: "OK", style:
                        UIAlertAction.Style.default, handler:
                        {(action: UIAlertAction!) -> Void in
                            self.presentingViewController?.dismiss(animated: false, completion: {() -> Void in
                                self.game.blueScore = 0
                                self.game.redScore = 0
                                self.game.freshGame = true
                            })
                    }))
                    self.present(winAlert, animated: true, completion:
                        {() -> Void in})
                }else{
                    let alert: UIAlertController = UIAlertController(title: "End of the round", message: (self.game.redName + " Won the round!"), preferredStyle:
                        UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style:
                        UIAlertAction.Style.default, handler:
                        {(action: UIAlertAction!) -> Void in
                            self.enterNewGame()
                    }))
                    self.present(alert, animated: true, completion:
                        {() -> Void in})
                }
            }
        }
    }
    
    private func getBlueName(){
        let alert: UIAlertController = UIAlertController(title: "Blue Player", message: "Enter your name:", preferredStyle: UIAlertController.Style.alert)
        alert.addTextField { (textField : UITextField!) in
            
        }
        alert.addAction(UIAlertAction(title: "OK", style:
            UIAlertAction.Style.default, handler:
            {(action: UIAlertAction!) -> Void in
                self.game.blueName = alert.textFields?[0].text ?? ""
                self.score.text = self.game.blueName + " vs. "
                self.getRedName()
                
        }))
        self.present(alert, animated: true, completion:
            {() -> Void in
                
        })
    }
    
    private func getRedName(){
        let alert2: UIAlertController = UIAlertController(title: "Red Player", message: "Enter your name:", preferredStyle: UIAlertController.Style.alert)
        alert2.addTextField { (textField : UITextField!) in
        }
        alert2.addAction(UIAlertAction(title: "OK", style:
            UIAlertAction.Style.default, handler:
            {(action: UIAlertAction!) -> Void in
                self.game.redName = alert2.textFields?[0].text ?? ""
                self.score.text?.append(self.game.redName + " " + String(self.game.blueScore) + "-" + String(self.game.redScore))
                self.game.freshGame = false
        }))
        self.present(alert2, animated: true, completion:
            {() -> Void in
        })
    }
    
    @objc private func quitButtonPressed(){
        if game.blueTurn {
            message = self.game.redName
        }else{
            message = self.game.blueName
        }
        let alert: UIAlertController = UIAlertController(title: "Winner", message: message + " wins!", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
            self.presentingViewController?.dismiss(animated: false, completion: {() -> Void in
                self.game.blueScore = 0
                self.game.redScore = 0
                self.game.freshGame = true
                })
        }))
        quit.isEnabled = false
        let quitAlert: UIAlertController = UIAlertController(title: "Quit Game", message: "Are you sure you want to quit?", preferredStyle: UIAlertController.Style.alert)
        quitAlert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: {(action: UIAlertAction!) -> Void in
            self.present(alert, animated: true, completion:
                {() -> Void in
                    
            })
            })
        )
        quitAlert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: {(action: UIAlertAction!) -> Void in
            
        }))
        
        self.present(quitAlert, animated: true, completion:
            {() -> Void in
                
        })
        
        
    }
    @objc private func replayButtonPressed(){
        
    }
}


