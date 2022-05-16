//
//  PendingRequestsModel.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 1/5/2022.
//
//
import Foundation
import Firebase

class PendingRequests {
    
    static var collection: CollectionReference {
        get {
            return Firestore.firestore().collection("pending_requests")
        }
    }
    
    var id: String
    var tenantId: String
    var landlordId: String
    var propertyId: String
    var isAccepted: Bool?
    
    init?(snapshot: DocumentSnapshot) {
        guard let data = snapshot.data() else { return nil }
        guard let tenantId = data["tenant_id"] as? String else { return nil }
        guard let landlordId = data["landlord_id"] as? String else { return nil }
        guard let propertyId = data["property_id"] as? String else { return nil }
        self.id = snapshot.documentID
        self.tenantId = tenantId
        self.isAccepted = data["is_accepted"] as? Bool
        self.landlordId = landlordId
        self.propertyId = propertyId
    }
    
    init?(snapshot: QueryDocumentSnapshot) {
        let data = snapshot.data()
        guard let tenantId = data["tenant_id"] as? String else { return nil }
        guard let landlordId = data["landlord_id"] as? String else { return nil }
        guard let propertyId = data["property_id"] as? String else { return nil }
        self.id = snapshot.documentID
        self.tenantId = tenantId
        self.isAccepted = data["is_accepted"] as? Bool
        self.landlordId = landlordId
        self.propertyId = propertyId
    }
    
}
