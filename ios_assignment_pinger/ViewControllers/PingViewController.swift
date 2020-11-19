//
//  ViewController.swift
//  ios_assignment_pinger
//
//  Created by Cem Sezeroglu on 14.11.2020.
//

import UIKit

enum selectedFilter: Int {
    
    case Ip = 0
    case connectionType = 1
   
}

class PingViewController: UIViewController {
    
    @IBOutlet weak var searchBarHeight: NSLayoutConstraint!
    
    var ping: SwiftyPing?
    
    var desiredIPindex :Int?
    var isFiltering = false
    
    @IBOutlet weak var searchBar: UISearchBar!
    var timer = Timer()
    @IBOutlet var buttons: [UIButton]!
    
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    
    var localIpAdress = ""
    var counter = 1
    var buttonCliked : Bool?
    var result : IpAdressModal?
    @IBOutlet weak var tableView: UITableView!
    
 
    var ipAdresModalArray = [IpAdressModal]() //An Array of IP Modal which I will use in tableView
    var ipAdresses = [String]() // I get this because when I ping ip adresses I need all the possible IP adresses
    var newIpAdress = "" // This is just string :)
    var filteredArray = [IpAdressModal]()
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressBarLabel: UILabel!
    
    var totalTime : Int?
    var secondsPassed = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
      
        
        
        timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(progressBarUpdate), userInfo: nil, repeats: true)
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        searchBarHeight.constant = 0
        filterButton.alpha = 0.5
        filterButton.isEnabled = false
        
        configureButtons()
        increaseIpAdress()
        
   
        pinger(index: 0)
        
       
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ping?.stopPinging()
    }
    
    func setupSearchBar(){
        searchBarHeight.constant = 0
        searchBar.showsScopeBar = true
        searchBar.scopeButtonTitles = ["IP adress","Connection Status"]
        
      
        
    }
    
    func checkDesiredIPIndexIsActive(index:Int,desiredIP:Int?){
        if desiredIP != nil {
            self.pinger(index: index+1)
            if index+1 == desiredIP! {
                self.timer.invalidate()
                self.ping?.stopPinging()
                
            }else{
                if index+1 <= 254{
                   self.pinger(index: index+1)
               }else{
                   self.ping?.stopPinging()
               }
            }
        }else{
            self.pinger(index: index+1)
        }
    }
   
    @IBAction func filterButtonTapped(_ sender: UIButton) {
        searchBarHeight.constant = 44
    }
    
    @IBAction func restartClicked(_ sender: UIButton) {
        timer.invalidate()
        secondsPassed = 0
        progressBarLabel.text = "0 %"
        timer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(progressBarUpdate), userInfo: nil, repeats: true)
        ipAdresModalArray.removeAll()
        tableView.reloadData()
        
        pinger(index: 0)
        restartButton.alpha = 0.5
        stopButton.isEnabled = true
        stopButton.alpha = 1
        filterButton.isEnabled = false
        filterButton.alpha = 0.5
        searchBarHeight.constant = 0
        
    }
    
    @IBAction func stopButtonClicked(_ sender: UIButton) {

        ping?.stopPinging()
        timer.invalidate()
        stopButton.isEnabled = false
        stopButton.alpha = 0.5
        restartButton.isEnabled = true
        restartButton.alpha = 1
        filterButton.isEnabled = true
        filterButton.alpha = 1
        searchBarHeight.constant = 0
        
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
    
   
    
    @objc func progressBarUpdate(){
        
        if ipAdresses.isEmpty == false {
            
            totalTime = ipAdresses.count
            
            if secondsPassed < totalTime!{
                
                secondsPassed += 1
                progressView.progress = Float(secondsPassed) / Float(totalTime!)
                progressBarLabel.text = String (Int(progressView.progress * 100)) + "%"
                
            }else{
                timer.invalidate()
                secondsPassed = 0
                stopButton.isEnabled = false
                stopButton.alpha = 0.5
                filterButton.isEnabled = true
                
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
        desiredIPindex = nil //my targerCount didnt work so I try to do some control with this. Defaults is nil
        
         ping = try? SwiftyPing(host: ipAdresses[index], configuration: PingConfiguration(interval: 0.1, with: 1), queue: DispatchQueue.global())
            ping?.observer = { (response) in

                var message = ""
                if response.error != nil {

                    print(response.error!)
                    print("not reachable \(response.ipAddress!)")
                    message = "Unreachable "
                    self.ping?.stopPinging()
                    
                    self.checkDesiredIPIndexIsActive(index: index, desiredIP: self.desiredIPindex)
                    
                } else {
                    print(response.ipAddress!)
                    print("Reachable")
                    message = "Reachable"
                    self.ping?.stopPinging()
                    
                    self.checkDesiredIPIndexIsActive(index: index, desiredIP: self.desiredIPindex)
                }
                self.result = IpAdressModal(address: self.ipAdresses[index], success: message)
                self.ipAdresModalArray.append(self.result!)
                self.filteredArray = self.ipAdresModalArray
                
                DispatchQueue.main.async {
                self.tableView.reloadData()
                }
                
            }

        ping?.targetCount = 1 // It doesn't work I realy can't figure out why..

        try? ping?.startPinging()


    }
   
    

}

extension PingViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering ? filteredArray.count : ipAdresModalArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "pingCell", for: indexPath) as! pingTableViewCell
        let user = isFiltering ? filteredArray[indexPath.row] : ipAdresModalArray[indexPath.row]
        
        cell.IPStatusText.text = user.success
        cell.IPText.text = user.address
        
        if (indexPath.row % 2) != 0 { //index'i çift olanları beyaz diğerlerini açık gri yap
            cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }else{
            cell.backgroundColor = #colorLiteral(red: 0.9549764661, green: 0.9549764661, blue: 0.9549764661, alpha: 1)
        }
        
        return cell
    }
    
    
}
extension PingViewController:UISearchBarDelegate{

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        updateSearchResults(searchText: searchText)
        
    }
   

    func updateSearchResults(searchText: String) {
        
        if searchText.isEmpty {
            
            filteredArray.removeAll()
            
            isFiltering = false
            
        } else {
            
            if searchText.starts(with: "rea") {
                
                filteredArray = ipAdresModalArray.filter { $0.success.starts(with: "Rea")}
//                filteredArray = ipAdresModalArray.filter{$0.success.range(of: searchText, options: .caseInsensitive) != nil}
                
                isFiltering = true
//                    .filter { $0.contains("lo") }
            }else if searchText.contains("un") || searchText.contains("Un"){
                filteredArray = ipAdresModalArray.filter { $0.success.starts(with: "Un") }
                
                isFiltering = true
            }else{
                
                filteredArray = ipAdresModalArray.filter{$0.address.range(of: searchText, options: .caseInsensitive) != nil }
                
                isFiltering = true
            }
        
        }
        
        self.tableView.reloadData()
    }
}

