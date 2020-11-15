//
//  ViewController.swift
//  ios_assignment_pinger
//
//  Created by Cem Sezeroglu on 14.11.2020.
//

import UIKit

class PingViewController: UIViewController {
    
    var ping: SwiftyPing?
    
    
    
    @IBOutlet var buttons: [UIButton]!
    
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    
    var localIpAdress = ""
    var counter = 1
    var buttonCliked : Bool?
    
    @IBOutlet weak var tableView: UITableView!
    
 
    var ipAdresModalArray = [IpAdressModal]() //An Array of IP Modal which I will use in tableView
    var ipAdresses = [String]() // I get this because when I ping ip adresses I need all the possible IP adresses
    var newIpAdress = "" // This is just string :)
    
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressBarLabel: UILabel!
    var totalTime = 254
    var secondsPassed = 0
    
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
        
        if buttonCliked == true{
            startPing()
        }else{
            print("blabla")
        }
        
     
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ping?.stopPinging(resetSequence: true)
    }
    @IBAction func restartClicked(_ sender: UIButton) {
        stopButton.isEnabled = true
        filterButton.isEnabled = false
        startPing()
    }
    
    @IBAction func stopButtonClicked(_ sender: UIButton) {
        buttonCliked = false
        self.ping?.stopPinging(resetSequence: true)
        stopButton.isEnabled = false
        restartButton.isEnabled = true
        filterButton.isEnabled = true
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
    
    
    func startPing() {
        
        var count = 0
        
        do {
            ping = try SwiftyPing(host: ipAdresses[count], configuration: PingConfiguration(interval: 1, with: 1 ), queue: DispatchQueue.global())
               ping?.observer = { (response) in
                   DispatchQueue.main.async {
                       var duration = "\(response.duration! * 1000) ms"
                    var message = "Reachable"
                       if let error = response.error {
                        
                           if error == .responseTimeout {
                               message = "Unreachable"
                           } else if error == .hostNotFound {
                               print(error)
                               message = "Unreachable"
                           }else{
                            message = "Unreachable"
                           }
                       }
                    
                    if count == 254{
                        self.ping?.stopPinging()
                    }else{
                        print(self.ipAdresses[count])
                        let results = IpAdressModal(address: self.ipAdresses[count], success: message)
                        self.ipAdresModalArray.append(results)
                           print(message)
                        print(duration)
                        count += 1
                       
                        
                    }
                    self.tableView.reloadData()
                    
                    let index = IndexPath(row: self.ipAdresModalArray.count-1, section: 0)
                        self.tableView.scrollToRow(at: index, at: .bottom, animated: true)
                    
                   }
               }
//              ping?.targetCount = 2
               try ping?.startPinging()
               try ping?.startPinging()
           } catch {
               print(error.localizedDescription)
           }
        
    }
    
    

}

extension PingViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ipAdresModalArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "pingCell", for: indexPath) as! pingTableViewCell
        
        cell.IPStatusText.text = ipAdresModalArray[indexPath.row].success
        cell.IPText.text = ipAdresModalArray[indexPath.row].address
        
        
        return cell
    }
    
    
}

