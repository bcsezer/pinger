//
//  homeVC.swift
//  ios_assignment_pinger
//
//  Created by Cem Sezeroglu on 15.11.2020.
//

import UIKit

class homeViewController: UIViewController {
    @IBOutlet weak var localIpLabel: UILabel!
    
    var localIp = getIPAddress()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addNavBarShadow()
        
        localIpLabel.text = "Your Local IP : \(localIp ?? "Nil")"
    }
    
    func addNavBarShadow(){
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 1.0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 3.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 1.0
        self.navigationController?.navigationBar.layer.masksToBounds = false
    }
    
    
    @IBAction func startButtonClicked(_ sender: UIButton) {
        if localIp != ""{
            performSegue(withIdentifier: "toPingVC", sender: self)
        }else{
            makeAllert(titleInput: "Error", messageInput: "Could not find any IP adress")
        }
        
    }
    @IBAction func startInfoCLicked(_ sender: UIButton) {
        makeAllert(titleInput: "What is pinging ? ", messageInput: "Ping is a basic Internet program that allows a user to verify that a particular IP address exists and can accept requests.")
    }
    
    
    func makeAllert(titleInput :String,messageInput:String){
               let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
               alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.cancel, handler: nil))
               self.present(alert, animated: true, completion: nil)
       }
  
}
