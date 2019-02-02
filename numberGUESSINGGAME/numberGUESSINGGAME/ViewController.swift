//
//  ViewController.swift
//  RandomNumberGuessingGamePart2
//
//  Created by Manya Goutam on 12/8/18.
//  Copyright © 2018 Manya Goutam. All rights reserved.
// One Sound by Snowflake (c) copyright 2014 Licensed under a Creative Commons Attribution Noncommercial  (3.0) license. http://dig.ccmixter.org/files/snowflake/48115 Ft: Alex Beroza

import UIKit
import AVFoundation
class ViewController: UIViewController {
    var randomNumber:Int!
    var timer:Timer?
    
    
    var audioPlaya:AVAudioPlayer!
    
    // IBOutlet Connections
    @IBOutlet var massageLabel: UILabel!
    @IBOutlet var guessField: UITextField!
    @IBOutlet var guessButton: UIButton!
    @IBOutlet var messages: UITextView!
    
    // Constants
    let MIN = 1
    let MAX = 9
    var MAX_CHARS:Int { // take count of chars in max
        return "\(MAX)".count
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        newGame()
        
        let fileURL = Bundle.main.path(forResource: "snowflake_-_One_Sound", ofType: "mp3")!
            audioPlaya = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileURL))
            audioPlaya.numberOfLoops = -1
            audioPlaya.play()
    }
    
    func resetMassage(){
        massageLabel.text = "Guess a number between \(MIN) and \(MAX)."
        massageLabel.textColor = UIColor.black
        guessField.text = nil
        guessButton.isEnabled = false
    }
    func newGame() {
        randomNumber = Int.random(in: MIN...MAX)
        resetMassage()
        guessField.text = nil
        guessButton.isEnabled = false
        guessField.isEnabled = true
        messages.text = "Starting new game...\n"
        guessField.becomeFirstResponder()
    }
    @IBAction func makeAGuess(_ sender: Any) {
        let GUESS = Int(self.guessField.text ?? "") ?? 0
        var massage = ""
        massageLabel.textColor = UIColor.red
        if(GUESS<MIN || GUESS>MAX){
            
            massage = "Enter a valid guess"
            massageLabel.text = massage
        }
        else if(GUESS<randomNumber){
            massage = "Too Low"
            massageLabel.text = massage
        }else if (GUESS>randomNumber){
            massage = "Too High"
            massageLabel.text = massage
        }else if (GUESS==randomNumber){
            
            massageLabel.textColor = UIColor.green
            massage = "Correct!"
            massageLabel.text = massage
            hideKeyboard(guessButton)
            guessField.isEnabled = false
        }
        // append guess and message to messages with a newline char
        messages.text += "\(GUESS) - \(massage)\n"
        if GUESS == randomNumber {
            if self.timer != nil {
                self.timer?.invalidate()
            }
            Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (timer) in
                self.newGame()
                timer.invalidate()
                self.timer = nil
            }
        }else {
            if self.timer != nil {
                self.timer?.invalidate()
            }
            self.timer = Timer.init(timeInterval: 3, repeats: false) { (timer) in
                self.resetMassage()
                timer.invalidate()
                self.timer = nil
            }
            RunLoop.current.add(self.timer!, forMode: .default)
        }
    }
    
    @IBAction func hideKeyboard(_ sender:Any) {
        guessButton.isEnabled = false
        self.view.endEditing(true)
    }
}

extension ViewController:UIGestureRecognizerDelegate{
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if guessButton.isEnabled && gestureRecognizer.location(in: guessButton.superview).x > guessButton.frame.minX && gestureRecognizer.location(in: guessButton.superview).x<guessButton.frame.maxX && gestureRecognizer.location(in: guessButton.superview).y > guessButton.frame.minY && gestureRecognizer.location(in: guessButton.superview).y<guessButton.frame.maxY{
            
            return false
        }
        
        return true
    }
}

extension ViewController:UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == nil || textField.text?.count == 0 {guessButton.isEnabled=false
            
        } else{ guessButton.isEnabled = true }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length // the current text length plus the new text length minus the selected text length which will be replaced
        if newLength == 0 { guessButton.isEnabled = false
            if self.timer != nil {
                self.timer?.fire()
                self.timer?.invalidate()
                self.timer = nil
            }
        } else {guessButton.isEnabled = true}
        return newLength <= MAX_CHARS
    }
}

