//
//  DemoViewController.swift
//  test-wryg
//
//  Created by Jeff Liu on 11/30/18.
//  Copyright © 2018 Jeff Liu. All rights reserved.
//

import UIKit
import Branch

class DemoViewController: UIViewController {
    
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var textField2: UITextField!
    
    @IBOutlet weak var linkdataLebel: UILabel!
    
    var buo:BranchUniversalObject! = nil
    let lp: BranchLinkProperties = BranchLinkProperties()
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Branch
        let date = Date()
        let calendar = Calendar.current
        
        
        DispatchQueue.main.async {
            self.textField2.text = self.appDelegate.branch_param_value
        }
        
        let timestamp:String = String(date.timeIntervalSinceReferenceDate)
        //CPID
        Branch.getInstance().crossPlatformIdData{ (data)->() in
            print("CPID")
            let cpid = data as? BranchCrossPlatformID
            print(cpid?.crossPlatformID)
            DispatchQueue.main.async {
               self.textField.text = cpid?.crossPlatformID ?? "cpid-nil"
            }

        }
        
        
        // Create a BranchUniversalObject with your content data:
        let branchUniversalObject = BranchUniversalObject.init()
        
        // ...add data to the branchUniversalObject as needed...
        branchUniversalObject.canonicalIdentifier = "item/12345"
        branchUniversalObject.contentMetadata.price = 1.5
        branchUniversalObject.contentMetadata.customMetadata = ["ProductCategory":"ProductCategory name"]
        
        //Create Content Reference
        buo = BranchUniversalObject.init(canonicalIdentifier:timestamp)
        buo.title = String(calendar.component(.month, from: date))
        buo.contentDescription = String(calendar.component(.day, from: date))
        buo.imageUrl = "https://i.ebayimg.com/images/g/iHgAAOSwH3haJD4L/s-l300.jpg"
        buo.publiclyIndex = true
        buo.locallyIndex = true
        buo.contentMetadata.customMetadata["name"] = "link"
        
        //
        
    }
    
    @IBAction func share(_ sender: UIButton) {
        let event = BranchEvent.standardEvent(.viewItems)
        /*
        let event = BranchEvent.customEvent(withName: "share_attempt", contentItem: buo)
        event.customData["date"] = DateFormatter().string(from: Date())
        event.logEvent()
        */
        let message = "Check out this link"
        buo.showShareSheet(with: lp, andShareText: message, from: self) { (activityType, completed) in
            print(activityType ?? "")
        }
    }
    
    @IBAction func trackCustom(_ sender: UIButton){
        let event = BranchEvent.customEvent(withName:"book_class")
        event.customData["class"] = "basic yoga"
        event.customData["instructor"] = "Jeff Liu"
        event.logEvent()
    }
    
    @IBAction func trackCommerce(_ sender: UIButton){
        let branchUniversalObject = BranchUniversalObject.init()
        
        // ...add data to the branchUniversalObject as needed...
        branchUniversalObject.canonicalUrl        = "https://whereyogi.com"
        branchUniversalObject.title               = "Whereyogi Item1"
        
        branchUniversalObject.contentMetadata.contentSchema     = .commerceProduct
        branchUniversalObject.contentMetadata.quantity          = 1
        branchUniversalObject.contentMetadata.price             = 23.20
        branchUniversalObject.contentMetadata.currency          = .USD
        branchUniversalObject.contentMetadata.sku               = "wherehyogi1231"
        
        // Create a BranchEvent:
        let event = BranchEvent.standardEvent(.purchase)
        
        // Add the BranchUniversalObjects with the content:
        event.contentItems     = [ branchUniversalObject ]
        
        // Add relevant event data:
        event.transactionID    = "12344555"
        event.currency         = .USD
        event.revenue          = 1.5
        event.shipping         = 10.2
        event.tax              = 12.3
        event.customData       = [
            "foo": "bar",
            "test1": "1o1"
        ]
        event.logEvent() // Log the event.
    }
    
    
    @IBAction func poplinkdata(_ sender:UIButton){
        let alert = UIAlertController(title: "Linke data",
                                      message: appDelegate.branch_param_value,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: nil))

        self.present(alert, animated: true)
    }
}
