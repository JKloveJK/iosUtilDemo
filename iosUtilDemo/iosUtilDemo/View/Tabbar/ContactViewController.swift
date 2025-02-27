//
//  ContactViewController.swift
//  iosUtilDemo
//
//  Created by Jiankai Lei on 2025/2/18.
//

import Foundation
import UIKit
import SnapKit

class FriendCell: UITableViewCell {
    static let reuseIdentifier = "FriendCell"
    
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 5
        iv.layer.masksToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        
        avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(40)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualToSuperview().offset(-16)
        }
    }
    
    func configure(with friend: Friend) {
        nameLabel.text = friend.displayName
        avatarImageView.kf.setImage(with: URL(string: friend.avatar))
    }
}

class FunctionCell: UITableViewCell {
    static let reuseIdentifier = "FunctionCell"
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .systemBlue
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let accessoryImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.tintColor = .lightGray
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(accessoryImageView)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            iconImageView.heightAnchor.constraint(equalToConstant: 28),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            accessoryImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            accessoryImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(for index: Int) {
        let functions = [
            ("person.badge.plus", "新的朋友"),
            ("person.3", "群聊"),
            ("tag", "标签")
        ]
        iconImageView.image = UIImage(systemName: functions[index].0)
        titleLabel.text = functions[index].1
    }
}

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
    
    private let viewModel = FriendsViewModel()
    private var tableView: UITableView!
    private let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        setupSearchController()
    }
    
    private func setupNavigationBar() {
        title = "通讯录"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "person.crop.circle.badge.plus"),
            style: .plain,
            target: self,
            action: #selector(addFriendButtonTapped)
        )
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        tableView.register(FriendCell.self, forCellReuseIdentifier: FriendCell.reuseIdentifier)
        tableView.register(FunctionCell.self, forCellReuseIdentifier: FunctionCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.sectionIndexColor = .systemBlue
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    @objc private func addFriendButtonTapped() {
        // 处理添加好友逻辑
    }
}

extension ContactViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count + 1 // 增加功能入口section
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3 // 新的朋友、群聊、标签
        }
        return viewModel.sections[section - 1].friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: FunctionCell.reuseIdentifier, for: indexPath) as! FunctionCell
            cell.configure(for: indexPath.row)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendCell.reuseIdentifier, for: indexPath) as! FriendCell
        let friend = viewModel.sections[indexPath.section - 1].friends[indexPath.row]
        cell.configure(with: friend)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section > 0 else { return nil }
        return viewModel.sections[section - 1].title
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return viewModel.sections.map { $0.title }
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index + 1 // 跳过第一个功能入口section
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 处理点击事件
    }
}

extension ContactViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // 实现搜索过滤逻辑
    }
}
