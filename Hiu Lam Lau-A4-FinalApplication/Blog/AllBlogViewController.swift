//
//  AllBlogViewController.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 11/5/2023.
//

import UIKit

class AllBlogViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DatabaseListener {
    

    @IBOutlet weak var blogTable: UITableView!
    
    // varable
    var blogCoreDataController: BlogCoreDataController?
    var listenerType: ListenerType = .blog
    var allBlogs: [Blog] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        blogCoreDataController = appDelegate?.blogDatabaseController as? BlogCoreDataController
        
        blogTable.dataSource = self
        blogTable.delegate = self

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
        blogTable.reloadData()
    }
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allBlogs.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        guard let blogCell = tableView.dequeueReusableCell(withIdentifier: "BlogCell", for: indexPath) as? BlogTableViewCell else {
//                fatalError("Unable to dequeue BlogCell")
//            }
        
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
            }
            
        }
        
        blogCell.selectionStyle = .none
        
        return blogCell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let blog = allBlogs[indexPath.row]
            blogCoreDataController?.deleteTask(blog: blog)
        } else if editingStyle == .insert {
            
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBlogDetails" {
            if let blogDetailsViewController = segue.destination as? BlogDetailsViewController, let selectedIndexPath = blogTable.indexPathForSelectedRow {
                blogDetailsViewController.selectedBlog = allBlogs[selectedIndexPath.row]
            }
        }
    }

    



}
