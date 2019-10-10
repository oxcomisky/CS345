//
//  PreviewController.swift
//  Disperse
//
//  Created by Comisky, Jon T on 2/23/19.
//  Copyright © 2019 Comisky, Jon T. All rights reserved.
//

import UIKit
class PreviewController: UIViewController{
    private let startButton: UILabel = UILabel()
    private let SCard: UIImageView = UIImageView()
    private let DCard: UIImageView = UIImageView()
    private let HCard: UIImageView = UIImageView()
    private let CCard: UIImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startButton.frame = CGRect(x: UIScreen.main.bounds.width / 2 - 50, y: (UIScreen.main.bounds.height) - (UIScreen.main.bounds.height / 4), width: 100, height: 50)
        startButton.text = "START"
        startButton.textColor = UIColor.white
        startButton.textAlignment = NSTextAlignment.center
        startButton.backgroundColor = UIColor.black
        startButton.isUserInteractionEnabled = true
        
        DCard.frame = CGRect(x: (CONTROLSPACE+CONTROLSIZE)*1 - 26, y:(3*CONTROLSIZE), width: CARDWIDTH, height: CARDHEIGHT)
        DCard.image = UIImage(named: "s-e-150.png")
        
        SCard.frame = CGRect(x: (CONTROLSPACE+CONTROLSIZE)*2 - 26, y:(3*CONTROLSIZE), width: CARDWIDTH, height: CARDHEIGHT)
        SCard.image = UIImage(named: "d-e-150.png")
        
        HCard.frame = CGRect(x: (CONTROLSPACE+CONTROLSIZE)*3 - 26 , y:(3*CONTROLSIZE), width: CARDWIDTH, height: CARDHEIGHT)
        HCard.image = UIImage(named: "h-e-150.png")
        
        CCard.frame = CGRect(x: (CONTROLSPACE+CONTROLSIZE)*4 - 26, y:(3*CONTROLSIZE), width: CARDWIDTH, height: CARDHEIGHT)
        CCard.image = UIImage(named: "c-e-150.png")
        
        
        self.view.addSubview(startButton)
        self.view.addSubview(DCard)
        self.view.addSubview(SCard)
        self.view.addSubview(HCard)
        self.view.addSubview(CCard)
        self.view.backgroundColor = UIColor.purple
        self.DCard.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/6))
        self.DCard.center = CGPoint(x: (3.0*CONTROLSIZE), y: 8*CONTROLSPACE)
        self.SCard.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/15))
        self.SCard.center = CGPoint(x: (4.35*CONTROLSIZE), y: 7.5*CONTROLSPACE)
        self.HCard.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/18))
        self.HCard.center = CGPoint(x: (5.75*CONTROLSIZE), y: 7.5*CONTROLSPACE)
        self.CCard.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/6))
        self.CCard.center = CGPoint(x: (7.0*CONTROLSIZE), y: 8.15*CONTROLSPACE)
        
        startButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PreviewController.handleStartButton(_:))))
    }
    
    @objc func handleStartButton(_ recognizer: UISwipeGestureRecognizer) {
        let vc: ViewController = ViewController()
        self.present(vc, animated: true, completion: {() -> Void in
            vc.enterNewGame()
        })
    }
}
