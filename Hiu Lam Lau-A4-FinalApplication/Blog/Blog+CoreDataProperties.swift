//
//  Blog+CoreDataProperties.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 4/5/2023.
//
//

import Foundation
import CoreData


extension Blog {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Blog> {
        return NSFetchRequest<Blog>(entityName: "Blog")
    }

    @NSManaged public var blogTitle: String?
    @NSManaged public var blogContent: String?
    @NSManaged public var blogImage: String?
    @NSManaged public var isLocalImage: NSNumber?

}

extension Blog : Identifiable {

}
