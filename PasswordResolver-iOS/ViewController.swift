//
//  ViewController.swift
//  PasswordResolver-iOS
//
//  Created by Sergey Shirnin on 19/01/2019.
//  Copyright © 2019 Sergey Shirnin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBAction func generateButtonPressed(_ sender: Any) {
        generatePasswords()
    }

    // Результирующая выборка
    var passwordsList: [String] = []
    let cifers = [
        ["!", "@", "$", "#"],
        ["(", "_", "-", ")"],
        ["a", "b", "c", "^"],
        ["d", "e", "f", "*"],
        ["g", "h", "i", "A"],
        ["j", "k", "l", "B"],
        ["m", "n", "o", "C"],
        ["p", "q", "r", "D"],
        ["s", "t", "u", "v"],
        ["w", "x", "y", "z"]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
    }

    private func resolve(input: String) -> [String] {
        guard input.count >= 1 else { return [] }
        var variants: [String] = []

        var interestedList: [[String]] = []

        for char in input {
            let index = Int(String(char))!
            interestedList.append(cifers[index])
        }

        func getVariants(symbList: [String], nextIndex: Int) -> [String] {
            guard nextIndex < interestedList.count else {
                return symbList
            }

            let variants = getVariants(symbList: interestedList[nextIndex], nextIndex: nextIndex + 1)
            var results: [String] = []
            for symb in symbList {
                for variant in variants {
                    results.append(symb+variant)
                }
            }
            return results
        }

        guard interestedList.count > 1 else { return interestedList[0] }
        variants = getVariants(symbList: interestedList[0], nextIndex: 1)
        return variants
    }

    private func generatePasswords() {
        let rawPassword = passwordTextField.text!
        let queue = DispatchQueue(label: "Resolve", qos: .background)
        activityIndicator.startAnimating()
        queue.async {
            self.passwordsList = self.resolve(input: rawPassword)
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
            }
        }
    }

}

extension ViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PasswordCell") else {
            return UITableViewCell()
        }
        cell.textLabel?.text = passwordsList[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passwordsList.count
    }

}

