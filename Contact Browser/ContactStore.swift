//
//  ContactStore.swift
//  Contact Browser
//
//  Created by Son Le on 9/13/16.
//  Copyright © 2016 Son Le. All rights reserved.
//

import Foundation
import Contacts

/// Provide access to user's contacts.
public struct ContactStore: AbstractContactStore {

    /**

     Enumerate through every contact whose name matches a given keyword.

     If there are no contact whose name matches the given keyword or if we do not have
     permission to access user's contacts, the supplied block is not called.

     - Parameter keyword: An arbitrary string; supply nil to enumerate through every contact.
     - Parameter block: A block that is called for every contact whose name matches keyword.
     Return true to keep enumerating or false to stop.

     - Returns: true if enumeration finished with no errors, false otherwise.

     */

    public func enumerateContacts(matching keyword: String?, usingBlock block: @escaping (Contact) -> Bool) -> Bool {
        if CNContactStore.authorizationStatus(for: .contacts) != .authorized {
            return false
        }

        let request = CNContactFetchRequest(keysToFetch: [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                                                          CNContactPhoneNumbersKey as CNKeyDescriptor])
        request.mutableObjects = false
        request.unifyResults = true
        request.sortOrder = .userDefault
        if let keyword = keyword {
            request.predicate = CNContact.predicateForContacts(matchingName: keyword)
        }

        do {
            let store = CNContactStore()
            try store.enumerateContacts(with: request) { (contact, stop) in
                guard let fullName = CNContactFormatter.string(from: contact, style: .fullName) else {
                    return
                }

                var phoneNumbers = [String]()
                for no in contact.phoneNumbers {
                    phoneNumbers.append(no.value.stringValue)
                }
                if phoneNumbers.count == 0 { return }

                let shouldContinue = block(Contact(fullName: fullName, phoneNumbers: phoneNumbers))

                stop.pointee = ObjCBool(!shouldContinue)
            }
        }
        catch {
            return false
        }
        
        return true
    }
    
}
