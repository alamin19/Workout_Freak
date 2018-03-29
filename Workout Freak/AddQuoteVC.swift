//
//  AddQuoteVC.swift
//  Workout Freak
//
//  Created by Sikander Zeb on 1/4/18.
//  Copyright © 2018 Amin. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import SVProgressHUD

class AddQuoteVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var addImage: UIImageView!
    @IBOutlet weak var captionField: UITextView!
    
    // MARK: Variables
    
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // initalize image picker
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
    }
    
    // MARK: Imagepicker
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            addImage.image = image
            imageSelected = true
        } else {
            print("DEV: Invalid image selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: IBActions
    
    @IBAction func signOutButtonPressed(_ sender: AnyObject) {
        performSegue(withIdentifier: "shwoPosts", sender: sender)
//        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
//        print("DEV: Id removed from keychain - \(keychainResult)")
//        try! Auth.auth().signOut()
//        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addImagePressed(_ sender: AnyObject) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func postButtonPressed(_ sender: AnyObject) {
        // check if there is any caption and image before posting
        if captionField.text == "Type Quote Here" {
            captionField.text = ""
        }
        guard let caption = captionField.text, caption != "" else {
            print("DEV: Caption must be entered")
            LoginViewController.showAlert(self, title: "Quote missing", message: "Enter quote please")
            return
        }
        guard let image = addImage.image, imageSelected == true else {
            print("DEV: An image must be selected")
            LoginViewController.showAlert(self, title: "Image missing", message: "Select image please")
            // TODO: Inform the user to select an image
            return
        }
        
        // upload compressed image
        if let imageData = UIImageJPEGRepresentation(image, 0.2) {
            // get a unique identifier and set metadata
            let imageUid = NSUUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            // post image and metadata in child of Unique identifier
            SVProgressHUD.show()
            DataService.ds.REF_POST_IMAGES.child(imageUid).putData(imageData, metadata: metadata) { (metadata, error) in
                SVProgressHUD.dismiss()
                if error != nil {
                    print("DEV: Unable to upload image to Firebase storage")
                    // TODO: Inform the user that the upload has failed
                } else {
                    print("DEV: Successfully uploaded image to Firebase storage")
                    // get download url to the image
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    // create a post with the downloadURL
                    if let url = downloadURL {
                        self.postToFirebase(imageUrl: url)
                    }
                }
            }
        }
        
        // TODO: prevent uploading identical posts (Eg. fast pressing the button?)
        
    }
    
    func postToFirebase(imageUrl: String) {
        // define the dictionary
        let post: Dictionary<String, Any> = [
            "caption": captionField.text!,
            "imageUrl": imageUrl,
            "likes": 0,
            "postedDate": ServerValue.timestamp()
        ]
        // create a post, using Firebase to create a postId
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        // reset UI
        captionField.text = ""
        imageSelected = false
        addImage.image = UIImage(named: "add-image")
        performSegue(withIdentifier: "shwoPosts", sender: self)
        // reload tableView
        //tableView.reloadData()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}

extension AddQuoteVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Type Quote Here" {
            textView.text = ""
        }
    }
}
