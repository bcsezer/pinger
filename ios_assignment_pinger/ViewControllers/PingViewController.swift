//
//  ViewController.swift
//  ios_assignment_pinger
//
//  Created by Cem Sezeroglu on 14.11.2020.
//

import UIKit

class PingViewController: UIViewController {
    
    @IBOutlet var buttons: [UIButton]!
    
    var localIpAdress = ""
    var counter = 1
    
    @IBOutlet weak var tableView: UITableView!
    
 
    var ipAdresModalArray = [IpAdress]() //An Array of IP Modal which I will use in tableView
    var ipAdresses = [String]() // I get this because when I ping ip adresses I need all the possible IP adresses
    var newIpAdress = "" // This is just string :)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
       
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureButtons()
        increaseIpAdress()
       
     
    }
    
    
    //MARK:My IP starts with 192 . Instead of filling the Array manually, I filled it up to 254 with the loop.
    func increaseIpAdress(){
        
        localIpAdress = getIPAddress() ?? "Nil"  //To get my ip adress
        
        print("My IP Adress is : \(localIpAdress)")
        
        let splitAdres = localIpAdress.split(separator: ".") //It's hard to convert IP to string to Int. That's why I split String than add last index my counter as string.
        
        print(splitAdres)// Control spliting string
        
        if splitAdres[0] == "192"{
            
                    print("before While :\(counter)") // just some control...
            
            while (counter <= 254) {
                
                    newIpAdress = splitAdres[0]+"."+splitAdres[1]+"."+splitAdres[2]+"."+String(counter) // Add last index counter as string
                    counter += 1 // increase counter while counter is 254
                    
                ipAdresses.append(newIpAdress) // fill array with ip adresses
                
            }
        
            print(" After While  :\(counter)") // just some control...
            
        }else{
            print("Error while parsing string")
        }
        
    }
    
    func configureButtons(){
        for button in buttons{
            button.layer.cornerRadius = 5
            button.layer.masksToBounds = true
        }
    }
    

}

extension PingViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "pingCell", for: indexPath) as! pingTableViewCell
        
        cell.IPStatusText.text = "Reachable"
        cell.IPText.text = localIpAdress
        
        
        return cell
    }
    
    
}

