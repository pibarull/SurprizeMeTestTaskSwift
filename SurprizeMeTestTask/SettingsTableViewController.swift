//
//  SettingsTableViewController.swift
//  SurprizeMeTestTask
//
//  Created by Илья Ершов on 30/10/2019.
//  Copyright © 2019 Ilia Ershov. All rights reserved.
//

import UIKit
import CoreLocation

class SettingsTableViewController: UITableViewController {

    //MARK: - Variables
    var viewController: ViewController?
    var userData: UserData?
    var firstSwitch: Bool = true
    
    var locationAllowed: Bool {
        set{
            UserDefaults.standard.set(newValue, forKey: "locationAllowed")
            UserDefaults.standard.synchronize()
        }
        get{
            if let newLocationAllowed = UserDefaults.standard.value(forKey: "locationAllowed") as? Bool? {
                return newLocationAllowed ?? false
            } else {
                return false
            }
        }
    }
    var enChosen: Bool {
        set{
            UserDefaults.standard.set(newValue, forKey: "enChosen")
            UserDefaults.standard.synchronize()
        }
        get{
            if let newEnChosen = UserDefaults.standard.value(forKey: "enChosen") as? Bool?{
                return newEnChosen ?? false
            } else {
                return false
            }
        }
    }
    var ruChosen: Bool {
        set{
            UserDefaults.standard.set(newValue, forKey: "ruChosen")
            UserDefaults.standard.synchronize()
        }
        get{
            if let newRuChosen = UserDefaults.standard.value(forKey: "ruChosen") as? Bool?{
                return newRuChosen ?? false
            } else {
                return false
            }
        }
    }
    
    //MARK: - Constants
    let locationManager = CLLocationManager()
    
    //MARK: - Outlets
    @IBOutlet weak var englishButton: UIButton!
    @IBOutlet weak var russianButton: UIButton!
    @IBOutlet weak var locationSwitch: UISwitch!
    @IBOutlet weak var changeNameButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var locationNotification: UILabel!
    @IBOutlet weak var locationDisable: UILabel!
    

    //MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsSelection = false
        
        englishButton.layer.cornerRadius = 20
        russianButton.layer.cornerRadius = 20
        
        if enChosen {
            englishButton.backgroundColor = UIColor.lightGray
        }
        if ruChosen {
            russianButton.backgroundColor = UIColor.lightGray
        }
        
        self.nameLabel.text = userData?.data.firstName
        self.emailLabel.text = userData?.data.email
            
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if locationAllowed {
            locationManager.startUpdatingLocation()
            locationSwitch.isOn = true
            locationDisable.text = "Location is enabled"
            locationAllowed = false
        } else {
            locationManager.stopUpdatingLocation()
            locationSwitch.isOn = false
            locationDisable.text = "Location is disabled"
            locationAllowed = true
        }
    }
    
    @IBAction func locationSwitch(_ sender: Any) {
        
        if !firstSwitch {
            if !locationAllowed {
                locationManager.startUpdatingLocation()
                locationDisable.text = "Location is enabled"
            } else {
                locationManager.stopUpdatingLocation()
                locationDisable.text = "Location is disabled"
            }

            locationAllowed = !locationAllowed
        }
        
        if firstSwitch {
            
            if CLLocationManager.locationServicesEnabled() {
                switch(CLLocationManager.authorizationStatus()) {
                case .notDetermined, .restricted, .denied:
                    self.locationAllowed = false
                    self.locationSwitch.isOn = false
                    self.locationSwitch.isEnabled = false
                    self.locationDisable.text = "Location is disabled"
                    self.locationNotification.text = "Check phone's setting to give access for your location"
                case .authorizedAlways, .authorizedWhenInUse:
                    
                    if !locationAllowed {
                        self.locationManager.stopUpdatingLocation()
                        self.locationAllowed = false
                        self.locationSwitch.isOn = false
                        self.locationDisable.text = "Location is disabled"
                    } else {
                        self.locationManager.delegate = self as? CLLocationManagerDelegate
                        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                        self.locationManager.startUpdatingLocation()
                        self.locationAllowed = true
                        self.locationSwitch.isOn = true
                        self.locationDisable.text = "Location is enabled"
                    }
                    self.locationNotification.text = ""
                @unknown default:
                    fatalError()
                }
                firstSwitch = false
            } else {
                print("Location services are disabled")
            }
        }
    }
    
    @IBAction func englishButtonPush(_ sender: Any) {
            
        if !enChosen && !ruChosen {
                enChosen = true
                englishButton.backgroundColor = UIColor.lightGray
            }
            if !enChosen {
                englishButton.backgroundColor = UIColor.lightGray
                russianButton.backgroundColor = UIColor.white
                enChosen = !enChosen
                ruChosen = !ruChosen
            }
        }
        
    @IBAction func russianButtonPush(_ sender: Any) {
        
        if !enChosen && !ruChosen {
            russianButton.backgroundColor = UIColor.lightGray
            ruChosen = true
        }
        if !ruChosen {
            russianButton.backgroundColor = UIColor.lightGray
            englishButton.backgroundColor = UIColor.white
            ruChosen = !ruChosen
            enChosen = !enChosen
        }
    }
    
    @IBAction func changeNamePush(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Change name", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "New name"
        }
        
        let changeNameAction = UIAlertAction(title: "Done", style: .default)
        {
            (alert) in
            if (alertController.textFields![0].text! != "") {
                self.postName(alertController.textFields![0].text!)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in }
        
        alertController.addAction(changeNameAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
        
    func postName(_ newName: String) {
        guard let url = URL(string: "https://app.surprizeme.ru/api/profile/name/") else { return }
            
        let changedData = ["first_name" : "\(newName)"]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
          
        guard let httpBody = try? JSONSerialization.data(withJSONObject: changedData, options: []) else { return }
        
        request.httpBody = httpBody
        request.setValue("Token b08ec419bc777ba24264ec5cd426b874c89e4c34", forHTTPHeaderField: "Authorization")
        request.addValue("text/html", forHTTPHeaderField: "Content-Type")
            
        let session = URLSession.shared
            
        session.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            
            //Setting new name value for labels's fields
            do{
                
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                self.viewController?.userData = try decoder.decode(UserData.self, from: data)
                self.userData = self.viewController?.userData
                
                DispatchQueue.main.async {
                    self.nameLabel.text = self.userData?.data.firstName
                    self.viewController?.nameLabel.text = self.userData?.data.firstName
                }
            } catch {
                print(error)
            }
        }.resume()
        
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 1
        }
        return 2
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
