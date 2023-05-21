//
//  BlogCoreDataController.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 5/5/2023.
//

import UIKit
import CoreData
import Firebase
import FirebaseAuth

class BlogCoreDataController: NSObject, DatabaseProtocolBlog,  NSFetchedResultsControllerDelegate{
    
    
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer: NSPersistentContainer
    var BlogFetchedResultsController: NSFetchedResultsController<Blog>?
    var BlogFetchedResultsControllerUser: String = ""
    
    
    
    override init() {
        persistentContainer = NSPersistentContainer(name: "BlogModel")
        persistentContainer.loadPersistentStores() { (description, error ) in
            if let error = error {
                fatalError("Failed to load Core Data Stack with error: \(error)")
            }
        }
        super.init()
    }
    
    func cleanup() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                fatalError("Failed to save changes to Core Data with error: \(error)")
            }
        }
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .blog{
            listener.onBlogChange(change: .update, blogs: fetchBlog())
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func addBlog(blogTitle: String, blogContent: String, blogImage: String, isLocalImage: Bool, userID: String) -> Blog {
        let blog = NSEntityDescription.insertNewObject(forEntityName: "Blog", into: persistentContainer.viewContext) as! Blog
        
        blog.blogTitle = blogTitle
        blog.blogContent = blogContent
        
        // test
        blog.blogImage = URL(string: blogImage)?.lastPathComponent
        
        //        blog.blogImage = blogImage
        blog.isLocalImage = NSNumber(value: isLocalImage)
        
        // user
        blog.userID = userID
        
        cleanup()
        
        return blog
    }
    
    func deleteTask(blog: Blog) {
        persistentContainer.viewContext.delete(blog)
        cleanup()
    }
    
    func fetchBlog() -> [Blog] {
        let request: NSFetchRequest<Blog> = Blog.fetchRequest()
        
        // user
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user is currently logged in.")
            return [Blog]()
        }
        
        request.predicate = NSPredicate(format: "userID == %@", userID)
        print(userID)
        
        let nameSortDescriptor = NSSortDescriptor(key: "blogTitle", ascending: true)
        request.sortDescriptors = [nameSortDescriptor]
        
        BlogFetchedResultsControllerUser = Auth.auth().currentUser!.uid
        //        if BlogFetchedResultsController == nil {
        
        if BlogFetchedResultsControllerUser == userID {
            BlogFetchedResultsController =
            NSFetchedResultsController<Blog>(fetchRequest: request,
                                             managedObjectContext: persistentContainer.viewContext,
                                             sectionNameKeyPath: nil, cacheName: nil)
            // Set this class to be the results delegate
            BlogFetchedResultsController?.delegate = self
        }
            //        do {
            //            try BlogFetchedResultsController?.performFetch()
            //        } catch {
            //            print("Fetch Request Failed: \(error)")
            //        }
            //        if let blog = BlogFetchedResultsController?.fetchedObjects {
            //            return blog
            //        }
            
            do {
                try BlogFetchedResultsController?.performFetch()
                let blogs = BlogFetchedResultsController?.fetchedObjects ?? []
                for blog in blogs {
                    print("Fetched task with userID: \(String(describing: blog.userID))")
                }
                return blogs
            } catch {
                print("Fetch Request Failed: \(error)")
            }
            return [Blog]()         
        }
    
}
