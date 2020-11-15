//
//  pingTableViewCell.swift
//  ios_assignment_pinger
//
//  Created by Cem Sezeroglu on 15.11.2020.
//

import UIKit

class pingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var IPText: UILabel!
    @IBOutlet weak var IPStatusText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        changeBackGroundColor()
        // Configure the view for the selected state
    }
    
    
    func changeBackGroundColor(){
        if IPStatusText.text == "Reachable"{
            IPStatusText.textColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        }else{
            IPStatusText.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        }
        
    }

}
