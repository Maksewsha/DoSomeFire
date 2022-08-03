//
//  ViewController.swift
//  DoSomeFire
//
//  Created by admin on 02.08.2022.
//
import FirebaseAuth
import FirebaseDatabase
import UIKit

class LoginViewController: UIViewController {
    
    
    private let segueIdentifier = "tasksSegue"
    private var ref: DatabaseReference!

    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var doesntExistLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference(withPath: "users")
        doesntExistLabel.alpha = 0
        
        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            if user != nil{
                self?.performSegue(withIdentifier: (self?.segueIdentifier)!, sender: nil)
            }
        }
    }
    
    private func displayWarningLabel(withText text: String){
        doesntExistLabel.text = text
        UIView.animate(withDuration: 3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut) { [weak self] in
            self?.doesntExistLabel.alpha = 1
        } completion: { [weak self] complete in
            self?.doesntExistLabel.alpha = 0
        }

    }


    @IBAction func registerTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passTextField.text, email != "", password != "" else {
            displayWarningLabel(withText: "Data is incorrect")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] user, error in
            guard error == nil, user != nil else {
                print(error?.localizedDescription)
                return
            }
            
            let userRef = self?.ref.child((user?.user.uid)!)
            userRef!.setValue(["email" : user?.user.email])
            
        }
    }
    
    
    @IBAction func loginTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passTextField.text, email != "", password != "" else {
            displayWarningLabel(withText: "Data is incorrect")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] user, error in
            if error != nil{
                self?.displayWarningLabel(withText: "Error occured")
                return
            }
            if user != nil {
                self?.performSegue(withIdentifier: "tasksSegue", sender: nil)
                return
            }
            
            self?.displayWarningLabel(withText: "No such user")
        }
    }
    
    @IBAction func signOutTapped(_ sender: UIBarButtonItem){
        do{
            try Auth.auth().signOut()
        } catch let error as NSError{
            
        }
        dismiss(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailTextField.text = ""
        passTextField.text = ""
    }
    
    
}

