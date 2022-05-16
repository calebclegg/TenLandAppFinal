//
//  Maintenance.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 24/04/2022.
//

import Foundation
import FirebaseFirestore


struct Maintenance {
    
    static var collection: CollectionReference {
        get {
            return Firestore.firestore().collection("maintenance")
    
            }

    }
    
    var id: String
    var addImage: URL
    var maintenanceType:String
    var description: String
    var dor: Date
    var da: Date
    
    init?(snapshot: DocumentSnapshot) {
        guard let data = snapshot.data() else { return nil }
        guard let availableDate = data["available_date"] as? Double else { return nil }
        guard let requestDate = data["request_date"] as? Double else { return nil }
        guard let description = data["description"] as? String else { return nil }
        guard let maintenanceType = data["maintenance_type"] as? String else { return nil }
        guard let image = data["property_maintenance"] as? String,
              let url = URL(string: image) else {
                  return nil
              }
        self.id = snapshot.documentID
        self.addImage = url
        self.maintenanceType = maintenanceType
        self.description = description
        self.dor = Date(timeIntervalSince1970: requestDate)
        self.da = Date(timeIntervalSince1970: availableDate)
    }

}
