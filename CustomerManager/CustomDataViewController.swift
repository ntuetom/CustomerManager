//
//  CustomDataViewController.swift
//  CustomerManager
//
//  Created by Wu hung-yi on 19/03/2018.
//  Copyright © 2018 Wu. All rights reserved.
//

import UIKit

protocol SwipeDelegate {
    func onSwipe(gestureRecognizer: UISwipeGestureRecognizer)
}

class CustomDataViewController: UIViewController,SwipeDelegate{
    
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelTel: UILabel!
    @IBOutlet weak var labeDate: UILabel!
    
    var editDataBarbutton:UIBarButtonItem!
    
    var data:CustomData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        labelName.text = data.name
        labelTel.text = data.tel
        
        editDataBarbutton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(onBarButtonClick))
        let swiperight: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(onSwipe(gestureRecognizer:)))
        swiperight.direction = .right
        self.view!.addGestureRecognizer(swiperight)
        self.navigationItem.setRightBarButton(editDataBarbutton, animated: true)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func onSwipe(gestureRecognizer: UISwipeGestureRecognizer){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func onBarButtonClick(){
        if let addDataViewController = self.storyboard?.instantiateViewController(withIdentifier:
            "EditDataViewController") as? CustomDataViewController{
            addDataViewController.pageType = CorrectType.Edit
            self.navigationController?.pushViewController(addDataViewController, animated: true)
        }
    }
    
    func switchToCustomDataPage(){
        
    }

}
