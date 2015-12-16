//
//  ViewController.swift
//  myFlickFinder
//
//  Created by Alper on 15/12/15.
//  Copyright © 2015 Alper. All rights reserved.
//

import UIKit

/* 1 - Define constants */
let BASE_URL = "https://api.flickr.com/services/rest/"
let METHOD_NAME = "flickr.galleries.searchPhotos"
let API_KEY = "5d5a5f042fdd0e0f65d99e908965ecc6"
let TEXT = "baby+asian+elephant"
let DATA_FORMAT = "json"
let NO_JSON_CALLBACK = "1"




class ViewController: UIViewController {

    
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textFieldPhrase: UITextField!
    @IBOutlet weak var textFieldLatitude: UITextField!
    @IBOutlet weak var textFieldLongitude: UITextField!
    @IBOutlet weak var imageTitleLabel: UILabel!
    
    @IBAction func phraseSearchBtnPressed(sender: AnyObject) {
    
        searchImageByPhraseInFlickr()
    
    }
    
    
    
    @IBAction func latLongSearchBtnPressed(sender: AnyObject) {
        
        
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchImageByPhraseInFlickr(){
    
        /* 2 - API method arguments */
        let methodArguments = [
            "method": METHOD_NAME,
            "api_key": API_KEY,
            "text": TEXT,
            "format": DATA_FORMAT,
            "nojsoncallback": NO_JSON_CALLBACK
        ]
    }
    


}

