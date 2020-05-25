//
//  SignUpViewController.swift
//  InstgramFirebase
//
//  Created by Peter Bassem on 5/8/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    
    let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handlePlusPhototButtonPress(_:)), for: .touchUpInside)
        return button
    }()
    
    let emailTextField: UITextField = {
        let textFiled = UITextField()
        textFiled.placeholder = "Email"
        textFiled.backgroundColor = UIColor(white: 0, alpha: 0.03)
        textFiled.borderStyle = .roundedRect
        textFiled.font = UIFont.systemFont(ofSize: 14)
        textFiled.addTarget(self, action: #selector(handleInputTextChanged(_:)), for: .editingChanged)
        return textFiled
    }()
    
    let usernameTextField: UITextField = {
        let textFiled = UITextField()
        textFiled.placeholder = "Username"
        textFiled.backgroundColor = UIColor(white: 0, alpha: 0.03)
        textFiled.borderStyle = .roundedRect
        textFiled.font = UIFont.systemFont(ofSize: 14)
        textFiled.addTarget(self, action: #selector(handleInputTextChanged(_:)), for: .editingChanged)
        return textFiled
    }()
    
    let passwordTextField: UITextField = {
        let textFiled = UITextField()
        textFiled.placeholder = "Password"
        textFiled.isSecureTextEntry = true
        textFiled.backgroundColor = UIColor(white: 0, alpha: 0.03)
        textFiled.borderStyle = .roundedRect
        textFiled.font = UIFont.systemFont(ofSize: 14)
        textFiled.addTarget(self, action: #selector(handleInputTextChanged(_:)), for: .editingChanged)
        return textFiled
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleSignUpButtonPress(_:)), for: .touchUpInside)
        return button
    }()
    
    let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Already have account?  ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Sign in", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.mainBlue()]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.addTarget(self, action: #selector(handleAlreadyHaveAccountButtonPress(_:)), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        
        view.addSubview(plusPhotoButton)
        NSLayoutConstraint.activate([
            plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        plusPhotoButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        setupInputFields()
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(top: nil, left: view.leadingAnchor, bottom: view.bottomAnchor, right: view.trailingAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 0, height: 50)
    }
    
    private func setupInputFields() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, usernameTextField, passwordTextField, signUpButton])
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        view.addSubview(stackView)
        stackView.anchor(top: plusPhotoButton.bottomAnchor, left: view.leadingAnchor, bottom: nil, right: view.trailingAnchor, paddingTop: 20, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 200)
    }
    
    @objc private func handlePlusPhototButtonPress(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.modalPresentationStyle = .fullScreen
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc private func handleInputTextChanged(_ sender: UITextField) {
        let isFormValid = emailTextField.text?.count ?? 0 > 0 && usernameTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0
        if isFormValid {
            signUpButton.backgroundColor = .mainBlue()
            signUpButton.isEnabled = true
        } else {
            signUpButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
            signUpButton.isEnabled = false
        }
    }
    
    @objc private func handleSignUpButtonPress(_ sender: UIButton) {
        guard let email = emailTextField.text, email.count > 0, let username = usernameTextField.text, username.count > 0, let password = passwordTextField.text, password.count > 0 else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user: AuthDataResult?, error: Error?) in
            if let error = error {
                print("Failed to create user", error)
                return
            }
            print("Successfully created user:", user?.user.uid ?? "")
            
            guard let image = self.plusPhotoButton.imageView?.image else { return }
            guard let uploadData = image.jpegData(compressionQuality: 0.8) else { return }
            let imageName = UUID().uuidString
            
            let storageRef = Storage.storage().reference().child("profile_images").child(imageName)
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            storageRef.putData(uploadData, metadata: nil) { (storageMetadata, error) in
                if let error = error {
                    print("failed to upload profile image:", error)
                    return
                }
                storageRef.downloadURL { (url, error) in
                    if let error = error {
                        print("failed to get profile image url:", error)
                        return
                    }
                    guard let profileImageUrl = url?.absoluteString else { return }
                    print("Successfully uploaded profile image", profileImageUrl)
                    
                    guard let fcmToken = Messaging.messaging().fcmToken else { return }
                    
                    guard let uid = user?.user.uid else { return }
                    let dictionaryValues = ["username": username, "profileImageUrl": profileImageUrl, "fcmToken": fcmToken]
                    let values = [uid: dictionaryValues]
                    Database.database().reference().child("users").updateChildValues(values) { (error, databaseReference) in
                        if let error = error {
                            print("failed to save user info iinto db:", error.localizedDescription)
                            return
                        }
                        print("successfully saved user into db")
                        
                        guard let mainTabBarViewController = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first?.rootViewController as? MainTabBarViewController else { return }
                        
                        mainTabBarViewController.setupViewControllers()
                        
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @objc private func handleAlreadyHaveAccountButtonPress(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            plusPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            plusPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.height / 2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.black.cgColor
        plusPhotoButton.layer.borderWidth = 3
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
}

