//
//  User.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 03/03/2022.
//
//
import Foundation
import FirebaseFirestore

struct UserModel {
    
    static var collection: CollectionReference {
        get {
            return Firestore.firestore().collection("users")
        }
    }
    var id: String
    var name: String
    var phone: String?
    var email: String
    var userType: UserType
    var profileImage: URL?
    var headerImage: URL?
    var propertyId: String?
    
    init?(snapshot: DocumentSnapshot) {
        guard let data = snapshot.data() else { return nil }
        guard let id = data["uid"] as? String else { return nil }
        guard let email = data["email"] as? String else { return nil }
        guard let userType = data["user_type"] as? String else { return nil }
        self.id = id
        self.email = email
        self.name = data["name"] as? String ?? "Anonymous"
        self.phone = data["phone"] as? String
        self.userType = userType == UserType.landlord.rawValue ? UserType.landlord : UserType.tenant
       
        if let profileImage = data[ImageModel.profile.firebaseEntryName()] as? String,
            let url = URL(string: profileImage) {
            self.profileImage = url
        }
        if let headerImage = data[ImageModel.header.firebaseEntryName()] as? String,
            let url = URL(string: headerImage) {
            self.headerImage = url
        }
        if let propertyId = data["property_id"] as? String {
            self.propertyId = propertyId
        }
    }
    
}
