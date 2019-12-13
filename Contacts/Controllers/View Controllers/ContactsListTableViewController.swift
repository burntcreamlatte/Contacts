//
//  ContactsListTableViewController.swift
//  Contacts
//
//  Created by Aaron Shackelford on 12/13/19.
//  Copyright © 2019 Aaron Shackelford. All rights reserved.
//

import UIKit

class ContactsListTableViewController: UITableViewController {

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ContactController.shared.fetchAllContacts { (success) in
            if success {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    //MARK: TODO
    //viewWillAppear reloadData if does not populate properly

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ContactController.shared.contacts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)
        let contact = ContactController.shared.contacts[indexPath.row]
        cell.textLabel?.text = contact.name

        return cell
    }

    //MARK: - Black Diamond: Delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toContactDetailVC" {
            guard let indexPath = tableView.indexPathForSelectedRow,
                let destinationVC = segue.destination as? ContactDetailViewController else { return }
            
            destinationVC.contact = ContactController.shared.contacts[indexPath.row]
        }
    }

}