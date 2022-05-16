//
//  Notification.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 26/4/2022.
//

import Foundation
import Firebase

struct MaintenanceNotification {
    
    static var collection: CollectionReference {
        get {
            return Firestore.firestore().collection("maintenance_notifications")
    
            }
    }
    var id: String
    var landlordId: String
    var propertyId: String
    var tenantId: String
    var isRead: Bool
    var maintenanceId: String
    var title: String
    var image: URL?
    
    init?(data: QueryDocumentSnapshot) {
        guard let landlordId = data["landlord_uid"] as? String else { return nil }
        guard let propertyId = data["property_id"] as? String else { return nil }
        guard let tenantId = data["tenant_uid"] as? String else { return nil }
        guard let isRead = data["is_read"] as? Bool else { return nil }
        guard let maintenanceId = data["maintenance_id"] as? String else { return nil }
        guard let title = data["title"] as? String else { return nil }
        self.id = data.documentID
        self.landlordId = landlordId
        self.propertyId = propertyId
        self.tenantId = tenantId
        self.isRead = isRead
        self.maintenanceId = maintenanceId
        self.title = title
        if let image = data["image"] as? String,
            let url = URL(string: image) {
            self.image = url
        }
    }
    
    init?(data: DocumentSnapshot) {
        let documentId = data.documentID
        guard let data = data.data() else { return nil }
        guard let landlordId = data["landlord_uid"] as? String else { return nil }
        guard let propertyId = data["property_id"] as? String else { return nil }
        guard let tenantId = data["tenant_uid"] as? String else { return nil }
        guard let isRead = data["is_read"] as? Bool else { return nil }
        guard let maintenanceId = data["maintenance_id"] as? String else { return nil }
        guard let title = data["title"] as? String else { return nil }
        self.landlordId = landlordId
        self.propertyId = propertyId
        self.tenantId = tenantId
        self.isRead = isRead
        self.maintenanceId = maintenanceId
        self.title = title
        self.id = documentId
        if let image = data["image"] as? String,
            let url = URL(string: image) {
            self.image = url
        }
    }
    
}
