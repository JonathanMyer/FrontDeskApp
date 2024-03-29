//
//  UserDataViewController.swift
//  FrontDeskApp
//
//  Created by Jon Myer on 7/2/18.
//  Copyright © 2018 Jonathan Myer. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class UserDataViewController: UIViewController {
    var userRef: DatabaseReference?
    var userQuestionnaire: Bool?
    @IBOutlet weak var labelTextField: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var verificationLabel: UILabel!
    var questionsRef = Database.database().reference().child("questions").ref
    var questionsArray: [String] = []
    var count = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        questionsRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            if(snapshot.value is NSNull){
                print("questions cannot be found")
            } else {
                // get the question array out of the database.
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    let data = child.value  as? String ?? ""
                    self.questionsArray.append(data)
                }
            }
            self.labelTextField.text = self.questionsArray[self.count]
            self.answerTextField.isHidden = true
            self.confirmButton.isHidden = true
            self.verificationLabel.isHidden = true
            
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        
    }
    // saves the data that is answered after each call along with the quesiton that was being asked.
    func saveAnswer (answer: String){
        userRef?.child("answersAndQuestions").child("\(count)").updateChildValues(["answer":answer, "question": self.questionsArray[self.count]])
    }
    
    
    // updates the view by increasing the count to display the next question
    func updateView(){
        if count == 18 && userQuestionnaire == false { // this is for if the full questionnaire is not needed.
            let currentDate = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZ"
            let currentDateString = formatter.string(from: currentDate)
            self.userRef?.child("answersAndQuestions").updateChildValues(["questionnaireDate": currentDateString])
            performSegue(withIdentifier: "toFinishSegue", sender: self)
        }
        if count == 39 { // kicks out of the loop and sends to next page when the questionnaire ends
            let currentDate = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZ"
            let currentDateString = formatter.string(from: currentDate)
            self.userRef?.child("answersAndQuestions").updateChildValues(["questionnaireDate": currentDateString])
            performSegue(withIdentifier: "toFinishSegue", sender: self)
        }
        self.count += 1 // increase count

        // for specific questions whwere yes/no are not applicable.
        if self.count == 7 || self.count == 8 || self.count == 12 || self.count == 25 {
            yesButton.isHidden = true
            noButton.isHidden = true
            answerTextField.isHidden = false
            confirmButton.isHidden = false
            answerTextField.text = ""
            answerTextField.placeholder = ""
            answerTextField.becomeFirstResponder()
        } else { // switch back to yes/no if not one of the previous nubmers.
            yesButton.isHidden = false
            noButton.isHidden = false
            answerTextField.isHidden = true
            confirmButton.isHidden = true
        }
        // updates the view to show the next question.
        self.labelTextField.text = self.questionsArray[self.count]
    }
    
    // activated when the yes button is clicked
    @IBAction func yesButtonAction(_ sender: Any) {
        if self.count == 20 || self.count == 21 || self.count == 23 || self.count == 24{
            yesButton.isHidden = true
            noButton.isHidden = true
            answerTextField.isHidden = false
            confirmButton.isHidden = false
            answerTextField.text = ""
            answerTextField.placeholder = "Amount"
            answerTextField.becomeFirstResponder()
        } else {
            saveAnswer(answer: "yes")
            updateView()
        }

    }
    
    // activated when the no button is clicked
    @IBAction func noButtonActon(_ sender: Any) {
        
        saveAnswer(answer: "no")
        if (count == 6){
            count = 10
        }
        updateView()

    }
    
    // activated when the confirm button is clicked
    @IBAction func confirmButtonAction(_ sender: Any) {
        let answer = answerTextField.text
        if answer!.count == 0 {
            verificationLabel.isHidden = false
        } else {
            verificationLabel.isHidden = true
            saveAnswer(answer: answer!)
            updateView()
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if let destinationViewController = segue.destination as? SignInConfirmViewController {
            destinationViewController.userRef = userRef
        }
    }
}
