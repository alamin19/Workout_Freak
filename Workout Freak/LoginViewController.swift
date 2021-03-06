//
//  LoginViewController.swift
//  Workout Freak
//
//  Created by Al Amin on 27.09.16.
//  Copyright © 2018 Amin. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import SVProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: CustomTextField!
    @IBOutlet weak var pwdField: CustomTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true 
    }

    override func viewDidAppear(_ animated: Bool) {
        // if key exist, go directly to FeedViewController
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            print("DEV: ID found in keychain")
            performSegue(withIdentifier: "FeedVC", sender: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // facebook authentification
    @IBAction func facebookButtonPressed(_ sender: AnyObject) {
        // create loginmanager
        
    }
    
    // email authentication
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        // TODO: add alert if the user dont enter anything
        // TODO: the password for firebase has to be at least 6 characters long
        
        if emailField.text == "lisanalamin@gmail.com" && pwdField.text == "postQuote123" {
            if let email = emailField.text, let pwd = pwdField.text {
                SVProgressHUD.show()
                Auth.auth().signIn(withEmail: email, password: pwd, completion: { (user, error) in
                    SVProgressHUD.dismiss()
                    if error == nil {
                        print("DEV: Email user authenticated with Firebase")
                        if let user = user {
                            let userData = ["provider": user.providerID]
                            self.completeSignIn(id: user.uid, userData: userData)
                        }
                    } else {
                        Auth.auth().createUser(withEmail: email, password: pwd, completion: { (user, error) in
                            if error != nil {
                                print("DEV: Unable to authenticate with Firebase using email - \(error)")
                            } else {
                                print("DEV: Account created and successfully authenticated with Firebase")
                                if let user = user {
                                    let userData = ["provider": user.providerID]
                                    self.completeSignIn(id: user.uid, userData: userData)
                                }
                            }
                        })
                    }
                })
            }
        }
        else {
            LoginViewController.showAlert(self, title: "Invalid Credentials", message: "Please login with correct admin credentials")
            return
        }
        
    }
    
    // firebase authentication method
    func firebaseAuth(_ credential: AuthCredential) {
        Auth.auth().signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("DEV: Unable to authenticate with Firebase - \(error)")
            } else {
                print("DEV: Successfully authenticated with Firebase")
                if let user = user {
                    let userData = ["provider": credential.provider]
                    self.completeSignIn(id: user.uid, userData: userData)
                }
            }
        })
    }

    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        // create the firebase user
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        // add userid to keychain
        let  keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("DEV: Data saved to keychain \(keychainResult)")
        // segue to FeedViewController
        performSegue(withIdentifier: "goToPost", sender: nil)
    }
    
    public static func showAlert(_ vc: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    
}

