//
//  ImageViewExtension.swift
//  SampleApp
//
//  Created by Ben Scheirman on 8/18/15.
//  Copyright (c) 2015 Adzerk. All rights reserved.
//

import UIKit

class RemoteImageView: UIImageView {
    var task: URLSessionDataTask? = nil
    
    func loadImageWithURL(_ url: URL) {
        if let task = task {
            task.cancel()
        }
        
        image = nil
        task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if error == nil {
                if self.task?.state == .canceling {
                    return
                }
                let http = response as! HTTPURLResponse
                if http.statusCode == 200 {
                    let image = UIImage(data: data!)
                    DispatchQueue.main.async {
                        if self.task?.state == .canceling {
                            return
                        }
                        
                        self.image = image
                    }
                } else {
                    print("Received HTTP \(http.statusCode) from \(url)")
                }
            } else {
                // ignore
            }
        }) 
        task?.resume()
    }
}
