//
//  RatingControll.swift
//  FavouritePlaces
//
//  Created by Dmitrii Timofeev on 02/04/2020.
//  Copyright © 2020 Dmitrii Timofeev. All rights reserved.
//

import UIKit

@IBDesignable class RatingControll: UIStackView {

    
    //MARK: Properties
    
    private var ratingButtons = [UIButton]()
    var rating = 0 {
        didSet{
            updateButtonSelectedState()
        }
    }
    
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        
        didSet {
            setupButtons()
        }
        
    }
    @IBInspectable var starCount: Int = 5 {
        
        didSet{
            setupButtons()
        }
        
    }
    

    //MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    //MARK: Button Action
    
    @objc func ratingButtonTapped(button: UIButton) {
        
        guard let index = ratingButtons.firstIndex(of: button) else { return } // этот метод возвращает индекс первого выбраного элемента
        
        // calculate rating of the selected button
        
        let selectedRating = index + 1
        
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
        
    }
    
    
    //MARK: Private methods
    
    private func setupButtons() {
   
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        
        ratingButtons.removeAll()
        
        // load button image
        
        let filledStar = UIImage(systemName: "star.fill")
        let emptyStar = UIImage(systemName: "star")
        let highlightedStar = UIImage(systemName: "star.circle")
        
        
        for _ in 0..<starCount {
            
            let button = UIButton()
                  
                  button.addTarget(self, action: #selector(ratingButtonTapped(button:)), for: .touchUpInside)
                  
                  // set button images
            
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.selected, .highlighted])
            
            
                  
                  button.translatesAutoresizingMaskIntoConstraints = false // отключает автоматически сгенерированые констрейнты для кнопки
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
                  
                  addArrangedSubview(button)
            
            ratingButtons.append(button)
        }
        
        updateButtonSelectedState()
        
    }
    
    private func updateButtonSelectedState() {
        
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
        }
        
    }
    
    
}
