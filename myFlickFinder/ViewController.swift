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
let SAFE_SEARCH = "1"
let BOUNDING_BOX_HALF_WIDTH = 1.0
let BOUNDING_BOX_HALF_HEIGHT = 1.0
let LAT_MIN = -90.0
let LAT_MAX = 90.0
let LON_MIN = -180.0
let LON_MAX = 180.0


// MARK: - String Extension

extension String {
    func toDouble() -> Double? {
        return NSNumberFormatter().numberFromString(self)?.doubleValue
    }
}



class ViewController: UIViewController {

    
    
    @IBOutlet weak var defaultLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textFieldPhrase: UITextField!
    @IBOutlet weak var textFieldLatitude: UITextField!
    @IBOutlet weak var textFieldLongitude: UITextField!
    @IBOutlet weak var imageTitleLabel: UILabel!
    
    var tapRecognizer : UITapGestureRecognizer?  = nil
    @IBAction func phraseSearchBtnPressed(sender: AnyObject) {
        
        if !(textFieldPhrase.text!.isEmpty){
            
            imageTitleLabel.text = "Searching"
            /* 2 - API method arguments */
            let methodArguments : [String: String!] = [
                "method": METHOD_NAME,
                "api_key": API_KEY,
                "text": self.textFieldPhrase.text,
                "extras": EXTRAS,
                "format": DATA_FORMAT,
                "nojsoncallback": NO_JSON_CALLBACK
            ]
            searchImageInFlickr(methodArguments)
        
        }else{
            imageTitleLabel.text = "Phrase empty."
        }
    
    }
    
    
    
    @IBAction func latLongSearchBtnPressed(sender: AnyObject) {
        if !textFieldLatitude.text!.isEmpty && !textFieldLongitude.text!.isEmpty{
            
            
            
            if validLatitude() && validLongitude() {
               
                imageTitleLabel.text = "Searching..."
                
                /* 2 - API method arguments */
                let methodArguments = [
                    "method": METHOD_NAME,
                    "api_key": API_KEY,
                    "bbox": createBboxString(),
                    "safe_search": SAFE_SEARCH,
                    "extras": EXTRAS,
                    "format": DATA_FORMAT,
                    "nojsoncallback": NO_JSON_CALLBACK
                ]
                searchImageInFlickr(methodArguments)
            
            }else if !validLongitude() && !validLongitude(){
                imageTitleLabel.text = "Lat/Lon Invalid.\nLat should be [-90, 90].\nLon should be [-180, 180]."
            }else if !validLongitude(){
                imageTitleLabel.text = "Lot Invalid.\nLot should be [-180, -180]."
            }else {
                imageTitleLabel.text = "Lat Invalid.\nLat should be [-90, 90]."
            }
            
        
        }else{
            if textFieldLongitude.text!.isEmpty && textFieldLatitude.text!.isEmpty{
            
               imageTitleLabel.text = "Lat/Lon empty."
            
            }else if textFieldLatitude.text!.isEmpty{
                
                imageTitleLabel.text = "Latitude is empty."
                
            }else{
                imageTitleLabel.text = "Longtitude is empty."
            }
        }
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.addKeyboardDismissRecognizer()
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.removeKeyboardDismissRecognizer()
        self.unsubscribeToKeyboardNotifications()
    }
    
    // MARK: Show/Hide Keyboard
    
    func addKeyboardDismissRecognizer() {
        print("Add the recognizer to dismiss the keyboard")
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        print("Remove the recognizer to dismiss the keyboard")
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        print("End editing here")
        self.view.endEditing(true)
    }
    
    func subscribeToKeyboardNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    
    }
    
    func unsubscribeToKeyboardNotifications() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        print("Shift the view's frame up so that controls are shown")
        if self.imageView.image != nil {
            self.defaultLabel.alpha = 0.0
        }
        if self.view.frame.origin.y == 0.0 {
            self.view.frame.origin.y -= self.getKeyboardHeight(notification) / 2
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        print("Shift the view's frame down so that the view is back to its original placement")
        if self.imageView.image == nil {
            self.defaultLabel.alpha = 1.0
        }
        if self.view.frame.origin.y != 0.0 {
            self.view.frame.origin.y += self.getKeyboardHeight(notification) / 2
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        print("Get and return the keyboard's height from the notification")
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    // MARK: Flickr API
    
    func searchImageInFlickr(methodArguments : [String : AnyObject]){
        
        /* 3 - Initialize session and url */
        let session = NSURLSession.sharedSession()
        let urlString = BASE_URL + escapedParameters(methodArguments)
        //print(urlString)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        /* 4 - Initialize task for getting data */
        let task = session.dataTaskWithRequest(request) { (data, response, downloadError) in
            
            /* Parse the data! */
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            } catch {
                parsedResult = nil
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
                
            
            /* GUARD: Did Flickr return an error? */
            guard let stat = parsedResult["stat"] as? String where stat == "ok" else {
                print("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            guard let photosDictionary = parsedResult["photos"] as? NSDictionary else{
                print("Cannot find keys 'photos' in  \(parsedResult)")
                return
            }
            
            
            //Total Number of Photos
            var totalPhotosVal = 0
            if let totalphotos = photosDictionary["total"] as? String {
                totalPhotosVal = (totalphotos as NSString).integerValue
            
            }
            
            
            //If photos returned, lets grab one !
            if totalPhotosVal > 0 {
                
                guard let photosArray = photosDictionary["photo"] as? [[String:AnyObject]] else{
                    print("Cannot find keys 'photo' in  \(photosDictionary)")
                    return
                }
                
                //Get a randow index , pick a random photo in dictionary
                let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
                let photoDictionary = photosArray[randomPhotoIndex] as NSDictionary
                
                
                
                //Prepare the UI Updates
                
                let photoTitle = photoDictionary["title"] as? String
               
                guard let imageURLString = photoDictionary["url_m"] as? String else {
                
                    print("Cannot find keys 'url_m' in  \(photosDictionary)")
                    return
                }
                
                
                
                let imageURL = NSURL(string: imageURLString)
                
                //Update the UI on the main thread
                if let imageData = NSData(contentsOfURL: imageURL!){
                    dispatch_async(dispatch_get_main_queue(),{
                        print ("Success , updates the UI here !")
                        
                        self.imageView.image = UIImage(data: imageData)
                        self.defaultLabel.alpha = 0.0
                        
                        if methodArguments["bbox"] != nil {
                            if let photoTitle = photoTitle {
                                self.imageTitleLabel.text = ("\(self.getLatLonString()) \(photoTitle)")
                                
                            }else {
                                self.imageTitleLabel.text = ("\(self.getLatLonString()) \(photoTitle)")
                            }
                        }else {
                            self.imageTitleLabel.text = photoTitle ?? "(Untitled)"
                        }
                    })
                }else{
                    
                    print("Image does not exist in\(imageURL)")
                }
            }else {
                dispatch_async(dispatch_get_main_queue(),{
                    print ("Success , updates the UI here !")
                    self.imageTitleLabel.text = "No photos found , search again!"
                    self.imageView.image = nil
                    self.defaultLabel.alpha = 1.0
                })
                
            }
            
            
        
        }
        
        task.resume()

    }
    
    
    //MARK: Create Bounding Box Function
    
    func createBboxString() -> String {
        
        let latitude = (self.textFieldLatitude.text! as NSString).doubleValue
        let longitude = (self.textFieldLongitude.text! as NSString).doubleValue
        
        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(longitude - BOUNDING_BOX_HALF_WIDTH, LON_MIN)
        let bottom_left_lat = max(latitude - BOUNDING_BOX_HALF_HEIGHT, LAT_MIN)
        let top_right_lon = min(longitude + BOUNDING_BOX_HALF_HEIGHT, LON_MAX)
        let top_right_lat = min(latitude + BOUNDING_BOX_HALF_HEIGHT, LAT_MAX)
        
        
        return ("\(bottom_left_lon ),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)")
        
    }
    
    func getLatLonString() -> String {
        let latitude = (self.textFieldLatitude.text! as NSString).doubleValue
        let longitude = (self.textFieldLongitude.text! as NSString).doubleValue
        
        return "(\(latitude), \(longitude))"
    }
    
    
    /* Check to make sure the latitude falls within [-90, 90] */
    func validLatitude() -> Bool {
        if let latitude : Double? = self.textFieldLatitude.text!.toDouble() {
            if latitude < LAT_MIN || latitude > LAT_MAX {
                return false
            }
        } else {
            return false
        }
        return true
    }
    
    /* Check to make sure the longitude falls within [-180, 180] */
    func validLongitude() -> Bool {
        if let longitude : Double? = self.textFieldLongitude.text!.toDouble() {
            if longitude < LON_MIN || longitude > LON_MAX {
                return false
            }
        } else {
            return false
        }
        return true
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

