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
let METHOD_NAME = "flickr.photos.search"
let API_KEY = "5d5a5f042fdd0e0f65d99e908965ecc6"
let EXTRAS = "url_m"
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
            "text": "baby asian elephant",
            "extras": EXTRAS,
            "format": DATA_FORMAT,
            "nojsoncallback": NO_JSON_CALLBACK
        ]
        
        
        /* 3 - Initialize session and url */
        let session = NSURLSession.sharedSession()
        let urlString = BASE_URL + escapedParameters(methodArguments)
        //print(urlString)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        /* 4 - Initialize task for getting data */
        let task = session.dataTaskWithRequest(request) { (data, response, downloadError) in
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            } catch {
                parsedResult = nil
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
                
            print(parsedResult["photos"])
            // so it prints another dictionary
        
        }
        
        task.resume()

    }
    
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }


}

