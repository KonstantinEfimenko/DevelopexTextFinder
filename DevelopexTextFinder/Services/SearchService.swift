//
//  SearchService.swift
//  DevelopexTextFinder
//
//  Created by Konstantin Efimenko on 3/13/18.
//  Copyright © 2018 Konstantin Efimenko. All rights reserved.
//

import UIKit

protocol SearchServiceDelegate: NSObjectProtocol {
    
    func didUpdateLinksDictionary()
    
    func didFinishSearch()
    
}

class SearchService {
    
    weak var delegate: SearchServiceDelegate?
    var urls: [String] = [String]()
    var urlStatuses: [String: String] = [String: String]()
    private var stop: Bool = false
    private var maxThreadNumber: Int = 0
    private var urlMaxCount: Int = 0
    private var indexOfUrlToSearch: Int = 0
    private var textToSearch: String = ""
    private lazy var session: URLSession = {
        return URLSession(configuration: URLSessionConfiguration.default)
    }();
    
    func startSearch(startUrl: String, maxThreadNumber: Int, textToSearch: String, urlMaxCount: Int) {
        
        self.urlMaxCount = urlMaxCount
        self.textToSearch = textToSearch.lowercased()
        self.maxThreadNumber = maxThreadNumber
        indexOfUrlToSearch = 0
        urls.removeAll()
        urlStatuses.removeAll()
        search(in: startUrl)
        
    }
    
    func stopSearch() {
        urlMaxCount = 0
        delegate?.didFinishSearch()
    }
    
    private func search(in url: String) {
        
        print(url)
        //check if we reach max number of links
        if indexOfUrlToSearch > urlMaxCount {
            return
        }
        //add url into list for loading if it not exist in list and number of links less then maximum
        if urlStatuses[url] == nil && urls.count < urlMaxCount && url != "" {
            urls.append(url)
            urlStatuses[url] = "loading"
            delegate?.didUpdateLinksDictionary()
        }
        //launch as much threads as we can
        while urls.count >= indexOfUrlToSearch + 1 && maxThreadNumber > 0 {
            let urlString = urls[indexOfUrlToSearch]
            guard let urlAddress = URL(string: urlString) else {
                indexOfUrlToSearch += 1
                continue
            }
            //decrease number of threads available
            maxThreadNumber -= 1
            //and increase next link index in array
            indexOfUrlToSearch += 1
            
            //launch search by first Url
            DispatchQueue.global().async {
                let localUrlString = urlString
                var urlRequest = URLRequest(url: urlAddress)
                urlRequest.timeoutInterval = 10
                let task = self.session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
                    
                    if let data = data,
                        let dataText = String(data: data, encoding: .utf8)?.lowercased() {
                        
                        DispatchQueue.main.async { [weak self] in
                            //getting search text on page
                            guard let strongSelf = self else { return }
                            
                            if error != nil {
                                strongSelf.urlStatuses[localUrlString] = error.debugDescription
                            } else if dataText.contains(strongSelf.textToSearch) {
                                strongSelf.urlStatuses[localUrlString] = "found"
                            } else {
                                strongSelf.urlStatuses[localUrlString] = "not found"
                            }
                            strongSelf.delegate?.didUpdateLinksDictionary()
                            //increase max thread number
                            strongSelf.maxThreadNumber += 1
                            //get all links on page
                            strongSelf.parseLinks(text: dataText)
                        }
                    } else {
                        DispatchQueue.main.async { [weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.urlStatuses[localUrlString] = "No HTML"
                            strongSelf.delegate?.didUpdateLinksDictionary()
                            strongSelf.maxThreadNumber += 1
                            strongSelf.search(in: "")
                        }
                    }
                    DispatchQueue.main.async { [weak self] in
                        guard let strongSelf = self else { return }
                        if strongSelf.indexOfUrlToSearch == strongSelf.urlMaxCount {
                            strongSelf.delegate?.didFinishSearch()
                        }
                    }
                })
                task.resume()
            }
        }
        
    }
    
    func parseLinks(text: String) {
        DispatchQueue.global().async {
            let newLinks = text.extractURLs()
            //add all links in to urls if not exist before
            DispatchQueue.main.async { [weak self] in
                //if url doesn't contain any strings - relaunch anyway
                if newLinks.count == 0 {
                    self?.search(in: "")
                }
                for link in newLinks {
                    self?.search(in: link.absoluteString)
                }
            }
        }
        
    }

}
