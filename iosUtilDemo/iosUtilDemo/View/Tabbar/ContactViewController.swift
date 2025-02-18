//
//  ContactViewController.swift
//  iosUtilDemo
//
//  Created by Jiankai Lei on 2025/2/18.
//

import Foundation

class ContactViewController: BaseTabbarViewController {
    override var tabTitle: String {
        return "通讯录"
    }
    
    override var tabNormalImageName: String {
        return "tab_contact"
    }
    
    override var tabSelectedImageName: String {
        return "tab_contact"
    }
}
