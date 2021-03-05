//
//  UserListViewModel.swift
//  tawkApp
//
//  Created by Eugene Shapovalov on 02.03.2021.
//

import Foundation
import Combine
import UIKit
import CoreData

final class UserListViewModel: ObservableObject {
    
    private var subscriptions = Set<AnyCancellable>()
    private var lastUserID: Int = 0
    
    var dataSource = CurrentValueSubject<[UserViewModel], Never>([UserViewModel]())
    var updateData = CurrentValueSubject<Bool, Never>(false)
    @Published var selectUserName: String = ""
    
    func observUserData() {
        let request: NSFetchRequest<User> = User.fetchRequest()

        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        ObservableCoreData(request: request,
                           context: CoreDataManager.shared.context)
            .map {$0}
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {completion in
                if case let .failure(error) = completion {
                    debugPrint("Error get user", error)
                }
            }, receiveValue: { [weak self] newUsers in
                self?.dataSource.send(newUsers.map({UserViewModel(model: $0)}))
            })
            .store(in: &self.subscriptions)
        
        getMoreUser()
    }
    
    func observNote() {
        let requestNote: NSFetchRequest<Note> = Note.fetchRequest()
        
        ObservableCoreData(request: requestNote,
                           context: CoreDataManager.shared.context)
            .map {$0}
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {completion in
                if case let .failure(error) = completion {
                    debugPrint("Error get user", error)
                }
            }, receiveValue: { [weak self] updateNote in
                self?.updateData.send(true)
            })
            .store(in: &self.subscriptions)
    }
    
    func getMoreUser() {
        lastUserID = Int(dataSource.value.last?.id ?? 0)
        NetworkManager.shared.getUserList(lastUserID)
            .sink(receiveCompletion: {completion in
                if case let .failure(error) = completion {
                    debugPrint("Error get user", error)
                }
            }, receiveValue: { users in
                CoreDataManager.shared.saveAllUsers(users)
            })
            .store(in: &self.subscriptions)
    }
}
