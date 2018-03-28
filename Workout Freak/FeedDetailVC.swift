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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgView.sd_setImage(with: URL(string: (post?.imageUrl)!), placeholderImage: UIImage(named: "add-image"))
        imgView.setupImageViewer(withImageURL: URL(string: (post?.imageUrl)!))
        
        lblQuoteText.text = post!.caption
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnBackClicked(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
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
