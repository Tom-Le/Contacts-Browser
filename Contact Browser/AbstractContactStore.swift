//
//  ContactStore.swift
//  Contact Browser
//
//  Created by Son Le on 9/13/16.
//  Copyright © 2016 Son Le. All rights reserved.
//

import Foundation

public struct Contact: Equatable {

    let fullName: String
    let phoneNumbers: [String]

    public static func == (left: Contact, right: Contact) -> Bool {
        return left.fullName == right.fullName
            && left.phoneNumbers == right.phoneNumbers
    }

}

public protocol AbstractContactStore {

    /**

     Enumerate through every contact whose name matches a given keyword.

     If there are no contact whose name matches the given keyword, the supplied block is
     not called.

     - Parameter keyword: An arbitrary string; supply nil to enumerate through every contact.
     - Parameter block: A block that is called for every contact whose name matches keyword.
     Return true to keep enumerating or false to stop.
     
     - Returns: true if enumeration finished with no errors, false otherwise.

     */
    func enumerateContacts(matching keyword: String?, usingBlock block: @escaping (Contact) -> Bool) -> Bool

}
