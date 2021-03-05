//
//  UserListViewController.swift
//  tawkApp
//
//  Created by Eugene Shapovalov on 02.03.2021.
//

import UIKit
import Combine

class UserListViewController: UIViewController {

    //Properties
    var viewModel: UserListViewModel
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var isSearchBarEmpty: Bool {
        return self.searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    private let tableView = UITableView()
    private var subscriptions = Set<AnyCancellable>()
    private let normalCell = "normalCell"
    private let noteCell = "noteCell"
    private let isOpenCell = "isOpenCell"
    private var filteredUsers = [UserViewModel]()
    
    required init(viewModel: UserListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
        viewModel.observNote()
        binding()
    }
    
    // Setup view
    private func setupView() {
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.searchBarStyle = .minimal
        searchController.searchResultsUpdater = self
        self.navigationItem.titleView = self.searchController.searchBar
        self.definesPresentationContext = true
    }
    
    // Setup table view
    private func setupTableView() {
        tableView.register(UINib(nibName: "NormalTableViewCell", bundle: nil), forCellReuseIdentifier: normalCell)
        tableView.register(UINib(nibName: "NoteTableViewCell", bundle: nil), forCellReuseIdentifier: noteCell)
        tableView.register(UINib(nibName: "InvertedTableViewCell", bundle: nil), forCellReuseIdentifier: isOpenCell)
        self.view.addSubview(self.tableView)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
    }
    
    func filterContentForSearchText(_ searchText: String,
                                    category: User? = nil) {
        filteredUsers = viewModel.dataSource.value.filter { (user: UserViewModel) -> Bool in
            return (user.userName?.lowercased().contains(searchText.lowercased()) ?? true)
        }
        
        tableView.reloadData()
    }
    
    func binding() {
        viewModel.dataSource.sink { [unowned self] _ in
            self.tableView.reloadData()
        }
        .store(in: &self.subscriptions)
        
        viewModel.updateData.sink { [unowned self] _ in
            self.viewModel.observUserData()
        }
        .store(in: &self.subscriptions)
        
     

    }
}

extension UserListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering ? filteredUsers.count : viewModel.dataSource.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellModel = viewModel.dataSource.value[indexPath.row]
        let user = isFiltering ? self.filteredUsers[indexPath.row] : viewModel.dataSource.value[indexPath.row]
        let shouldInvert = (indexPath.row + 1) % 4 == 0 && indexPath.row > 0
        
        switch cellModel.type {
            case .normal:
                let cell = tableView.dequeueReusableCell(withIdentifier: normalCell, for: indexPath) as! NormalTableViewCell
                cell.configCell(user, invert: shouldInvert)
                return cell
            case .note:
                let cell = tableView.dequeueReusableCell(withIdentifier: noteCell, for: indexPath) as! NoteTableViewCell
                cell.configCell(user, invert: shouldInvert)
                return cell
            case .open:
                let cell = tableView.dequeueReusableCell(withIdentifier: isOpenCell, for: indexPath) as! InvertedTableViewCell
                cell.configCell(user, invert: shouldInvert)
                return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let reachability = try? Reachability(), reachability.connection == .unavailable {
            return
        }
        
        let lastItem = self.viewModel.dataSource.value.count - 1
        if indexPath.row == lastItem {
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.startAnimating()
            spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
            tableView.tableFooterView = spinner
            
            viewModel.getMoreUser()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                tableView.tableFooterView = nil
            }
        }
    }
}

extension UserListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isFiltering {
            if self.filteredUsers.count > indexPath.row {
                let user = self.filteredUsers[indexPath.row].userName
                viewModel.selectUserName = user ?? ""
            }
        } else {
            if self.viewModel.dataSource.value.count > indexPath.row {
                let user = self.viewModel.dataSource.value[indexPath.row].userName
                viewModel.selectUserName = user ?? ""
            }
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Pagination
        let distance = scrollView.contentSize.height - (targetContentOffset.pointee.y + scrollView.bounds.height)
        if distance < 200 {
            viewModel.getMoreUser()
        }
    }
}

// MARK: - UISearchBarDelegate
extension UserListViewController: UISearchBarDelegate {
    
}

extension UserListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
}
