//
//  ViewController.swift
//  SurprizeMeTestTask
//
//  Created by Илья Ершов on 28/10/2019.
//  Copyright © 2019 Ilia Ershov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var userData: UserData?
    private var imageURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.isHidden = true
        activityIndicator.hidesWhenStopped = true
        
        fetchData()
        
        
        
    }

    @IBAction func rateUsButton(_ sender: Any) {
        let urlStr = "https://itunes.apple.com/app/id1054189818?action=write-review"

        guard let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) else { return }

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    
    func fetchData() {
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        guard let url = URL(string: "https://app.surprizeme.ru/api/profile/") else { return }
        
        var request = URLRequest(url: url)
        
        request.setValue("Token b08ec419bc777ba24264ec5cd426b874c89e4c34", forHTTPHeaderField: "Authorization")
    
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, let response = response else { return }
            //print (response)
            
            do{
                let json = try JSONSerialization.jsonObject(with: data, options: [])
        
                //print(json)
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                self.userData = try decoder.decode(UserData.self, from: data)
                
                
                DispatchQueue.main.async {
                    self.nameLabel.text = self.userData?.data.firstName
                    self.emailLabel.text = self.userData?.data.email
                }
                
                guard let imageURL = URL( string: (self.userData?.data.avatar)! ) else { return }
                
                URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                            self.avatarImage.image = image
                        }
                    }
                }.resume()
                
            } catch {
                print(error)
            }
        }.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is SettingsViewController {
            if (segue.identifier == "toSettings") {
                let settingsController = segue.destination as! SettingsViewController
                settingsController.userData = self.userData
                settingsController.viewController = self
            }
        }
    }
    
}

