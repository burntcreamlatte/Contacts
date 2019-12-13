//
//  ContactController.swift
//  Contacts
//
//  Created by Aaron Shackelford on 12/13/19.
//  Copyright © 2019 Aaron Shackelford. All rights reserved.
//

import Foundation
import CloudKit

class ContactController {
    //singleton
    static let shared = ContactController()
    //private cloud DB
    let privateDB = CKContainer.default().privateCloudDatabase
    //-local- SOT
    var contacts = [Contact]()
    
    // MARK: - CRUD Methods
    
    //create
    func addContact(name: String, phoneNumber: String?, email: String?, completion: @escaping (Bool) -> Void) {
        let contact = Contact(name: name, phoneNumber: phoneNumber, email: email)
        
        //using our CKRecord? for our optional checks
        guard let record = contact.record else {
            print("ERROR converting Contact to CKRecord."); return
        }
        //attempt to save record passed in, then error handle
        privateDB.save(record) { (record, error) in
            //check for error
            if let error = error {
                print("ERROR in \(#function) : \(error), \n---\n \(error.localizedDescription)")
                completion(false); return
            }
            //confirm record exists
            guard let record = record else {
                print("ERROR in retrieving saved record. Confirm a record has already been created.")
                completion(false); return
            }
            //confirm contact exists from converted CKRecord
            guard let contact = Contact(ckRecord: record) else {
                print("ERROR converting CKRecord to Contact.")
                completion(false); return
            }
            print("Adding Contact to local Source of Truth...")
            self.contacts.insert(contact, at: 0)
            completion(true)
            print("Contact successfully added.")
        }
    }
    
    //read
    func fetchAllContacts(completion: @escaping (Bool) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: ContactStrings.recordTypeKey, predicate: predicate)
        
        privateDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("ERROR in \(#function) : \(error), \n---\n \(error.localizedDescription)")
                completion(false); return
            }
            guard let records = records else {
                print("ERROR fetching records. Confirm array is not nil.")
                completion(false); return
            }
            //for-loop substitute, adding each found record into sortedContacts array to then add to SOT
            //also sorts our contacts alphabetically with .sorted
            let sortedContacts = records.compactMap({ Contact(ckRecord: $0) }).sorted(by: { $0.name < $1.name })
            self.contacts = sortedContacts
            completion(true)
        }
    }
    
    //update
    func updateContact(contact: Contact, completion: @escaping (Bool) -> Void) {
        //MARK: REVIEW
        //in hindsight there must be a better way to check for optionals in CKRecord
        guard let record = contact.record else {
            print("ERROR converting Contact to CKRecord.")
            completion(false); return
        }
        
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { (records, _, error) in
            if let error = error {
                print("ERROR in \(#function) : \(error), \n---\n \(error.localizedDescription)")
                completion(false); return
            }
            //allows us to verify the array has a non-nil value
            guard let confirmRecord = records?.first else {
                print("ERROR in updating contact record. Array of records is nil.")
                completion(false); return
            }
            //allows us to confirm record we are changing is correct
            guard contact.recordID == confirmRecord.recordID else {
                print("ERROR updating contact record. Record IDs do not match.")
                completion(false); return
            }
            completion(true)
        }
        privateDB.add(operation)
    }
    
    // MARK: - Black Diamond: Delete
    //delete
    func deleteContact(contact: Contact, completion: @escaping (Bool) -> Void) {
        privateDB.delete(withRecordID: contact.recordID) { (record, error) in
            if let error = error {
                print("ERROR in \(#function) : \(error), \n---\n \(error.localizedDescription)")
                print("ERROR in deletion of contact.")
                completion(false); return
            }
            completion(true)
            print("Successfully deleted contact remotely.")
        }
    }
}
