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
    
    // record of impressions sent
    var impressions: [String: Bool] = [:]
    
    fileprivate var _rowData: [Any]?
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
        tableView.rowHeight = UITableView.automaticDimension
        
        loadPlacements {
            self.loadVikings()
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let obj = rowData[indexPath.row]
        if let viking = obj as? Viking {
            let cell = tableView.dequeueReusableCell(withIdentifier: "VikingCell") as! VikingCell
            configureVikingCell(cell, viking: viking)
            return cell
        } else if let decision = obj as? ADZPlacementDecision {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DecisionCell") as! DecisionCell
            configureDecisionCell(cell, decision: decision)
            return cell
        } else {
            fatalError("Unhandled row data type: \(obj)")
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let _ = cell as? DecisionCell {
            if let decision = rowData[indexPath.row] as? ADZPlacementDecision, let impressionUrl = decision.impressionUrl {
                if impressions[impressionUrl] == nil {
                    impressions[impressionUrl] = true
                    recordImpression(impressionUrl)
                }
            }
        }
    }
    
    fileprivate func recordImpression(_ urlString: String) {
        if let url = URL(string: urlString) {
            print("Recording impression for \(url)")
            adzerkSDK.recordImpression(url)
        } else {
            print("Not a valid url: \(urlString)")
        }
    }
    
    fileprivate func loadPlacements(_ completion: @escaping () -> ()) {
        
        let options = ADZPlacementRequestOptions()
        options.keywords = ["karate", "kittens", "knives"]
        
        let placement = ADZPlacement(divName: "div1", adTypes: [5])!
        placement.properties = ["foo": "bar"]
        placement.eventIds = [1, 2, 3]
        
        adzerkSDK.requestPlacements([placement], options: options) { response in
            switch response {
            case .success(let placementResponse):
                self.decisions = Array(placementResponse.decisions.values)
                print("Decisions: \(self.decisions)")
                break
                
            case .badRequest(let status, let body):
                print("Bad request: HTTP \(status) -> \(body)")
                
            case .badResponse(let body):
                print("Bad response: \(body)")
                
            case .error(let error):
                print("error fetching placements: \(error)")
            }
            
            completion()
        }
    }
    
    fileprivate func loadVikings() {
        vikings = VikingGenerator.generateVikings(40)
    }
    
    fileprivate func configureVikingCell(_ cell: VikingCell, viking: Viking) {
        cell.nameLabel.text = viking.name
        cell.quoteLabel.text = viking.quote
        cell.vikingImageView.loadImageWithURL(viking.imageUrl)
    }
    
    fileprivate func configureDecisionCell(_ cell: DecisionCell, decision: ADZPlacementDecision) {
        if let contents = decision.contents?.first, let data = contents.data {
            if let title = data["title"] as? String {
                cell.nameLabel.text = title
            }
            if let customData = data["customData"] as? [String: String], let quote = customData["quote"] {
                cell.quoteLabel.text = quote
            }
            if let imageUrl = data["imageUrl"] as? String {
                let url = URL(string: imageUrl)!
                cell.vikingImageView.loadImageWithURL(url)
            }
        } else {
            // decision doesn't have any contents
            cell.nameLabel.text = ""
            cell.quoteLabel.text = ""
        }
    }
}
