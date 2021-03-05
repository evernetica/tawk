//
//  CoreDataManager.swift
//  tawkApp
//
//  Created by Eugene Shapovalov on 03.03.2021.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "tawkApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension CoreDataManager {
    func saveAllUsers(_ users: [UserListModel]) {
        users.forEach{saveOrUpdateUser($0)}
        saveContext()
    }

    func saveOrUpdateUser(_ user: UserListModel) {
        if !updateUser(user) {
            makeManadgedObjectUser(user)
        }
    }
    
    func updateUser(_ user: UserListModel) -> Bool {
        let fetchRequest = NSFetchRequest<User>(entityName: "User")
        
        let predicate = NSPredicate(format: "id == \(user.id)")
        fetchRequest.predicate = predicate
        
        guard let foundUser = try? context.fetch(fetchRequest).first else { return false }
        
        foundUser.avatarUrl = user.avatarURL
        foundUser.id = Int32(user.id)
        foundUser.login = user.login

        return true
    }
    
    func updateUserState(_ userState: Bool, id: Int) {
        let fetchRequest = NSFetchRequest<User>(entityName: "User")
        
        let predicate = NSPredicate(format: "id == \(id)")
        fetchRequest.predicate = predicate
        
        do {
            let foundUser = try? context.fetch(fetchRequest)
            foundUser?.first?.isOpen = userState
        }
        saveContext()
    }
    
    func updateUserNoteState(_ noteText: String, userId: Int) {
        let fetchRequest = NSFetchRequest<User>(entityName: "User")
    
        let predicate = NSPredicate(format: "id == \(userId)")
        fetchRequest.predicate = predicate
        
        do {
            let foundUser = try? context.fetch(fetchRequest)
            foundUser?.first?.note?.noteText = noteText
        }
        saveContext()
    }
    
    func deleteData(_ entityName: String) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.persistentStoreCoordinator?.execute(deleteRequest, with: context)
        } catch {

        }
    }
    
    func saveNote(_ noteText: String, userId: Int) {
        let fetchRequest = NSFetchRequest<User>(entityName: "User")
        
        let predicate = NSPredicate(format: "id == \(userId)")
        fetchRequest.predicate = predicate
        
        guard let user = try? context.fetch(fetchRequest).first else { return }
        
        let newNote = Note(context: CoreDataManager.shared.context)
        newNote.userId = Int32(userId)
        newNote.noteText = noteText
        user.note = newNote
        
        saveContext()
    }
    
    func updateNote(_ noteText: String, userId: Int) {
        let fetchRequest = NSFetchRequest<Note>(entityName: "Note")
        let fetchRequestUser = NSFetchRequest<User>(entityName: "User")
        
        let predicate = NSPredicate(format: "userId == \(userId)")
        fetchRequest.predicate = predicate
        
        let predicateId = NSPredicate(format: "id == \(userId)")
        fetchRequestUser.predicate = predicateId
        
        do {
            let foundUser = try? context.fetch(fetchRequestUser)
            let foundNote = try? context.fetch(fetchRequest)
            foundNote?.first?.noteText = noteText
            foundUser?.first?.note = foundNote?.first
        }
        saveContext()
    }
    
    func getNote(_ userId: Int) -> Note? {
        let fetchRequest = NSFetchRequest<Note>(entityName: "Note")
        
        let userId = "\(userId)"
        let predicate = NSPredicate(format: "userId == \(userId)")
        fetchRequest.predicate = predicate
        
        do {
            let notes = try context.fetch(fetchRequest)
            return notes.first
        } catch let error {
            print(error)
            return nil
        }
    }
    
    @discardableResult func makeManadgedObjectNote(_ noteText: String, userId: Int) -> NSManagedObject {
        let newNote = Note(context: context)
        newNote.noteText = noteText
        newNote.userId = Int32(userId)
        return newNote
    }
    
    @discardableResult func makeManadgedObjectUser(_ user: UserListModel) -> NSManagedObject {
        let newUser = User(context: context)
        newUser.avatarUrl = user.avatarURL
        newUser.id = Int32(user.id)
        newUser.login = user.login
        newUser.isOpen = false
        newUser.note?.noteText = ""
        return newUser
    }
}
