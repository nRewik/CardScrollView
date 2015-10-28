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
    var originIndex = 0
    
    var fullCardSize: CGSize{
        return frame.size
    }
    
    var shrinkedCardSize: CGSize{
        return CGSize(width: fullCardSize.width*downScale, height: fullCardSize.height*downScale)
    }
    
    // card position
    func cardCenterAtIndex(index: Int) -> CGPoint{
        
        let centerY = frame.size.height/2.0
        let centerX: CGFloat
        
        if selectionMode{
            let ralativeIndex = CGFloat(index-originIndex)
            let eachItemWidth = spaceBetweenCard + shrinkedCardSize.width
            centerX = centerXReference - (fullCardSize.width/2.0) + (eachItemWidth * ralativeIndex)
        }else{
            centerX = (fullCardSize.width + spaceBetweenCard) * CGFloat(index) + fullCardSize.width/2.0
        }
        return CGPoint(x: centerX, y: centerY)
    }
    
    // scroll view offset
    var centerXReference: CGFloat = 0.0

    var fragmentWidth: CGFloat{
        return fullCardSize.width - shrinkedCardSize.width - 2*spaceBetweenCard
    }
    
    var perCardOffset: CGFloat{
        return shrinkedCardSize.width + fragmentWidth/2.0 + spaceBetweenCard
    }
    
    func scrollOffsetInSelectionMode(index index: Int) -> CGPoint{
        
        let relativeCardIndex = CGFloat( max(0,index) - originIndex)
        let aggregatedFragment = fragmentWidth/2.0 * relativeCardIndex
        let xOffset = centerXReference - fullCardSize.width + relativeCardIndex * perCardOffset - aggregatedFragment
        return CGPoint(x: xOffset, y: 0.0)
    }
    
    public func addCardAtIndex(index: Int) -> UIView{
        return addCardAtIndex(index, animated: false)
    }
    
    public func addCardAtIndex(index: Int, animated: Bool) -> UIView{
        
        let newView = UIView()
        _cards.insert(newView, atIndex: index)

        scrollView.addSubview(newView)
        scrollView.sendSubviewToBack(newView)

        if animated{
            
            adjustScrollViewContentSize()
            adjustCardSize()
            adjustCardTransform()
            
            newView.transform = CGAffineTransformMakeScale(0.001, 0.001)
            newView.center = cardCenterAtIndex(index)
            UIView.animateWithDuration(0.35){
                self.adjustCardPosition()
                newView.transform = self.selectionMode ? CGAffineTransformMakeScale(self.downScale, self.downScale) : CGAffineTransformIdentity
            }
            
        }else{
            layoutSubviews()
        }
        return newView
    }
    
    public func removeCardAtIndex(index: Int){
        removeCardAtIndex(index, animated: false)
    }
    
    public func removeCardAtIndex(index: Int, animated: Bool){
        
        if animated{
            
            let targetCard = cards[index]
            _cards.removeAtIndex(index)
            
            selectedIndex = max(0,min(cards.count-1,selectedIndex)) //truncated
            UIView.animateWithDuration(0.3,
            animations: {
                targetCard.transform = CGAffineTransformMakeScale(0.001, 0.001)
                self.adjustScrollViewOffset()
                self.adjustCardPosition()
            },
            completion: { finish in
                self.layoutSubviews()
                targetCard.removeFromSuperview()
            })
        }else{
            _cards[index].removeFromSuperview()
            _cards.removeAtIndex(index)
            selectedIndex = max(0,min(cards.count-1,selectedIndex)) //truncated
            layoutSubviews()
        }
    }
    
    private func updateSelection(selection: Bool){
        
        if selection{
            
            scrollView.pagingEnabled = false
            scrollView.scrollEnabled = true
            
            // set origin index
            let _originIndex = (scrollView.contentOffset.x + fullCardSize.width/2.0) / fullCardSize.width
            originIndex = Int(_originIndex)
            centerXReference = (fullCardSize.width * _originIndex) + (fullCardSize.width/2.0)
            
            adjustCardPosition()
            adjustCardTransform()
        }else{
            
            // force scroll view to stop scrolling
            scrollView.setContentOffset(scrollView.contentOffset, animated: false)
            
            scrollView.pagingEnabled = true
            scrollView.scrollEnabled = false

            adjustCardPosition()
            adjustCardTransform()

            let xOffset = (self.fullCardSize.width + self.spaceBetweenCard) * CGFloat(self.selectedIndex)
            scrollView.contentOffset.x = xOffset
        }

        
    }
    
    // MARK: - Layout
    override public func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame.size = frame.size
        adjustScrollViewContentSize()
        adjustCardSize()
        adjustCardPosition()
        adjustCardTransform()
        adjustScrollViewOffset()
    }
    
    func adjustScrollViewContentSize(){
        let contentWidth = fullCardSize.height * CGFloat(cards.count)
        let contentHeight = frame.height
        scrollView.contentSize = CGSize(width: contentWidth, height: contentHeight)
    }
    
    func adjustScrollViewOffset(){
        if selectionMode{
            scrollView.contentOffset = scrollOffsetInSelectionMode(index: selectedIndex)
        }else{
            scrollView.contentOffset.x = (fullCardSize.width + spaceBetweenCard) * CGFloat(selectedIndex)
        }
    }
    
    func adjustCardSize(){
        for card in cards{
            card.transform = CGAffineTransformIdentity
            card.frame.size = fullCardSize
        }
    }
    
    func adjustCardPosition(){
        for (index,card) in cards.enumerate(){
            card.center = cardCenterAtIndex(index)
        }
    }

    func adjustCardTransform(){
        for card in cards{
            card.transform = selectionMode ? CGAffineTransformMakeScale(downScale, downScale) : CGAffineTransformIdentity
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
    
    init(numberOfCards: Int){
        super.init(frame: CGRect())
        for _ in 0..<numberOfCards{
            _cards += [UIView()]
        }
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
