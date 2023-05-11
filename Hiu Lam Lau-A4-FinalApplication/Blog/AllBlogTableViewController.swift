//
//  AllBlogTableViewController.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 5/5/2023.
//
// Reference 1 Swift: TableView w/ Custom Cells Tutorial (2021, iOS) - 2021: https://www.youtube.com/watch?v=R2Ng8Vj2yhY
// Reference 2 What does main.sync in global().async mean?: https://stackoverflow.com/questions/42772907/what-does-main-sync-in-global-async-mean

import UIKit

class AllBlogTableViewController: UITableViewController, DatabaseListener {

    
    // varable
    var blogCoreDataController: BlogCoreDataController?
    var listenerType: ListenerType = .blog
    var allBlogs: [Blog] = []
    
    @IBOutlet weak var blogImage: UIImageView!
    
    @IBOutlet weak var blogTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        blogCoreDataController = appDelegate?.blogDatabaseController as? BlogCoreDataController

        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        blogCoreDataController?.addListener(listener: self)
    }
    

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        blogCoreDataController?.removeListener(listener: self)
    }
    

    func onTaskChange(change: DatabaseChange, tasks: [Task]) {
        
    }
    
    func onBlogChange(change: DatabaseChange, blogs: [Blog]) {
        allBlogs = blogs
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allBlogs.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let blogCell = tableView.dequeueReusableCell(withIdentifier: "BlogCell", for: indexPath) as! BlogTableViewCell

        
        if indexPath.row < allBlogs.count{
            let blogs = allBlogs[indexPath.row]
            blogCell.blogTitle.text = blogs.blogTitle
            
            // test
            if let imageName = blogs.blogImage {
                        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
                        let imagePath = "\(documentDirectoryPath)/\(imageName)"
                        let imageURL = URL(fileURLWithPath: imagePath)
                        
                        if FileManager.default.fileExists(atPath: imageURL.path) {
                            blogCell.blogImage.image = UIImage(contentsOfFile: imageURL.path)
                        } else {
                            print("Image file not found at path: \(imageURL.path)")
                        }
                    
            
//            if let imageUrlString = blogs.blogImage {
//                blogCell.blogImage.image = UIImage(contentsOfFile: imageUrlString)
            
                
//                let imageURL = URL(string: imageUrlString)
//                blogCell.imageView?.image = UIImage(contentsOfFile: imageUrlString)
//                if blogs.isLocalImage?.boolValue ?? false, let imageUrl = URL(string: imageUrlString) {
//                    // Load image from local storage
//                    DispatchQueue.global().async {
//                        if let imageData = try? Data(contentsOf: imageUrl) {
//                            DispatchQueue.main.async {
//                                blogCell.blogImage.image = UIImage(data: imageData)
//                            }
//                        }
//                    }
//                } else if let imageUrl = URL(string: imageUrlString) {
//                    // Load image from remote URL
//                    DispatchQueue.global().async {
//                        if let imageData = try? Data(contentsOf: imageUrl) {
//                            DispatchQueue.main.async {
//                                blogCell.blogImage.image = UIImage(data: imageData)
//                            }
//                        }
//                    }
//                }
            }
            
        }
        
        blogCell.selectionStyle = .none
        
        return blogCell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let blog = allBlogs[indexPath.row]
            blogCoreDataController?.deleteTask(blog: blog)
        } else if editingStyle == .insert {
            
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBlogDetails" {
            if let blogDetailsViewController = segue.destination as? BlogDetailsViewController, let selectedIndexPath = tableView.indexPathForSelectedRow {
                blogDetailsViewController.selectedBlog = allBlogs[selectedIndexPath.row]
            }
        }
    }

}
