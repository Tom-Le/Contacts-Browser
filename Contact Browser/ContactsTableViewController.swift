//
//  ViewController.swift
//  Contact Browser
//
//  Created by Son Le on 9/12/16.
//  Copyright © 2016 Son Le. All rights reserved.
//

import UIKit
import Contacts

class ContactsTableViewController: UITableViewController, UISearchResultsUpdating {

    private let store = ContactStore()
    private var viewModel: ContactsViewModel?

    private var searchController: UISearchController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Request permission to read user's contacts if necessary.
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        switch authorizationStatus {
        case .notDetermined, .denied:
            CNContactStore().requestAccess(for: .contacts) { accessGranted, error in
                if accessGranted {
                    DispatchQueue.main.async {
                        self.createViewModel()
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self.displayAlert(
                            message: "Please give us permission to access your contacts.",
                            actionTitle: "Open Privacy Settings",
                            handler: { action in
                                self.openSettingsApp()
                            }
                        )
                    }
                }
            }

        case .restricted:
            displayAlert(message: "Unfortunately, we are not able to access your contacts.",
                         actionTitle: "OK")

        case .authorized:
            createViewModel()
        }

        searchController = UISearchController(searchResultsController: nil)
        searchController?.searchResultsUpdater = self
        searchController?.hidesNavigationBarDuringPresentation = true
        searchController?.dimsBackgroundDuringPresentation = false

        self.tableView.tableHeaderView = searchController?.searchBar
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)

        if let contact = viewModel?.contactAt(index: indexPath.row, section: indexPath.section) {
            cell.textLabel?.text = contact.fullName
            cell.detailTextLabel?.text = contact.phoneNumbers[0]
        }

        return cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.sectionHeaders.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfContactsIn(section: section) ?? 0
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return viewModel?.sectionHeaders
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel?.sectionHeaders[section]
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let contact = viewModel?.contactAt(index: indexPath.row, section: indexPath.section) {
            guard let contactDetailVC = self.storyboard?
                .instantiateViewController(withIdentifier: "ContactDetailPopover") as? ContactDetailViewController
                else { return }

            contactDetailVC.name = contact.fullName
            contactDetailVC.phoneNumbers = contact.phoneNumbers
            contactDetailVC.contactsViewController = self
            contactDetailVC.modalPresentationStyle = .popover

            let contactPopoverPresentationController = contactDetailVC.popoverPresentationController
            contactPopoverPresentationController?.delegate = contactDetailVC
            contactPopoverPresentationController?.permittedArrowDirections = [.up, .down]
            if let cell = tableView.cellForRow(at: indexPath) {
                contactPopoverPresentationController?.sourceView = cell
                contactPopoverPresentationController?.sourceRect = cell.bounds
            }

            navigationController?.visibleViewController?.present(contactDetailVC, animated: true)
        }
    }

    // MARK: - UISearchResultsUpdating

    func updateSearchResults(for searchController: UISearchController) {
        let hasNoSearchTerm = searchController.searchBar.text?.isEmpty ?? true
        viewModel?.filter = hasNoSearchTerm ? nil : searchController.searchBar.text

        tableView.reloadData()
    }

    // MARK: - Transitioning between self's view and contact detail popover's.
    func contactDetailPopoverDidDisappear() {
        if let selectedRowIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRowIndexPath, animated: true)
        }
    }

    // MARK: - Helpers

    private func displayAlert(message: String, actionTitle: String, handler: ((UIAlertAction) -> Void)? = nil) {
        guard let appTitle = Bundle.main.infoDictionary![kCFBundleNameKey as String] as? String else {
            return
        }

        let alertController = UIAlertController(title: appTitle, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: actionTitle, style: .default, handler: handler))

        navigationController?.visibleViewController?.present(alertController, animated: true)
    }

    private func createViewModel() {
        viewModel = ContactsViewModel(store: store)
        tableView.reloadData()
    }

    private func openSettingsApp() {
        if let url = URL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

}
