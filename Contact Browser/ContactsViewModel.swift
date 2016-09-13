//
//  ContactsViewModel.swift
//  Contact Browser
//
//  Created by Son Le on 9/13/16.
//  Copyright © 2016 Son Le. All rights reserved.
//

import Foundation

public final class ContactsViewModel {

    // Contacts store.
    private let store: AbstractContactStore

    // Dictionary of contacts. Contact whose names start with the same letter are grouped
    // under the same key.
    private var contacts: [String : [Contact]]?

    // Filter keyword.
    public var filter: String? {
        didSet {
            populateContacts()
        }
    }

    /**
     
     Initialize a view model with the given contacts store and filter keyword.
     
     - Parameter store: A contact store.
     - Parameter filter: If not nil, view model will only process contacts from contact
     store whose names contain this string.

     */
    public required init(store: AbstractContactStore, filter: String?) {
        self.store = store
        self.filter = filter

        populateContacts()
    }

    /**
     
     Initialize a view model with the given contacts store and no filter keyword.
     
     - Parameter store: A contact store.

     */
    public convenience init(store: AbstractContactStore) {
        self.init(store: store, filter: nil)
    }

    /// Section headers.
    public var sectionHeaders: [String] {
        return contacts?.keys.sorted() ?? []
    }

    /**
     
     Get the number of contacts in a section.
     
     - Parameter section: An integer specifying a section in `self.sectionHeaders`.
     
     - Returns: Number of contacts.
 
     */
    public func numberOfContactsIn(section: Int) -> Int {
        if section < 0 || section >= sectionHeaders.count { return 0 }
        let header = sectionHeaders[section]
        return contacts?[header]?.count ?? 0
    }

    /**
     
     Get a contact.
     
     - Parameter index: An integer specifying the contact's location within the specified section.
     - Parameter section: An integer specifying a section in `self.sectionHeaders`.
     
     - Returns: A contact, or `nil` if no contact is found.

     */
    public func contactAt(index: Int, section: Int) -> Contact? {
        // Get section header.
        if section < 0 || section >= sectionHeaders.count { return nil }
        let header = sectionHeaders[section]

        // Get contacts at specified section.
        guard let contactsAtSection = contacts?[header] else { return nil }

        // Get contact at specified index.
        if index < 0 || index >= contactsAtSection.count { return nil }
        return contactsAtSection[index]
    }

    // MARK: - Helpers

    /// Populate contacts dictionary.
    func populateContacts() {
        // Create empty contacts dictionary.
        var results = [String : [Contact]]()

        let success = store.enumerateContacts(matching: filter) {
            // Get first letter of contact's full name.
            let lettersInName = $0.fullName.characters
            let firstLetter = String(lettersInName[lettersInName.startIndex])

            // Add contact to dictionary.
            if results[firstLetter] != nil {
                results[firstLetter]!.append($0)
            }
            else {
                results[firstLetter] = [$0]
            }

            // Return true to keep enumerating.
            return true
        }

        if !success {
            contacts = nil
        }
        else {
            contacts = results
        }
    }

}
