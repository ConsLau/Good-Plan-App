//
//  BlogDetailsViewController.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 11/5/2023.
//

import UIKit

class BlogDetailsViewController: UIViewController {
    
    
    
    @IBOutlet weak var blogTitle: UILabel!
    @IBOutlet weak var blogImage: UIImageView!
//    @IBOutlet weak var blogContent: UILabel!
    
    @IBOutlet weak var blogContent: UITextView!
    var selectedBlog: Blog?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showDetails()
        
    }
    
    func showDetails(){
        if let blog = selectedBlog {
            blogTitle.text = blog.blogTitle
            blogContent.text = blog.blogContent

            if let imageName = blog.blogImage {
                let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
                let imagePath = "\(documentDirectoryPath)/\(imageName)"
                let imageURL = URL(fileURLWithPath: imagePath)
                
                if FileManager.default.fileExists(atPath: imageURL.path) {
                    blogImage.image = UIImage(contentsOfFile: imageURL.path)
                } else {
                    print("Image file not found at path: \(imageURL.path)")
                }
            }
        }
    }

}
