//
//  BlogCoreDataController.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 5/5/2023.
//

import UIKit
import CoreData

class BlogCoreDataController: NSObject, DatabaseProtocolBlog,  NSFetchedResultsControllerDelegate{

    

    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer: NSPersistentContainer
    var BlogFetchedResultsController: NSFetchedResultsController<Blog>?

    
    
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
    
    func addBlog(blogTitle: String, blogContent: String, blogImage: String, isLocalImage: Bool) -> Blog {
        let blog = NSEntityDescription.insertNewObject(forEntityName: "Blog", into: persistentContainer.viewContext) as! Blog
        
        blog.blogTitle = blogTitle
        blog.blogContent = blogContent
        blog.blogImage = blogImage
        blog.isLocalImage = NSNumber(value: isLocalImage)
        
        cleanup()
        
        return blog
    }
    
    func deleteTask(blog: Blog) {
        persistentContainer.viewContext.delete(blog)
        cleanup()
    }
    
    func fetchBlog() -> [Blog] {
        let request: NSFetchRequest<Blog> = Blog.fetchRequest()
        let nameSortDescriptor = NSSortDescriptor(key: "blogTitle", ascending: true)
        request.sortDescriptors = [nameSortDescriptor]
        if BlogFetchedResultsController == nil {
            
            BlogFetchedResultsController =
            NSFetchedResultsController<Blog>(fetchRequest: request,
                                             managedObjectContext: persistentContainer.viewContext,
                                             sectionNameKeyPath: nil, cacheName: nil)
            // Set this class to be the results delegate
            BlogFetchedResultsController?.delegate = self
            
        }
        
        do {
            try BlogFetchedResultsController?.performFetch()
        } catch {
            print("Fetch Request Failed: \(error)")
        }
        if let blog = BlogFetchedResultsController?.fetchedObjects {
            return blog
        }
        return [Blog]()
    }
    

}
