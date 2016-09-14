//
//  ContactsViewModelTests.swift
//  Contact Browser
//
//  Created by Son Le on 9/13/16.
//  Copyright © 2016 Son Le. All rights reserved.
//

import XCTest
@testable import Contact_Browser

private struct ArrayContactStore: AbstractContactStore {

    // Array of contacts
    var contacts: [Contact]

    func enumerateContacts(matching keyword: String?, usingBlock block: @escaping (Contact) -> Bool) -> Bool {
        // Filter contacts with given keyword.
        var filteredContacts: [Contact]
        if let keyword = keyword {
            filteredContacts = contacts.filter { $0.fullName.contains(keyword) }
        }
        else {
            filteredContacts = contacts
        }

        // Enumerate through every contact in filtered list.
        for contact in filteredContacts {
            let shouldContinue = block(contact)
            if !shouldContinue { break }
        }

        return true
    }

}

private struct AlwaysFailContactStore: AbstractContactStore {

    func enumerateContacts(matching keyword: String?, usingBlock block: @escaping (Contact) -> Bool) -> Bool {
        return false
    }

}

class ContactsViewModelTests: XCTestCase {

    // Test data.
    private let dummyStore = ArrayContactStore(contacts: [
        Contact(fullName: "Amanda Hill", phoneNumbers: ["(617)334-0584"]),
        Contact(fullName: "Andrea Owens", phoneNumbers: ["(638) 382-3829", "(372) 382-2719"]),
        Contact(fullName: "Billy Alvarez", phoneNumbers: ["389-291-4891"]),
        Contact(fullName: "Cynthia Salazar", phoneNumbers: ["(302) 281-2393"]),
        Contact(fullName: "Peter White", phoneNumbers: ["930-291-3930", "(392) 348-2891"]),
        Contact(fullName: "Sandra Hart", phoneNumbers: ["183-393-4291"]),
        Contact(fullName: "Stephanie Sayoush", phoneNumbers: ["392-173-2018", "839-103-4812"])
    ])

    private let alwaysFailStore = AlwaysFailContactStore()

    /// Test getting section header titles without setting a filter keyword.
    func testGettingNumberOfSectionsWithoutFilterKeyword() {
        let viewModel = ContactsViewModel(store: dummyStore)
        XCTAssertTrue(viewModel.sectionHeaders == ["A", "B", "C", "P", "S"])
    }

    /// Test getting section header titles with a filter keyword set.
    func testGettingNumberOfSectionsWithFilterKeyword() {
        let viewModel = ContactsViewModel(store: dummyStore, filter: "Amanda")
        XCTAssertTrue(viewModel.sectionHeaders == ["A"])

        viewModel.filter = "S"
        XCTAssertTrue(viewModel.sectionHeaders == ["C", "S"])
    }

    /// Test working with a contact store that fails to retrieve contacts.
    func testWorkingWithContactStoreThatFails() {
        let viewModel = ContactsViewModel(store: alwaysFailStore, filter: nil)

        XCTAssertTrue(viewModel.sectionHeaders == [])
        XCTAssertTrue(viewModel.numberOfContactsIn(section: 0) == 0)
        XCTAssertTrue(viewModel.contactAt(index: 0, section: 0) == nil)
    }

    /// Test getting number of contacts within a section, without setting a filter keyword.
    func testGettingNumberOfContactsWithoutFilterKeyword() {
        let viewModel = ContactsViewModel(store: dummyStore)

        XCTAssertTrue(viewModel.numberOfContactsIn(section: 0) == 2)
        XCTAssertTrue(viewModel.numberOfContactsIn(section: 1) == 1)
        XCTAssertTrue(viewModel.numberOfContactsIn(section: 10) == 0)
    }

    /// Test getting contacts within a section, without setting a filter keyword.
    func testGettingContactsWithoutFilterKeyword() {
        let viewModel = ContactsViewModel(store: dummyStore)

        XCTAssertTrue(viewModel.contactAt(index: 0, section: 0)
            == Contact(fullName: "Amanda Hill", phoneNumbers: ["(617)334-0584"]))
        XCTAssertTrue(viewModel.contactAt(index: 1, section: 0)
            == Contact(fullName: "Andrea Owens", phoneNumbers: ["(638) 382-3829", "(372) 382-2719"]))
        XCTAssertTrue(viewModel.contactAt(index: 2, section: 0) == nil)
        XCTAssertTrue(viewModel.contactAt(index: 0, section: 8) == nil)
    }

    /// Test getting contacts withit a section, with a filter keyword set.
    func testGettingContactsWithFilterKeyword() {
        let viewModel = ContactsViewModel(store: dummyStore, filter: "S")

        XCTAssertTrue(viewModel.contactAt(index: 0, section: 0)
            == Contact(fullName: "Cynthia Salazar", phoneNumbers: ["(302) 281-2393"]))
        XCTAssertTrue(viewModel.contactAt(index: 0, section: 1)
            == Contact(fullName: "Sandra Hart", phoneNumbers: ["183-393-4291"]))
        XCTAssertTrue(viewModel.contactAt(index: 1, section: 1)
            == Contact(fullName: "Stephanie Sayoush", phoneNumbers: ["392-173-2018", "839-103-4812"]))
    }
    
}
