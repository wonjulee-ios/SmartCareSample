//
//  BpMeasureViewController.swift
//  SmartCareSample
//
//  Created by philosys_macbook on 2020/08/28.
//  Copyright © 2020 philosys. All rights reserved.
//

import UIKit
import SmartCareCom
import Resource

class BpMeasureViewController: UIViewController {

    @IBOutlet weak var vContent: UIView!
    @IBOutlet weak var vOuter: UIView!
    @IBOutlet weak var imgTopDevice: UIImageView!
    @IBOutlet weak var lblMiddle: UILabel!
    @IBOutlet weak var imgBottomDevice: UIImageView!
    var deviceType:BloodPressManager.DeviceType!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if deviceType == .AnD {
            imgTopDevice.image = R.Image.imgMeasureDevice1P2
            imgBottomDevice.image = R.Image.imgMeasureDevice1P1
            lblMiddle.text = "착용 후, “START” 버튼을 눌러주세요.\n(누르신 후, 35-40초 정도 기다려주세요.)"
        } else {
            imgTopDevice.image = R.Image.imgMeasureDevice2P2
            imgBottomDevice.image = R.Image.imgMeasureDevice2P1
            lblMiddle.text = "압박대를 왼쪽 팔뚝에 착용 후,\n혈압계의 시작(START) 버튼을 누릅니다."
        }
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
