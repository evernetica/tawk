//
//  UserDetailsViewController.swift
//  tawkApp
//
//  Created by Eugene Shapovalov on 04.03.2021.
//

import UIKit
import Combine

class UserDetailsViewController: UIViewController {
    
    var viewModel: UserDetailsViewModel
    var listViewModel = UserListViewModel()
    private var subscriptions = Set<AnyCancellable>()
    private var cancellable: AnyCancellable?
    var bottomConstraint: NSLayoutConstraint?
    
    var avatarImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(systemName: "photo")
        return image
    }()
    var avatarImageViewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var followersLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "followersLabel"
        label.textAlignment = .center
        return label
    }()
    var followingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "followingLabel"
        label.textAlignment = .center
        return label
    }()
    var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "nameLabel"
        return label
    }()
    var companyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "companyLabel"
        return label
    }()
    var blogLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "blogLabel"
        return label
    }()
    var notesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Notes:"
        return label
    }()
    var notesLabelContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var notesTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    var saveNoteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .black
        button.isEnabled = true
        button.setTitle("Save note", for: .normal)
        return button
    }()
    var saveNoteButtonContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var stackViewVertical: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    var stackViewHorizontal: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = NSLayoutConstraint.Axis.horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 10.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true
        scrollView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        return scrollView
    }()
 
    required init(viewModel: UserDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.getDetails()
        setupView()
        setupLayout()
        keyboardSetupControl()
        binding()
    }
    
    private func binding() {
        viewModel.$userDetails.sink { (userInfo) in
            self.followersLabel.text = "followers: \(userInfo?.followers ?? 0)"
            self.followingLabel.text = "following: \(userInfo?.following ?? 0)"
            self.nameLabel.text = "Name: \(userInfo?.name ?? "")"
            self.companyLabel.text = "Company: \(userInfo?.company ?? "")"
            self.blogLabel.text = "Blog: \(userInfo?.blog ?? "")"
            guard let url = URL(string: userInfo?.avatarURL ?? "") else {
                return
            }
            let imageLoader = ImageLoader.shared.loadImage(from: url )
            self.cancellable = imageLoader.sink { [weak self] image in
                self?.avatarImageView.image = image
            }
        }
        .store(in: &subscriptions)
        
        viewModel.updateList.sink { [unowned self]  _ in
            listViewModel.observUserData()
        }
        .store(in: &subscriptions)
        
        viewModel.$noteTextHandle.assign(to: \.text, on: notesTextView).store(in: &subscriptions)
    }

    private func setupView() {
        //Base setup
        title = viewModel.userName
        view.backgroundColor = .mainCellBg
        saveNoteButton.backgroundColor = .mainButtonBg
        saveNoteButton.setTitleColor(.mainButtonLabel, for: .normal)
        notesTextView.addDoneButton(title: "Done", target: self, selector: #selector(tapDone(sender:)))
        saveNoteButton.addTarget(self, action: #selector(saveNote), for: .touchUpInside)
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(stackViewVertical)
        
        saveNoteButtonContainer.addSubview(saveNoteButton)
        notesLabelContainer.addSubview(notesLabel)
        avatarImageViewContainer.addSubview(avatarImageView)
        
        //Horizontal stack
        stackViewHorizontal.addArrangedSubview(followersLabel)
        stackViewHorizontal.addArrangedSubview(followingLabel)
        
        //Vertical stack
        stackViewVertical.addArrangedSubview(avatarImageViewContainer)
        stackViewVertical.addArrangedSubview(stackViewHorizontal)
        stackViewVertical.addArrangedSubview(nameLabel)
        stackViewVertical.addArrangedSubview(companyLabel)
        stackViewVertical.addArrangedSubview(blogLabel)
        stackViewVertical.addArrangedSubview(notesLabelContainer)
        stackViewVertical.addArrangedSubview(notesTextView)
        stackViewVertical.addArrangedSubview(saveNoteButtonContainer)
        
        //Setup view wrap
        notesTextView.layer.borderColor = UIColor.lightGray.cgColor
        notesTextView.layer.borderWidth = 2
        notesTextView.layer.cornerRadius = 12
        saveNoteButton.layer.cornerRadius = 12
        
    }
    
    private func setupLayout() {
        bottomConstraint = scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        
        //Constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            scrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            bottomConstraint!,
            
            stackViewVertical.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            stackViewVertical.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
            stackViewVertical.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
            stackViewVertical.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
            stackViewVertical.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
            
            avatarImageViewContainer.heightAnchor.constraint(equalToConstant: 120),
            avatarImageView.topAnchor.constraint(equalTo: self.avatarImageViewContainer.topAnchor),
            avatarImageView.bottomAnchor.constraint(equalTo: self.avatarImageViewContainer.bottomAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 120),
            avatarImageView.centerXAnchor.constraint(equalTo: avatarImageViewContainer.centerXAnchor),
            
            notesLabelContainer.heightAnchor.constraint(equalToConstant: 35),
            notesLabel.bottomAnchor.constraint(equalTo: notesLabelContainer.bottomAnchor),
            notesTextView.heightAnchor.constraint(equalToConstant: 150),
            
            saveNoteButtonContainer.heightAnchor.constraint(equalToConstant: 45),
            saveNoteButton.heightAnchor.constraint(equalTo: saveNoteButtonContainer.heightAnchor),
            saveNoteButton.leadingAnchor.constraint(equalTo: saveNoteButtonContainer.leadingAnchor, constant: 35),
            saveNoteButton.trailingAnchor.constraint(equalTo: saveNoteButtonContainer.trailingAnchor, constant: -35),
        ])
    }
    
    private func keyboardSetupControl() {
        NotificationCenter.default.addObserver(self, selector: #selector(UserDetailsViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        bottomConstraint?.constant = -keyboardSize.height
        view.layoutIfNeeded()
    }
    
    @objc func tapDone(sender: Any) {
        bottomConstraint?.constant = 0
        self.view.endEditing(true)
    }
    // Save note to DB
    @objc func saveNote() {
        viewModel.noteTextHandle = notesTextView.text
        viewModel.saveNote()
        Alert.presentAlert(title: "Success", message: "Note saved", vc: self)
    }
}
