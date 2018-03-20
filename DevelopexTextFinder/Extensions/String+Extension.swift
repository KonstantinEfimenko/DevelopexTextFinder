//
//  String+Extension.swift
//  DevelopexTextFinder
//
//  Created by Konstantin Efimenko on 3/18/18.
//  Copyright © 2018 Konstantin Efimenko. All rights reserved.
//

import Foundation

extension String {
    func extractURLs() -> [URL] {
        var urls : [URL] = []
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            detector.enumerateMatches(in: self, options: [], range: NSMakeRange(0, self.count), using: { (result, _, _) in
                if let match = result,
                    let url = match.url,
                    url.absoluteString.hasPrefix("http"),
                    !url.absoluteString.hasSuffix(".png"),
                    !url.absoluteString.hasSuffix(".js"),
                    !url.absoluteString.hasSuffix(".ico"),
                    !url.absoluteString.hasSuffix(".php"),
                    !url.absoluteString.hasSuffix(".gif") {
                        urls.append(url)
                }
            })
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return urls
    }
}
