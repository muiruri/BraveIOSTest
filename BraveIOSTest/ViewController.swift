//
//  ViewController.swift
//  BraveIOSTest
//
//  Created by John Mbuthia on 18/09/2018.
//  Copyright © 2018 John Mbuthia. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var fahrenLabel: UILabel!
    @IBOutlet weak var celsiusLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        setDateTime();
    }
    
    /**
        This function is invoked when the location is updated.
    */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        let long = userLocation.coordinate.longitude;
        let lat = userLocation.coordinate.latitude;
        
        longitudeLabel.text = "Longitude : \(Double(round(100000 * long)/100000))"
        latitudeLabel.text = "Longitude : \(Double(round(100000 * lat)/100000))"
        requestWeather(long : long, lat : lat)
        //Do What ever you want with it
    }
    
    /**
        This function gets the date and time.
    */
    func setDateTime() {
        let date = Date()
        
        // initialize the date formatter and set the style
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .long
        dateTimeLabel.text = formatter.string(from: date)
        print(formatter.string(from: date))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
        This function sends the request to fetch the weather data.
    */
    func requestWeather( long: Double,  lat : Double) {
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(long)&appid=45813a7a1a789e89b0b32e96e006e712&units=metric")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            if let data = data {
                do {
                    // Convert the data to JSON
                    let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                    
                    if let json = jsonSerialized, let main = json["main"] as? [String : Any] {
                        let temp = main["temp"] as! Double
                        let fah = temp * 33.8
                        DispatchQueue.main.async{
                            self.celsiusLabel.text = "\(temp)c"
                            self.fahrenLabel.text = "\(Double(round(100 * fah)/100))F"
                        }
                    }
                    
                }  catch let error as NSError {
                    print(error.localizedDescription)
                }
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }


}

