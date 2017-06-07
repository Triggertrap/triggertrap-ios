//
//  InspirationCarousel.swift
//  TriggertrapSLR
//
//  Created by Valentin Kalchev on 13/04/2015.
//  Copyright (c) 2015 Triggertrap Ltd. All rights reserved.
//

import UIKit

class CarouselViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    var imagesOffsetConstraints: [NSLayoutConstraint] = []
    
    let imageData = ["1.jpg", "2.jpg", "3.jpg", "4.jpg"]
    
    var currentIndex = 0
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        setupScrollViewImages()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(width: scrollView.frame.width * CGFloat(self.imageData.count), height: scrollView.frame.height)
        
        for index in 0..<imagesOffsetConstraints.count {
            imagesOffsetConstraints[index].constant = CGFloat(index) * scrollView.frame.width
        }
        
        moveContentOfScrollView(scrollView, toIndex: currentIndex, withAnimation: true)
        
        self.view.layoutSubviews()
    }
    
    // MARK: - Private
    
    private func setupScrollViewImages() {
        
        for index in 0..<imageData.count {
            let imageView = UIImageView(frame: CGRect(x: CGFloat(index) * scrollView.frame.width, y: 0, width: scrollView.frame.width, height: scrollView.frame.height))
            imageView.contentMode = UIViewContentMode.ScaleAspectFill
            imageView.image = UIImage(named: imageData[index])
            imageView.clipsToBounds = true
            
            scrollView.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false 
            
            scrollView.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: scrollView, attribute: NSLayoutAttribute.Height, multiplier: 1.0, constant: 0.0))
            
            scrollView.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: scrollView, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0.0))
            
            scrollView.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: scrollView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0))
            
            imagesOffsetConstraints.append(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: scrollView, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: CGFloat(index) * scrollView.frame.width))
            
            scrollView.addConstraint(imagesOffsetConstraints[index])
        }
    }
    
    // MARK: - Action
    @IBAction func nextButtonTapped(button: UIButton) {
        
        if currentIndex < (imageData.count - 1) {
            currentIndex++
        }
        
        moveContentOfScrollView(scrollView, toIndex: currentIndex, withAnimation: true)
    }
    
    @IBAction func previousButtonTapped(button: UIButton) {
        if currentIndex > 0 {
            currentIndex--
        }
        
        moveContentOfScrollView(scrollView, toIndex: currentIndex, withAnimation: true)
    }
}

extension CarouselViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let index = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        moveContentOfScrollView(scrollView, toIndex: index, withAnimation: true)
    } 
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let index = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        moveContentOfScrollView(scrollView, toIndex: index, withAnimation: true)
    }
    
    // Hide the previous and next button while user starts scrolling
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        previousButton.hidden = true
        nextButton.hidden = true
    }
    
    private func moveContentOfScrollView(scrollView: UIScrollView, toIndex index: Int, withAnimation animation: Bool) {
        currentIndex = index
        
        previousButton.hidden = (index == 0) ? true : false
        nextButton.hidden = (index == (imageData.count - 1)) ? true : false
        
        scrollView.setContentOffset(CGPoint(x: scrollView.frame.width * CGFloat(index), y: 0.0), animated: true)
    }
}
