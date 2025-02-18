//
//  MeViewController.swift
//  iosUtilDemo
//
//  Created by Jiankai Lei on 2025/2/18.
//

import Foundation
import UIKit

class MeViewController: BaseTabbarViewController {
    
    override var tabTitle: String {
        return "我"
    }
    
    override var tabNormalImageName: String {
        return "tab_me"
    }
    
    override var tabSelectedImageName: String {
        return "tab_me"
    }
}
