//
//  FeedDetailVC.swift
//  Workout Freak
//
//  Created by Saddam Al Amin on 3/27/18.
//  Copyright © 2018 Al Amin. All rights reserved.
//

import UIKit
import SDWebImage

class FeedDetailVC: UIViewController {
    
    @IBOutlet weak var lblQuoteText: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    var post: Post?
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgView.sd_setImage(with: URL(string: (post?.imageUrl)!), placeholderImage: UIImage(named: "add-image"))
        imgView.setupImageViewer(withImageURL: URL(string: (post?.imageUrl)!))
        
        lblQuoteText.text = post!.caption
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let url = URL(string:(post?.imageUrl)!)
        if let data = try? Data(contentsOf: url!)
        {
            image = UIImage(data: data)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func save(_ sender: AnyObject) {
        UIImageWriteToSavedPhotosAlbum(image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    //MARK: - Add image to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        // Test
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    @IBAction func btnBackClicked(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnShareClicked(_ sender: UIButton) {
        
        // set up activity view controller
        let imageToShare = [ image! ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [
            UIActivityType.airDrop,
            UIActivityType.postToWeibo,
            UIActivityType.print,
            UIActivityType.assignToContact,
            UIActivityType.saveToCameraRoll,
            UIActivityType.addToReadingList,
            UIActivityType.postToFlickr,
            UIActivityType.postToVimeo,
            UIActivityType.postToTencentWeibo,
            UIActivityType.postToTwitter
        ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
