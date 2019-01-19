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
        let startTime = Date()
        guard input.count >= 1 else { return [] }
        var variants: [String] = []

        var interestedList: [[String]] = []

        for char in input {
            let index = Int(String(char))!
            interestedList.append(cifers[index])
        }

        func getVariants(symbList: [String], nextIndex: Int, index: Int? = nil) -> [String] {
            guard nextIndex < interestedList.count else {
                return symbList
            }

            let variants = getVariants(symbList: interestedList[nextIndex], nextIndex: nextIndex + 1)
            var results: [String] = []
            if let index = index {
                for variant in variants {
                    results.append(symbList[index]+variant)
                }
            } else {
                for symb in symbList {
                    for variant in variants {
                        results.append(symb+variant)
                    }
                }
            }

            return results
        }

        guard interestedList.count > 1 else { return interestedList[0] }

        let queueA = DispatchQueue(label: "qA", qos: .background)
        let queueB = DispatchQueue(label: "qB", qos: .background)
        let queueC = DispatchQueue(label: "qC", qos: .background)
        let queueD = DispatchQueue(label: "qD", qos: .background)

        let groupA = DispatchGroup()
        let groupB = DispatchGroup()
        let groupC = DispatchGroup()
        let groupD = DispatchGroup()

        var resultsA: [String] = []
        var resultsB: [String] = []
        var resultsC: [String] = []
        var resultsD: [String] = []

        groupA.enter()
        groupB.enter()
        groupC.enter()
        groupD.enter()

        queueA.async {
            resultsA = getVariants(symbList: interestedList[0], nextIndex: 1, index: 0)
            groupA.leave()
        }
        queueB.async {
            resultsB = getVariants(symbList: interestedList[0], nextIndex: 1, index: 1)
            groupB.leave()
        }
        queueC.async {
            resultsC = getVariants(symbList: interestedList[0], nextIndex: 1, index: 2)
            groupC.leave()
        }
        queueD.async {
            resultsD = getVariants(symbList: interestedList[0], nextIndex: 1, index: 3)
            groupD.leave()
        }

        groupA.wait()
        groupB.wait()
        groupC.wait()
        groupD.wait()

//        variants = getVariants(symbList: interestedList[0], nextIndex: 1, start: 0, end: 1)
        let endTime = Date()
        DispatchQueue.main.async {
            let ac = UIAlertController(title: "Время выполнения", message: "Elapsed: \(endTime.timeIntervalSince(startTime))", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(ac, animated: true, completion: nil)
        }
        return resultsA + resultsB + resultsC + resultsD
    }

    private func generatePasswords() {
        passwordsList = []
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

