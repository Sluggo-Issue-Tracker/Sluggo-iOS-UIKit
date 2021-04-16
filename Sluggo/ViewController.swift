//
//  ViewController.swift
//  Sluggo
//
//  Created by Isaac Trimble-Pederson on 4/8/21.
//

import UIKit

class ViewController: UIViewController {

    
    let decoder = JSONDecoder()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the proper date Decoding Strategy to be ISO8601 (YYYY-MM-dd'T'HH:mm:ss'Z) NOTE NO MILLISECONDS SUPPORTED
        decoder.dateDecodingStrategy = .iso8601
        // Do any additional setup after loading the view.
    }


}

