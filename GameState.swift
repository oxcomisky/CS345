//
//  GameState.swift
//  Disperse
//
//  Created by Tim Gegg-Harrison, Nicole Anderson on 12/20/13.
//  Copyright © 2013 TiNi Apps. All rights reserved.
//

import UIKit

class GameState {
    var board: [CardView]
    var blueTurn: Bool
    var blueName: String
    var redName: String
    var blueScore: Int
    var redScore: Int
    var freshGame: Bool
    
    init() {
        board = [CardView]()
        blueTurn = true
        blueName = ""
        redName = ""
        blueScore = 0
        redScore = 0
        freshGame = true
    }
}
