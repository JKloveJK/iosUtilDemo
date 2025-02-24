//
//  LaunchScreenViewController.swift
//  iosUtilDemo
//
//  Created by Jiankai Lei on 2025/2/21.
//

import Foundation
import UIKit

class LaunchScreenViewController: UIViewController {
    
    private lazy var launchView: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.5)
        return view
    }()
    
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "launch")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "微信"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startAnimation()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(launchView)
        view.addSubview(logoImageView)
        view.addSubview(titleLabel)
        
        launchView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        logoImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(100)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
    }
    
    private func startAnimation() {
        // Logo缩放动画
        logoImageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseOut) {
            self.logoImageView.transform = .identity
        }
        
        // 标题淡入动画
        UIView.animate(withDuration: 0.3, delay: 0.5) {
            self.titleLabel.alpha = 1
        }
    }
}
