//
//  VikingsTableViewController.swift
//  SampleApp
//
//  Created by Ben Scheirman on 8/18/15.
//  Copyright (c) 2015 Adzerk. All rights reserved.
//

import UIKit
import AdzerkSDK

class VikingsTableViewController : UITableViewController {
    var vikings: [Viking] = [] {
        didSet { _rowData = nil }
    }
    
    var decisions: [ADZPlacementDecision] = [] {
        didSet { _rowData = nil }
    }
    
    private var _rowData: [Any]?
    var rowData: [Any]! {
        if _rowData == nil {
            _rowData = interleave(vikings, decisions, every: 10)
        }
        return _rowData
    }
    
    let adzerkSDK = AdzerkSDK()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        loadPlacements {
            self.loadVikings()
            self.tableView.reloadData()
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let obj = rowData[indexPath.row]
        if let viking = obj as? Viking {
            let cell = tableView.dequeueReusableCellWithIdentifier("VikingCell") as! VikingCell
            configureVikingCell(cell, viking: viking)
            return cell
        } else if let decision = obj as? ADZPlacementDecision {
            let cell = tableView.dequeueReusableCellWithIdentifier("DecisionCell") as! DecisionCell
            configureDecisionCell(cell, decision: decision)
            return cell
        } else {
            fatalError("Unhandled row data type: \(obj)")
        }
    }
    
    private func loadPlacements(completion: () -> ()) {
        
        var options = ADZPlacementRequestOptions()
        options.keywords = ["karate", "kittens", "knives"]
        
        var placement = ADZPlacement(divName: "div1", adTypes: [5])!
        placement.properties = ["foo": "bar"]
        
        adzerkSDK.requestPlacements([placement], options: options) { response in
            switch response {
            case .Success(let placementResponse):
                self.decisions = Array(placementResponse.decisions.values)
                println("Decisions: \(self.decisions)")
                break
                
            case .BadRequest(let status, let body):
                println("Bad request: HTTP \(status) -> \(body)")
                
            case .BadResponse(let body):
                println("Bad response: \(body)")
                
            case .Error(let error):
                println("error fetching placements: \(error)")
            }
            
            dispatch_async(dispatch_get_main_queue(), completion)
        }
    }
    
    private func loadVikings() {
        vikings = VikingGenerator.generateVikings(40)
    }
    
    private func configureVikingCell(cell: VikingCell, viking: Viking) {
        cell.nameLabel.text = viking.name
        cell.quoteLabel.text = viking.quote
        cell.vikingImageView.loadImageWithURL(viking.imageUrl)
    }
    
    private func configureDecisionCell(cell: DecisionCell, decision: ADZPlacementDecision) {
        if let contents = decision.contents?.first, data = contents.data {
            if let title = data["title"] as? String {
                cell.nameLabel.text = title
            }
            if let customData = data["customData"] as? [String: String], quote = customData["quote"] {
                cell.quoteLabel.text = quote
            }
            if let imageUrl = data["imageUrl"] as? String {
                let url = NSURL(string: imageUrl)!
                cell.vikingImageView.loadImageWithURL(url)
            }
        } else {
            // decision doesn't have any contents
        }
    }
}
