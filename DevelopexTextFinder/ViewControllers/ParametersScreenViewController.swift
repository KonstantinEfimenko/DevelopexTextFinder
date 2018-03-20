//
//  ViewController.swift
//  DevelopexTextFinder
//
//  Created by Konstantin Efimenko on 3/18/18.
//  Copyright © 2018 Konstantin Efimenko. All rights reserved.
//

import UIKit

class ParametersScreenViewController: UIViewController {
    
    @IBOutlet weak var startSearchUrlField: UITextField!
    @IBOutlet weak var numberOfThreadsField: UITextField!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var maxUrlCountField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startButton: UIButton!
    
    let searchService = SearchService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchService.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onStartButtonPressed(_ sender: Any) {
        startButton.isEnabled = false
        searchService.startSearch(startUrl: startSearchUrlField.text!, maxThreadNumber: Int(numberOfThreadsField.text!)!, textToSearch: searchTextField.text!, urlMaxCount: Int(maxUrlCountField.text!)!)
    }

    @IBAction func onStopButtonPressed(_ sender: Any) {
        searchService.stopSearch()
    }
}

extension ParametersScreenViewController: SearchServiceDelegate {
    
    func didUpdateLinksDictionary() {
        tableView.reloadData()
    }
    
    func didFinishSearch() {
        startButton.isEnabled = true
    }
    
}

extension ParametersScreenViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchService.urls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if (cell == nil) {
            cell = UITableViewCell(style:UITableViewCellStyle.value1, reuseIdentifier:"Cell")
            cell!.textLabel?.numberOfLines = 0
        }
        let url = searchService.urls[indexPath.row]
        cell!.textLabel!.text = url
        cell!.detailTextLabel?.text = searchService.urlStatuses[url]
        return cell!
    }
    
}

