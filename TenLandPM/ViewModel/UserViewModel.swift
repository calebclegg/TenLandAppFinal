//
//  UserViewModel.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 23/02/2022.
//
//
import Foundation
import Firebase

final class UsersViewModel: ObservableObject {
    @Published var users: [Users] = []
    
    init(){
        
        fetchUsers()
    }
    
    func fetchUsers() {
        let db = Firestore.firestore()
        
        db.collection("users").getDocuments() { (querySnapshot, error) in
            if let error = error{
                print("Error getting data: \(error)")
            }else{
                if let querySnapshot = querySnapshot {
                    for document in querySnapshot.documents {
                        let data = document.data()
                        
                        let id = data["id"] as? String ?? ""
                        let name = data["name"] as? String ?? ""
                        let email = data["email"] as? String ?? ""
                        let phone = data["phone"] as? String ?? ""
                        let userType = data["usertype"] as? String ?? ""
                        
                        let users = Users(id: id, name: name, email: email, phoone: phone, userType: userType)
                        
                        self.users.append(users)
                        
                    }
                            
                }
                
            }
            
        }
        
    }
    
    
}
