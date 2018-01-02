//
//  ViewController.swift
//  ChineseIDValidator
//
//  Created by ray on 2017/12/28.
//  Copyright © 2017年 ray. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let id = "123456789012345678"
        
        let validator = id.CNIDValidator(withTypeOption: .both) // typeOption: 验证的类型，可以是老15位，或者新18位，默认都选
        let isValid = validator.isValid // 看是否合法
        if isValid {
            let info = validator.info!
            let type = info.type
            let district1Name = info.districtInfo[.district1]?.name
            let district2Name = info.districtInfo[.district2]?.name
            let district3Name = info.districtInfo[.district3]?.name
            let birthdayDateString = info.birthDayInfo.dateString
            let birthdayDate = info.birthDayInfo.date
            let gender = info.gender
        }
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

