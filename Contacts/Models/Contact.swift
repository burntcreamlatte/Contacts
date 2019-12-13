//
//  Contact.swift
//  Contacts
//
//  Created by Aaron Shackelford on 12/13/19.
//  Copyright © 2019 Aaron Shackelford. All rights reserved.
//

import Foundation
import CloudKit

enum ContactStrings {
    static let recordTypeKey = "contact"
    static let nameKey = "name"
    static let phoneNumberKey = "phoneNumber"
    static let emailKey = "email"
}

class Contact {
    
    // MARK: - Properties
    var name: String
    var phoneNumber: String?
    var email: String?
    var recordID: CKRecord.ID
    //creating a CKRecord? property to be able to RETURN a record since we are checking for optional properties
    var record: CKRecord? {
        let record = CKRecord(recordType: ContactStrings.recordTypeKey, recordID: recordID)
        record.setValue(name, forKey: ContactStrings.nameKey)
        //check for present optional phone number and/or email before returning record; only sets values if able to find
        if let phoneNumber = phoneNumber {
            record.setValue(phoneNumber, forKey: ContactStrings.phoneNumberKey)
        }
        if let email = email {
            record.setValue(email, forKey: ContactStrings.emailKey)
        }
        return record
    }
    
    init(name: String, phoneNumber: String? = nil, email: String? = nil, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.name = name
        self.phoneNumber = phoneNumber
        self.email = email
        self.recordID = recordID
    }
}

// MARK: - Convenience Init
extension Contact {
    convenience init?(ckRecord: CKRecord) {
        //must have a name
        guard let name = ckRecord[ContactStrings.nameKey] as? String else {
            print("CKRecord does not contain a name."); return nil }
        let phoneNumber = ckRecord[ContactStrings.phoneNumberKey] as? String
        let email = ckRecord[ContactStrings.emailKey] as? String
        
        self.init(name: name, phoneNumber: phoneNumber, email: email, recordID: ckRecord.recordID)
    }
}

// MARK: - Equatable
extension Contact: Equatable {
    static func == (lhs: Contact, rhs: Contact) -> Bool {
        lhs.recordID == rhs.recordID
    }
}

// MARK: REVIEW
//retaining commented-out code for review questions
//easier for createContact method; only need to pass in the contact instead of creation
//extension CKRecord {
//    convenience init(contact: Contact) {
//        //the entire init'd record would have to return itself, make a property of record: CKRecord? ?
//        self.init(recordType: ContactStrings.recordTypeKey, recordID: contact.recordID)
//        self.setValue(contact.name, forKey: ContactStrings.nameKey)
//        if let phoneNumber = contact.phoneNumber {
//            self.setValue(contact.phoneNumber, forKey: ContactStrings.phoneNumberKey)
//        }
//        if let email = contact.email {
//            self.setValue(contact.email, forKey: ContactStrings.emailKey)
//        }
//    }
//}
