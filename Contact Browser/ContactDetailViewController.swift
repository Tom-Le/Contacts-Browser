//
//  ContactDetailViewController.swift
//  Contact Browser
//
//  Created by Son Le on 9/15/16.
//  Copyright © 2016 Son Le. All rights reserved.
//

import UIKit

class ContactDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var phoneNumbersTableView: UITableView!

    var contactsViewController: ContactsTableViewController?

    var name: String?
    var phoneNumbers: [String]?

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        preferredContentSize = phoneNumbersTableView.contentSize
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "phoneNumberCell", for: indexPath)

        cell.textLabel?.text = "📞 " + (phoneNumbers?[indexPath.row] ?? "")

        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return phoneNumbers != nil ? 1 : 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return phoneNumbers?.count ?? 0
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let name = name else { return }
        guard let phoneNumber = phoneNumbers?[indexPath.row] else { return }

        let title = "Call \(name)"
        let message = "Would you like to call \(name) at number: \(phoneNumber) ?"
        let dialNumberAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let dialAction = UIAlertAction(title: "Yes", style: .default) { action in
            DispatchQueue.main.async {
                self.callNumber(number: phoneNumber)
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            DispatchQueue.main.async {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }

        dialNumberAlertController.addAction(dialAction)
        dialNumberAlertController.addAction(cancelAction)

        present(dialNumberAlertController, animated: true)
    }

    // MARK: - UIPopoverPresentationControllerDelegate

    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        contactsViewController?.contactDetailPopoverDidDisappear()
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    // MARK: - Helpers

    private func callNumber(number: String) {
        let allowedCharacters = Set("1234567890+".characters)
        let trimmedPhoneNumber = String(number.characters.filter { allowedCharacters.contains($0) })

        if let url = URL(string: "tel://\(trimmedPhoneNumber)") {
            UIApplication.shared.open(url)
        }
    }

}
