//
//  User+CoreDataProperties.swift
//  tawkApp
//
//  Created by Eugene Shapovalov on 03.03.2021.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var id: Int32
    @NSManaged public var login: String?
    @NSManaged public var avatarUrl: String?
    @NSManaged public var isOpen: Bool
    @NSManaged public var note: Note?

}

extension User : Identifiable {

}
