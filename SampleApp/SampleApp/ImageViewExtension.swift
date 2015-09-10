//
//  ImageViewExtension.swift
//  SampleApp
//
//  Created by Ben Scheirman on 8/18/15.
//  Copyright (c) 2015 Adzerk. All rights reserved.
//

import UIKit

class RemoteImageView: UIImageView {
    var task: NSURLSessionDataTask? = nil
    
    func loadImageWithURL(url: NSURL) {
        if let task = task {
            task.cancel()
        }
        
        image = nil
        task = NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            if error == nil {
                if self.task?.state == NSURLSessionTaskState.Canceling {
                    return
                }
                let http = response as! NSHTTPURLResponse
                if http.statusCode == 200 {
                    let image = UIImage(data: data!)
                    dispatch_async(dispatch_get_main_queue()) {
                        if self.task?.state == NSURLSessionTaskState.Canceling {
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
        }
        task?.resume()
    }
}
