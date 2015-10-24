//
//  CardScrollView.swift
//  Pods
//
//  Created by Nutchaphon Rewik on 23/10/2015.
//
//

import UIKit

@IBDesignable public class CardScrollView: UIView {
    
    @IBInspectable public var spaceBetweenCard: CGFloat = 20.0
    @IBInspectable public var downScale: CGFloat = 0.75
    
    @IBInspectable public var selectionMode: Bool = false{
        didSet{
            updateSelection(selectionMode)
        }
    }
    public var selectedIndex: Int = 0
    
    public var cards: [UIView]{
        return _cards
    }
    
    let scrollView = UIScrollView()
    var _cards: [UIView] = []
    
    var originIndex: Int = 0
    
    var fullCardSize: CGSize{
        return frame.size
    }
    
    var shrinkedCardSize: CGSize{
        return CGSize(width: fullCardSize.width*downScale, height: fullCardSize.height*downScale)
    }
    
    var fragmentWidth: CGFloat{
        return fullCardSize.width - shrinkedCardSize.width - 2*spaceBetweenCard
    }
    
    var perCardOffset: CGFloat{
        return shrinkedCardSize.width + fragmentWidth/2.0 + spaceBetweenCard
    }
    var xOffsetOriginReference: CGFloat{
        return cards[originIndex].frame.origin.x - spaceBetweenCard - fragmentWidth/2.0
    }
    
    func scrollOffsetInSelectionMode(index index: Int) -> CGPoint{
        
        guard index >= 0 && index < cards.count else { return CGPointZero }
        
        let relativeCardIndex = CGFloat(index-originIndex)
        let aggregatedFragment = fragmentWidth/2.0 * relativeCardIndex
        let xOffset = xOffsetOriginReference + relativeCardIndex * perCardOffset - aggregatedFragment
        return CGPoint(x: xOffset, y: 0.0)
    }
    
    public func addCardAtIndex(index: Int) -> UIView{
        let newView = UIView()
        _cards.insert(newView, atIndex: index)
        scrollView.addSubview(newView)
        layoutSubviews()
        return newView
    }
    
    public func removeCardAtIndex(index: Int){
        _cards[index].removeFromSuperview()
        _cards.removeAtIndex(index)
        selectedIndex = max(0,min(cards.count-1,selectedIndex)) //truncated
        layoutSubviews()
    }
    
    private func updateSelection(selection: Bool){
        
        if selection{
            
            scrollView.pagingEnabled = false
            scrollView.scrollEnabled = true
            
            // set origin index
            let _originIndex = (scrollView.contentOffset.x + fullCardSize.width/2.0) / fullCardSize.width
            originIndex = max(0,min(cards.count-1,Int(_originIndex))) // truncated
            
            adjustCardInSelectionMode()
        }else{
            
            // force scroll view to stop scrolling
            scrollView.setContentOffset(scrollView.contentOffset, animated: false)
            
            scrollView.pagingEnabled = true
            scrollView.scrollEnabled = false
            

            let xOffset = (self.fullCardSize.width + self.spaceBetweenCard) * CGFloat(self.selectedIndex)
            
            adjustCard()
            scrollView.contentOffset.x = xOffset
        }
        
    }
    
    // MARK: - Layout
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView.frame.size = frame.size
        
        let contentWidth = fullCardSize.height * CGFloat(cards.count)
        let contentHeight = frame.height
        scrollView.contentSize = CGSize(width: contentWidth, height: contentHeight)
        
        for card in cards{
            card.transform = CGAffineTransformIdentity
            card.frame.size = fullCardSize
        }
        
        if selectionMode{
            adjustCardInSelectionMode()
            scrollView.contentOffset = scrollOffsetInSelectionMode(index: selectedIndex)
        }else{
            adjustCard()
            scrollView.contentOffset.x = (fullCardSize.width + spaceBetweenCard) * CGFloat(selectedIndex)
        }
    }
    
    func adjustCard(){
        for ( index, card ) in cards.enumerate(){
            card.transform = CGAffineTransformIdentity
            card.frame.origin.x = (fullCardSize.width + spaceBetweenCard) * CGFloat(index)
            card.center.y = frame.size.height/2.0
        }
    }
    
    func adjustCardInSelectionMode(){
        for ( index, card ) in cards.enumerate(){
            card.transform = CGAffineTransformMakeScale(downScale, downScale)
            let ralativeIndex = CGFloat(index-originIndex)
            let eachItemWidth = spaceBetweenCard + shrinkedCardSize.width
            card.center.x = cards[originIndex].center.x + (eachItemWidth * ralativeIndex)
            card.center.y = frame.size.height/2.0
        }
    }
    
    func setupView(){
        scrollView.delegate = self
        addSubview(scrollView)
        layoutSubviews()
    }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    // MARK: - prepareForInterfaceBuilder
    public override func prepareForInterfaceBuilder() {
        selectedIndex = 1
        let colors = [UIColor.redColor(),UIColor.brownColor(),UIColor.yellowColor()]
        for index in 0..<3{
            let newView = UIView()
            newView.backgroundColor = colors[index % colors.count]
            
            _cards += [newView]
        }
        _cards.forEach(scrollView.addSubview)
        selectedIndex = 1
    }

}
