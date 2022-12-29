//
//  ViewController.swift
//  Match
//
//  Created by n on 20.12.2022.
//

import UIKit

class ViewController: UIViewController {
//MARK: - properties
    var buttonsGrid: UIView!
    var buttonsArray = [UIButton]()
    var currentButtons = [UIButton]()
    
    var firstButton: UIButton!
    var secondButton: UIButton!
    var score = 0
    var pairs = [String]()
    var level = 1
    var isGameOver = false
//MARK: - loadView
    override func loadView() {
        view = UIView()
        view.backgroundColor = .black
        buttonsGrid = UIView()
        buttonsGrid.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsGrid)
        
        NSLayoutConstraint.activate([
            buttonsGrid.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            buttonsGrid.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -5),
            buttonsGrid.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            buttonsGrid.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])
    }

//MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createPair()
        DispatchQueue.main.async {
            self.createButton()
        }
    }
    
//MARK: - createButton
    func createButton() {
        pairs.removeLast()
        pairs.shuffle()
        let width = (buttonsGrid.frame.width / 4) - 5
        let height = (buttonsGrid.frame.height / 4) - 5
        var index = 0
        
        for row in 0...3 {
            for column in 0...3 {
                let button = UIButton(type: .custom)
                button.titleLabel?.font = UIFont.systemFont(ofSize: buttonsGrid.frame.width / 20)
                button.setTitleColor(.clear, for: .normal)
                button.setTitle(pairs[index], for: .normal)
                button.isUserInteractionEnabled = true
                button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
                button.backgroundColor = UIColor(red: 1, green: 0.6471, blue: 0.8588, alpha: 1)
                
                let frame = CGRect(x: CGFloat(column) * (width + 5), y: CGFloat(row) * (height + 5), width: width, height: height)
                button.frame = frame
                button.layer.cornerRadius = 5
                
                buttonsGrid.addSubview(button)
                buttonsArray.append(button)
                index += 1
            }
        }
    }
    
//MARK: - buttonTapped
    @objc func buttonTapped(_ sender: UIButton) {
        guard isGameOver == false else { return }
        guard secondButton == nil else { return }
        UIView.transition(with: sender, duration: 0.3, options: .transitionCrossDissolve, animations: {
            sender.setTitleColor(.black, for: .normal)
            sender.backgroundColor = UIColor(red: 0.6078, green: 0.9686, blue: 0.6196, alpha: 1)
        }) { flipped in
            sender.isUserInteractionEnabled = false
            self.currentButtons.append(sender)
        }
        
        if firstButton == nil {
            firstButton = sender
            print("FIRST BUTTON PRESSED")
        } else if firstButton.titleLabel?.text == sender.titleLabel?.text {
            secondButton = sender
            sender.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.firstButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: 2.0,
                           delay: 0,
                           usingSpringWithDamping: 0.2,
                           initialSpringVelocity: 6.0,
                           options: .allowUserInteraction,
                           animations: {
                sender.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                self.firstButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }) { completed in
                self.firstButton = nil
                self.secondButton = nil
                self.score += 2
                if self.score == self.buttonsArray.count {
                    self.isGameOver = true
                    self.showWin()
                }
            }
            print("EQUAL")
        } else if firstButton.titleLabel?.text != sender.titleLabel?.text {
            secondButton = sender
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                UIView.transition(with: self.firstButton, duration: 0.3, options: .transitionFlipFromLeft, animations: {
                    self.firstButton.setTitleColor(.clear, for: .normal)
                    self.firstButton.backgroundColor = UIColor(red: 1, green: 0.6471, blue: 0.8588, alpha: 1)
                }) { flipped in
                    self.firstButton.isUserInteractionEnabled = true
                    self.firstButton = nil
                }
                
                UIView.transition(with: self.secondButton, duration: 0.3, options: .transitionFlipFromRight, animations: {
                    self.secondButton.setTitleColor(.clear, for: .normal)
                    self.secondButton.backgroundColor = UIColor(red: 1, green: 0.6471, blue: 0.8588, alpha: 1)
                }) { flipped in
                    self.secondButton.isUserInteractionEnabled = true
                    self.secondButton = nil
                    self.currentButtons.removeLast(2)
                }
            }
            print("NOT EQUAL")
        }
    }
    
//MARK: - createPair
    func createPair() {
        guard let pairURL = Bundle.main.url(forResource: "level\(level)", withExtension: "txt") else {
            fatalError("Could not find level\(level).txt in the app bundle.")
        }
        guard let pairString = try? String(contentsOf: pairURL) else {
            fatalError("Could not load level.txt from the app bundle.")
        }
        pairs = pairString.components(separatedBy: "\n")
    }
    
//MARK: - showWin
    func showWin() {
        if level == 2 {
            let alert = UIAlertController(title: "Game over", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }

        let alert = UIAlertController(title: "You win!", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Next level", style: .default) { [weak self] _ in
            self?.level += 1
            self?.buttonsArray.removeAll()
            self?.resetGame()
        })
        present(alert, animated: true)
    }
    
//MARK: - resetGame
    func resetGame() {
        isGameOver = false
        score = 0
        firstButton = nil
        secondButton = nil
        currentButtons.removeAll()
        pairs.removeAll()
        for button in buttonsGrid.subviews {
            button.removeFromSuperview()
        }
        self.createPair()
        self.createButton()
    }
}

