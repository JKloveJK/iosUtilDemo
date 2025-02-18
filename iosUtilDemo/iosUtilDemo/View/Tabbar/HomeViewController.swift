//
//  HomeViewController.swift
//  iosUtilDemo
//
//  Created by Jiankai Lei on 2025/2/18.
//

import Foundation

class HomeViewController: BaseTabbarViewController {
    
    override var tabTitle: String {
        return "微信"
    }
    
//    override var tabTitle: String {
//        return "首页"
//    }
    
    override var tabNormalImageName: String {
        return "tab_home"
    }
    
    override var tabSelectedImageName: String {
        return "tab_home"
    }
}
