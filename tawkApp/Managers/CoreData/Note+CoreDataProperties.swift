//
//  Note+CoreDataProperties.swift
//  tawkApp
//
//  Created by Eugene Shapovalov on 03.03.2021.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var noteText: String?
    @NSManaged public var userId: Int32
    @NSManaged public var user: User?

}

extension Note : Identifiable {

}
