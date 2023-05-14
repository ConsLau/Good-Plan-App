//
//  AllBlogViewController.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 11/5/2023.
//
// Reference 1 Swift: TableView w/ Custom Cells Tutorial (2021, iOS) - 2021: https://www.youtube.com/watch?v=R2Ng8Vj2yhY
// Reference 2 What does main.sync in global().async mean?: https://stackoverflow.com/questions/42772907/what-does-main-sync-in-global-async-mean
// Reference 3 Swift: Multiple Inheritance from classes Error UIViewController and UIIMagePickerController: https://stackoverflow.com/questions/28598014/swift-multiple-inheritance-from-classes-error-uiviewcontroller-and-uiimagepicke
// Reference 4 Security of runtime process in iOS and iPadOS: https://support.apple.com/en-au/guide/security/sec15bfe098e/web


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
        
        self.navigationController?.navigationController?.isNavigationBarHidden = false

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        blogCoreDataController?.addListener(listener: self)
        
        self.navigationController?.navigationController?.isNavigationBarHidden = true
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
