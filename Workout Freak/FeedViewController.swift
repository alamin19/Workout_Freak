//
//  FeedViewController.swift
//  Workout Freak
//
//  Created by Al Amin on 28.03.18.
//  Copyright © 2018 Amin. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import SVProgressHUD
import GoogleMobileAds

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GADBannerViewDelegate {
    
    @IBOutlet weak var bannerView: GADBannerView!

    // MARK: IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addImage: CircleView!
    @IBOutlet weak var captionField: CustomTextField!
    
    // MARK: Variables
    
    var selectedCell = 0
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var imageSelected = false
    
    // MARK: VC Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bannerView.adUnitID = "ca-app-pub-5854090999342595/4909237362"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        // tableView delegates
        tableView.delegate = self
        tableView.dataSource = self
        
        // initalize image picker
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        // listener to get post data
        // with a query to sort by postedDate
        if Auth.auth().currentUser == nil {
            SVProgressHUD.show()
             
            Auth.auth().signIn(withEmail: "lisanalamin@gmail.com", password: "postQuote123", completion: { (user, error) in
                let id = Auth.auth().currentUser?.uid
                let  keychainResult = KeychainWrapper.standard.set(id!, forKey: KEY_UID)
                DataService.ds.REF_POSTS.queryOrdered(byChild: "postedData").observe(.value, with: { (snapshot) in
                    SVProgressHUD.dismiss()
                    // print(snapshot.value)
                    self.posts = []
                    // parse firebase post data
                    if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                        for snap in snapshot {
                            //print("SNAP: \(snap)")
                            
                            if let postDict = snap.value as? Dictionary<String, AnyObject> {
                                let key = snap.key
                                let post = Post(postId: key, postData: postDict)
                                // oldest post first
                                // self.posts.append(post)
                                // newest post first
                                self.posts.insert(post, at: 0)
                            }
                        }
                    }
                    self.tableView.reloadData()
                })
            })
        }
        else {
            SVProgressHUD.show()
            
                DataService.ds.REF_POSTS.queryOrdered(byChild: "postedData").observe(.value, with: { (snapshot) in
                    SVProgressHUD.dismiss()
                    // print(snapshot.value)
                    self.posts = []
                    // parse firebase post data
                    if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                        for snap in snapshot {
                            //print("SNAP: \(snap)")
                            
                            if let postDict = snap.value as? Dictionary<String, AnyObject> {
                                let key = snap.key
                                let post = Post(postId: key, postData: postDict)
                                // oldest post first
                                // self.posts.append(post)
                                // newest post first
                                self.posts.insert(post, at: 0)
                            }
                        }
                    }
                    self.tableView.reloadData()
                })
            
        }
        
    }
    
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }

    // MARK: TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let post = posts.reversed()[indexPath.row] // reverse the tableView elements
        let post = posts[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        
        if let image = FeedViewController.imageCache.object(forKey: post.imageUrl as NSString) {
            cell.configureCell(post: post, image: image)
        } else {
            cell.configureCell(post: post)
        }
        return cell
    
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCell = indexPath.row
        self.performSegue(withIdentifier: "FeedDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FeedDetail" {
            let destination = segue.destination as! FeedDetailVC
            destination.post = posts[selectedCell]
            print(destination)
        } else {
            
            let destination = segue.destination as! LoginViewController
            print(destination)
        }
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
    
    @IBAction func btnCellClicked(_ sender: AnyObject) {
        
        self.performSegue(withIdentifier: "FeedDetail", sender: self)
    }
    
    @IBAction func signOutButtonPressed(_ sender: UIButton) {
        
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("DEV: Id removed from keychain - \(keychainResult)")
        try! Auth.auth().signOut()
        
        if let vc = self.navigationController?.viewControllerWithClass(LoginViewController.self) {
            self.navigationController?.popToViewController(vc, animated: true)
        } else {
            self.performSegue(withIdentifier: "login", sender: sender)
        }
        
        
    }
    
    @IBAction func addImagePressed(_ sender: AnyObject) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func postButtonPressed(_ sender: AnyObject) {
        // check if there is any caption and image before posting
        guard let caption = captionField.text, caption != "" else {
            print("DEV: Caption must be entered")
            // TODO: Inform the user to enter a caption (or make it optional)
            return
        }
        guard let image = addImage.image, imageSelected == true else {
            print("DEV: An image must be selected")
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
            DataService.ds.REF_POST_IMAGES.child(imageUid).putData(imageData, metadata: metadata) { (metadata, error) in
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
        
    }

    // MARK: Upload helper method
    
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
        // reload tableView
        tableView.reloadData()
    }

}

extension UINavigationController {
    
    func viewControllerWithClass(_ aClass: AnyClass) -> UIViewController? {
        
        for vc in self.viewControllers {
            
            if vc.isMember(of: aClass) {
                
                return vc
            }
        }
        
        return nil
    }
}
