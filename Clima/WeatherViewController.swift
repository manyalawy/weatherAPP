//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
class WeatherViewController: UIViewController, CLLocationManagerDelegate , ChangeCityDelegate{
   
    
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "cc0bbcf5c74954a72a29ed299845a991"
    
    var cel:Int = 0
    var fer:Int = 0
    //TODO: Declare instance variables here
    
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var switchTemp: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        
    }
    
    @IBAction func switchh(_ sender: Any) {

        


            if switchTemp.isOn == true{
                
                temperatureLabel.text = String(cel)
                
            }
        
        if switchTemp.isOn == false{
            temperatureLabel.text = String(fer)
        }
        
    }
    
  
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    func getWeatherData(url:String ,parameters:[String:String]) {
          
        Alamofire.request(url , method: .get , parameters: parameters).responseJSON {
              response in
              if(response.result.isSuccess){
                  
                let weatherJSON : JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
                self.updateUIWithWeatherData()
              }
              else{
                  self.cityLabel.text = "Connection error"
              }
          }
      }
    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json:JSON){
         
        if let tempResult = json["main"]["temp"].double{
            
            weatherDataModel.temperature = Int(tempResult - 273.15)
            
            cel = Int(tempResult - 273.15)
            fer = Int(1.8*(tempResult - 273) + 32)
            print(fer)
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
        }
        else{
            cityLabel.text = "weather unavailable"
        }
        
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData(){
        
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = String(weatherDataModel.temperature)
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if(location.horizontalAccuracy>0){
            locationManager.stopUpdatingLocation()
        }
        
        let longitude = String(location.coordinate.longitude)
        let latitude = String(location.coordinate.latitude)
        
        let params : [String:String] = ["lat" : latitude ,"lon" : longitude , "appid":APP_ID]
        
        getWeatherData(url: WEATHER_URL , parameters: params)
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        cityLabel.text = "location unavailable"
    }
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String) {
           
        let params : [String:String] = ["q":city , "appid": APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: params)
        
        
       }

    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "changeCityName"{
           
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
            
        }
    }
    
    
    
}


