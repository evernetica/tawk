//
//  UserDetailsViewModel.swift
//  tawkApp
//
//  Created by Eugene Shapovalov on 04.03.2021.
//

import Foundation
import Combine

class UserDetailsViewModel: ObservableObject {
    
    var userName: String = ""
    var userId: Int = 0
    var noteObject: Note?
    @Published var userDetails: UserDetailsModel?
    @Published var noteTextHandle = ""
    var updateList = CurrentValueSubject<Bool, Never>(false)
    
    private var subscriptions = Set<AnyCancellable>()
    
    init(userName: String) {
        self.userName = userName
    }
    
    func getDetails() {
        NetworkManager.shared.getUserDetails(userName)
            .sink(receiveCompletion: {completion in
                if case let .failure(error) = completion {
                    debugPrint("Error get user", error)
                }
            }, receiveValue: { [weak self] userDetails in
                self?.userId = userDetails.id
                self?.userDetails = userDetails
                self?.getUserNote(userDetails.id)
                self?.changeIsOpenState(userId: userDetails.id)
            })
            .store(in: &self.subscriptions)
    }
    
    func saveNote() {
        if noteObject == nil {
            CoreDataManager.shared.saveNote(noteTextHandle, userId: Int(userId))
        } else {
            CoreDataManager.shared.updateNote(noteTextHandle, userId: Int(userId))
            changeIsOpenState(userId: Int(userId))
        }
    }
    
    func getUserNote(_ userId: Int) {
        noteObject = CoreDataManager.shared.getNote(userId)
        noteTextHandle = noteObject?.noteText ?? ""
    }
    
    func changeIsOpenState(userId: Int) {
        CoreDataManager.shared.updateUserState(true, id: userId)
        updateList.send(true)
    }
    
}
