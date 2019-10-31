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

    var viewController: ViewController?
    var userData: UserData?
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var englishButton: UIButton!
    @IBOutlet weak var russianButton: UIButton!
    @IBOutlet weak var locationSwitch: UISwitch!
    @IBOutlet weak var changeNameButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    var locationAllowed: Bool {
        set{
            UserDefaults.standard.set(newValue, forKey: "locationAllowed")
            UserDefaults.standard.synchronize()
        }
        get{
            if let newLocationAllowed = UserDefaults.standard.bool(forKey: "locationAllowed") as? Bool?{
                return newLocationAllowed!
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
            if let newEnChosen = UserDefaults.standard.bool(forKey: "enChosen") as? Bool?{
                return newEnChosen!
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
            if let newRuChosen = UserDefaults.standard.bool(forKey: "ruChosen") as? Bool?{
                return newRuChosen!
            } else {
                return false
            }
        }
    }
    
    @IBAction func locationSwitch(_ sender: Any) {
        
        if (!locationAllowed) {
            
                //self.locationAllowed = !self.locationAllowed
                
                // Ask for Authorisation from the User.
                self.locationManager.requestAlwaysAuthorization()
                
                // For use in foreground
                self.locationManager.requestWhenInUseAuthorization()
                
                if CLLocationManager.locationServicesEnabled() {
                    //self.locationManager.delegate = self as? CLLocationManagerDelegate
                    //self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                    //self.locationManager.startUpdatingLocation()
                    locationAllowed = true
                } else {
                    locationSwitch.isOn = false
                    locationAllowed = false
                }
           
        } else {
            locationAllowed = false
            locationManager.stopUpdatingLocation()
        }
                
        //locationAllowed = !locationAllowed
    }
    
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
        
    @IBAction func checkUserName(_ sender: Any) {
        print(self.viewController?.userData?.data.firstName)
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
//                    DispatchQueue.main.async {
//                        self.viewController?.fetchData()
//                        print(self.viewController?.userData?.data.firstName)
//                        self.userData = self.viewController?.userData
//                        self.nameLabel.text = self.userData?.data.firstName
//                    }
                    
                    
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
            
            //Setting new labels's fields to new name value
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
