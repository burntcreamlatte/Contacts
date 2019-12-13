//
//  ContactDetailViewController.swift
//  Contacts
//
//  Created by Aaron Shackelford on 12/13/19.
//  Copyright © 2019 Aaron Shackelford. All rights reserved.
//

import UIKit

class ContactDetailViewController: UIViewController {
    
    // MARK: - Properties
    //landing pad
    var contact: Contact? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - Actions
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let name = nameTextField.text, !name.isEmpty else { return }
        //do not need guarding against these fields as are optional
        let phoneNumber = phoneNumberTextField.text
        let email = emailTextField.text
        
        //if contact exists
        if let contact = contact {
            contact.name = name
            contact.phoneNumber = phoneNumber
            contact.email = email
            ContactController.shared.updateContact(contact: contact) { (success) in
                if success {
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        } else {
            //if contact does NOT exist
            ContactController.shared.addContact(name: name, phoneNumber: phoneNumber, email: email) { (success) in
                if success {
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    func updateViews() {
        loadViewIfNeeded()
        nameTextField.text = contact?.name
        phoneNumberTextField.text = contact?.phoneNumber
        emailTextField.text = contact?.email
    }
}
