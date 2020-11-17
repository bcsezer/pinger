//
//  ViewController.swift
//  ios_assignment_pinger
//
//  Created by Cem Sezeroglu on 14.11.2020.
//

import UIKit

class PingViewController: UIViewController {
    var memoryIndex = 0
    var ping: SwiftyPing?
    
    
    
    var timer = Timer()
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
    
    var totalTime : Int?
    var secondsPassed = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        timer = Timer.scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(progressBarUpdate), userInfo: nil, repeats: true)
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.isHidden = true
        configureButtons()
        increaseIpAdress()
      
        
        
      
            pinger(index: 0)
        
        
        
     
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ping?.stopPinging()
    }
    @IBAction func restartClicked(_ sender: UIButton) {
        timer.invalidate()
        secondsPassed = 0
        progressBarLabel.text = "0 %"
        timer = Timer.scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(progressBarUpdate), userInfo: nil, repeats: true)
        ipAdresModalArray.removeAll()
        tableView.reloadData()
        
        pinger(index: 0)
        
        stopButton.isEnabled = true
        filterButton.isEnabled = false
        
    }
    
    @IBAction func stopButtonClicked(_ sender: UIButton) {
        buttonCliked = false
        ping?.stopPinging()
        timer.invalidate()
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
    
    func congigureUI(){
        
        if Int(progressView.progress * 100) <= 5{
            tableView.isHidden = true
            progressBarLabel.isHidden = false
            
        }else{
            progressBarLabel.isHidden = false
            tableView.isHidden = false
        }
       
    }
    
    @objc func progressBarUpdate(){
        if ipAdresses.isEmpty == false {
            totalTime = ipAdresses.count
            if secondsPassed < totalTime!{
                secondsPassed += 1
                
              congigureUI()

                progressView.progress = Float(secondsPassed) / Float(totalTime!)
                progressBarLabel.text = String (Int(progressView.progress * 100)) + "%"
                
            }else{
                timer.invalidate()
                secondsPassed = 0
            }
        }
        
        
    }
    
    func configureButtons(){
        for button in buttons{
            button.layer.cornerRadius = 5
            button.layer.masksToBounds = true
        }
    }
    
    func pinger(index: Int) {
         ping = try? SwiftyPing(host: ipAdresses[index], configuration: PingConfiguration(interval: 0.5, with: 2), queue: DispatchQueue.global())
            ping?.observer = { (response) in
               
                var message = ""
                if response.error != nil {

                    print(response.error!)
                    print("not reachable \(response.ipAddress!)")
                    message = "Unreachable"
                    self.ping?.haltPinging()

                    if index+1 <= 254 {
                        self.pinger(index: index+1)
                        self.memoryIndex = index
                    }
                } else {
                    print(response.ipAddress!)
                    print("Reachable")
                    message = "Reachable"
                    self.ping?.haltPinging()


                    if index+1 <= 254 {
                        self.pinger(index: index+1)
                        self.memoryIndex = index
                    }
                    
                }
                    let results = IpAdressModal(address: self.ipAdresses[index], success: message)
                    self.ipAdresModalArray.append(results)
                DispatchQueue.main.async {
                self.tableView.reloadData()
                }
            
            }
        ping?.targetCount = 2
        try? ping?.startPinging()
            
        }
//    func startPing(count:Int) {
//
//
//        do {
//            ping = try SwiftyPing(host: ipAdresses[count], configuration: PingConfiguration(interval: 1, with: 1 ), queue: DispatchQueue.global())
//               ping?.observer = { (response) in
//                   DispatchQueue.main.async {
//                       var duration = "\(response.duration! * 1000) ms"
//                    var message = "Reachable"
//                       if let error = response.error {
//
//                           if error == .responseTimeout {
//                               message = "Unreachable"
//                           } else if error == .hostNotFound {
//                               print(error)
//                               message = "Unreachable"
//                           }else{
//                            message = "Unreachable"
//                           }
//                       }
//
//                    if count == 254{
//                        self.ping?.stopPinging()
//                    }else{
//                        print(self.ipAdresses[count])
//                        let results = IpAdressModal(address: self.ipAdresses[count], success: message)
//                        self.ipAdresModalArray.append(results)
//                           print(message)
//                        print(duration)
//                        self.startPing(count: count+1)
//
//
//                    }
//
//
//                   }
////                let index = IndexPath(row: self.ipAdresModalArray.count-1, section: 0)
////                    self.tableView.scrollToRow(at: index, at: .bottom, animated: true)
//                self.tableView.reloadData()
//
//
//               }
//            // ping?.targetCount = 1
//               try ping?.startPinging()
//           } catch {
//               print(error.localizedDescription)
//           }
//
//    }
    
    

}

extension PingViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ipAdresModalArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "pingCell", for: indexPath) as! pingTableViewCell
        
        cell.IPStatusText.text = ipAdresModalArray[indexPath.row].success
        cell.IPText.text = ipAdresModalArray[indexPath.row].address
        
        if (indexPath.row % 2) != 0 { //index'i çift olanları beyaz diğerlerini açık gri yap
            cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }else{
            cell.backgroundColor = #colorLiteral(red: 0.9549764661, green: 0.9549764661, blue: 0.9549764661, alpha: 1)
        }
        
        return cell
    }
    
    
}

