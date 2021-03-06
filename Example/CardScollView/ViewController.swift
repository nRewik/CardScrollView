//
//  ViewController.swift
//  CardScollView
//
//  Created by nRewik on 10/23/2015.
//  Copyright (c) 2015 nRewik. All rights reserved.
//

import UIKit
import CardScollView

class ViewController: UIViewController {

    @IBOutlet weak var cardScrollView: CardScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    @IBAction func toggleSelectionMode(sender: AnyObject) {
        UIView.animateWithDuration(0.3){
            self.cardScrollView.selectionMode = !self.cardScrollView.selectionMode
        }
    }
    
    var count = 0
    @IBAction func addItemButtonTapped(sender: AnyObject) {
        let colors = [UIColor.redColor(),UIColor.brownColor(),UIColor.yellowColor()]
        let newCard = cardScrollView.addCardAtIndex(cardScrollView.selectedIndex, animated: true)
        newCard.backgroundColor = colors[ (self.count++) % colors.count ]
    }
    
    @IBAction func removeButtonTapped(sender: AnyObject) {
        self.cardScrollView.removeCardAtIndex(self.cardScrollView.selectedIndex, animated: true)
    }

}

