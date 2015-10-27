//
//  CardScrollView+ScrollViewDelegate.swift
//  Pods
//
//  Created by Nutchaphon Rewik on 23/10/2015.
//
//

import UIKit

extension CardScrollView: UIScrollViewDelegate{
    
    public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        // if not swipe -> calculate position relate to index
        // swipe right -> move to next card
        // swift left -> move to previous card
        
        if abs(velocity.x-0) < 0.001{
            
            let _currentCardIndex = floor( (targetContentOffset.memory.x - perCardOffset/2.0 - centerXReference) /  perCardOffset)
            selectedIndex = originIndex + Int(_currentCardIndex) + 1
        }else{
            selectedIndex += velocity.x > 0 ? 1 : -1
        }
        
        selectedIndex = max(0,min(cards.count-1,selectedIndex)) //truncated
        targetContentOffset.memory = scrollOffsetInSelectionMode(index: selectedIndex)
    }
    
}