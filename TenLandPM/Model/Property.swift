//
//  Property.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 6/4/2022.
//
//
import Foundation
import FirebaseFirestore

struct Property {
    
    static var collection: CollectionReference {
        get {
            return Firestore.firestore().collection("properties")
        }
    }
    
    var id: String
    var addressLine1: String
    var numberOfBeds: Int
    var numberOfLivingRooms: Int
    var numberOfBathrooms: Int
    var leaseType: LeaseType
    var paymentDate: PaymentDate
    var endDate: Date
    var startDate: Date
    var propertyImage: URL?
    var ownerId: String
    var tenantId: String?
    var rentAmount: Int
    
    init?(data: QueryDocumentSnapshot) {
        guard let ownerId = data["owner_uid"] as? String else { return nil }
        guard let addressLine1 = data["addressLine1"] as? String else { return nil }
        guard let numberOfBeds = data["numberOfBeds"] as? Int else { return nil }
        guard let numberOfLivingRooms = data["numberOfLivingRooms"] as? Int else { return nil }
        guard let numberOfBathrooms = data["numberOfBathrooms"] as? Int else { return nil }
        guard let rawLeaseType = data["leaseType"] as? Int else { return nil }
        guard let leaseType = LeaseType.init(rawValue: rawLeaseType) else { return nil }
        guard let rawPaymentDate = data["paymentDate"] as? Int else { return nil }
        guard let paymentDate = PaymentDate.init(rawValue: rawPaymentDate) else { return nil }
        guard let rentAmount = data["rentAmount"] as? Int else { return nil }
        guard let endDateSinceEpoch = data["endDate"] as? Double else { return nil }
        let endDate = Date(timeIntervalSince1970: endDateSinceEpoch)
        guard let startDateSinceEpoch = data["startDate"] as? Double else { return nil }
        let startDate = Date(timeIntervalSince1970: startDateSinceEpoch)
        
        self.id = data.documentID
        self.addressLine1 = addressLine1
        self.numberOfBeds = numberOfBeds
        self.numberOfLivingRooms = numberOfLivingRooms
        self.numberOfBathrooms = numberOfBeds
        self.leaseType = leaseType
        self.paymentDate = paymentDate
        self.numberOfBathrooms = numberOfBathrooms
        self.startDate = startDate
        self.endDate = endDate
        self.ownerId = ownerId
        self.rentAmount = rentAmount
        self.tenantId = data["tenant_uid"] as? String
        if let propertyImage = data[ImageModel.property.firebaseEntryName()] as? String,
            let url = URL(string: propertyImage) {
            self.propertyImage = url
        }
    }
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        guard let ownerId = data["owner_uid"] as? String else { return nil }
        guard let addressLine1 = data["addressLine1"] as? String else { return nil }
        guard let numberOfBeds = data["numberOfBeds"] as? Int else { return nil }
        guard let numberOfLivingRooms = data["numberOfLivingRooms"] as? Int else { return nil }
        guard let numberOfBathrooms = data["numberOfBathrooms"] as? Int else { return nil }
        guard let rawLeaseType = data["leaseType"] as? Int else { return nil }
        guard let leaseType = LeaseType.init(rawValue: rawLeaseType) else { return nil }
        guard let rawPaymentDate = data["paymentDate"] as? Int else { return nil }
        guard let paymentDate = PaymentDate.init(rawValue: rawPaymentDate) else { return nil }
        guard let rentAmount = data["rentAmount"] as? Int else { return nil }
        guard let endDateSinceEpoch = data["endDate"] as? Double else { return nil }
        let endDate = Date(timeIntervalSince1970: endDateSinceEpoch)
        guard let startDateSinceEpoch = data["startDate"] as? Double else { return nil }
        let startDate = Date(timeIntervalSince1970: startDateSinceEpoch)
        
        self.id = document.documentID
        self.addressLine1 = addressLine1
        self.numberOfBeds = numberOfBeds
        self.numberOfLivingRooms = numberOfLivingRooms
        self.numberOfBathrooms = numberOfBeds
        self.leaseType = leaseType
        self.paymentDate = paymentDate
        self.numberOfBathrooms = numberOfBathrooms
        self.startDate = startDate
        self.endDate = endDate
        self.ownerId = ownerId
        self.rentAmount = rentAmount
        self.tenantId = data["tenant_uid"] as? String
        if let propertyImage = data[ImageModel.property.firebaseEntryName()] as? String,
            let url = URL(string: propertyImage) {
            self.propertyImage = url
        }
    }
    
}
