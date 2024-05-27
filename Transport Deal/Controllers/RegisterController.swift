//
//  RegisterController.swift
//  swift-login-system-tutorial
//
//  Created by YouTube on 2022-10-26.
//


import UIKit



class RegisterController: UIViewController {
    
    // MARK: - UI Components
    
    private let headerView = AuthHeaderView(title: "Sign Up", subTitle: "Create your account")
    private let usernameField = CustomTextField(fieldType: .username)
    private let phoneNumberField = CustomTextField(fieldType: .phoneNumber)
    private let countryField = CustomDropdownField()
    private let occupationField = CustomTextField(fieldType: .occupation)
    private let emailField = CustomTextField(fieldType: .email)
    private let passwordField = CustomTextField(fieldType: .password)
    private let signUpButton = CustomButton(title: "Sign Up", hasBackground: true, fontSize: .big)
    private let signInButton = CustomButton(title: "Already have an account? Sign In.", fontSize: .med)
    private let termsTextView: UITextView = {
        let attributedString = NSMutableAttributedString(string: "By creating an account, you agree to our Terms & Conditions and you acknowledge that you have read our Privacy Policy.")
        
        attributedString.addAttribute(.link, value: "terms://termsAndConditions", range: (attributedString.string as NSString).range(of: "Terms & Conditions"))
        attributedString.addAttribute(.link, value: "privacy://privacyPolicy", range: (attributedString.string as NSString).range(of: "Privacy Policy"))
        
        let tv = UITextView()
        tv.linkTextAttributes = [.foregroundColor: UIColor.systemBlue]
        tv.backgroundColor = .clear
        tv.attributedText = attributedString
        tv.textColor = .label
        tv.isSelectable = true
        tv.isEditable = false
        tv.delaysContentTouches = false
        tv.isScrollEnabled = true
        return tv
    }()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    // MARK: - Properties

    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        termsTextView.delegate = self
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        countryField.addTarget(self, action: #selector(pickerSelectionDidChange), for: .valueChanged)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - UI Setup
  
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(headerView)
        view.addSubview(usernameField)
        view.addSubview(phoneNumberField)
        view.addSubview(countryField)
        view.addSubview(occupationField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(signUpButton)
        view.addSubview(termsTextView)
        view.addSubview(signInButton)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        usernameField.translatesAutoresizingMaskIntoConstraints = false
        phoneNumberField.translatesAutoresizingMaskIntoConstraints = false
        countryField.translatesAutoresizingMaskIntoConstraints = false
        occupationField.translatesAutoresizingMaskIntoConstraints = false
        emailField.translatesAutoresizingMaskIntoConstraints = false
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        termsTextView.translatesAutoresizingMaskIntoConstraints = false
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.headerView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
            self.headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.headerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.headerView.heightAnchor.constraint(equalToConstant: 222),
            
            self.usernameField.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 12),
            self.usernameField.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.usernameField.heightAnchor.constraint(equalToConstant: 55),
            self.usernameField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            self.countryField.topAnchor.constraint(equalTo: usernameField.bottomAnchor, constant: 12),
            self.countryField.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.countryField.heightAnchor.constraint(equalToConstant: 55),
            self.countryField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            self.phoneNumberField.topAnchor.constraint(equalTo: countryField.bottomAnchor, constant: 12),
            self.phoneNumberField.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.phoneNumberField.heightAnchor.constraint(equalToConstant: 55),
            self.phoneNumberField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            self.occupationField.topAnchor.constraint(equalTo: phoneNumberField.bottomAnchor, constant: 12),
            self.occupationField.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.occupationField.heightAnchor.constraint(equalToConstant: 55),
            self.occupationField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            self.emailField.topAnchor.constraint(equalTo: occupationField.bottomAnchor, constant: 12),
            self.emailField.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.emailField.heightAnchor.constraint(equalToConstant: 55),
            self.emailField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            self.passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 12),
            self.passwordField.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.passwordField.heightAnchor.constraint(equalToConstant: 55),
            self.passwordField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            self.signUpButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 22),
            self.signUpButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.signUpButton.heightAnchor.constraint(equalToConstant: 55),
            self.signUpButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            self.termsTextView.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 6),
            self.termsTextView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.termsTextView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            
            self.signInButton.topAnchor.constraint(equalTo: termsTextView.bottomAnchor, constant: 11),
            self.signInButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.signInButton.heightAnchor.constraint(equalToConstant: 44),
            self.signInButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
        ])
    }
    
    // MARK: - Selectors
    
    private let countryPickerView = CountryPickerView()
    
    @objc private func pickerSelectionDidChange() {
        if let dropdownField = self.view.subviews.first(where: { $0 is CustomDropdownField }) as? CustomDropdownField {
            dropdownField.text = countryPickerView.selectedCountry ?? ""
        }
        
    }
    
    func isValidEmail(_ email: String) -> Bool {
        // Regular expression pattern for email validation
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
        @objc func didTapSignUp() {
        // Check if any fields are empty
            guard let name = usernameField.text, !name.isEmpty else {
                  showErrorAlert(message: "Please enter a username")
                  return
              }
              guard let email = emailField.text, !email.isEmpty else {
                  showErrorAlert(message: "Please enter an email address")
                  return
              }
              guard isValidEmail(email) else {
                  showErrorAlert(message: "Please enter a valid email address")
                  return
              }
        guard let password = passwordField.text, !password.isEmpty else {
            showErrorAlert(message: "Please enter a password")
            return
        }
        guard let country = countryField.text, !country.isEmpty else {
            showErrorAlert(message: "Please enter a country")
            return
        }
        guard let phoneNumber = phoneNumberField.text, !phoneNumber.isEmpty else {
            showErrorAlert(message: "Please enter a phone number")
            return
        }
        guard let occupation = occupationField.text, !occupation.isEmpty else {
            showErrorAlert(message: "Please enter an occupation")
            return
        }
        
        // Create the parameters dictionary
        let parameters: [String: Any] = [
            "name": name,
            "email": email,
            "password": password,
            "country" : country,
            "phoneNumber" : phoneNumber,
            "occupation" : occupation,
        ]
        
        // Create the URL request
        guard let url = URL(string: "https://admin-backend-4eyl.onrender.com/useregister") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        request.httpBody = httpBody
        
        // Send the request
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            // Handle the response
            guard let self = self else { return }
            if let error = error {
                print(error)
                return
            }
            guard let response = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }
            if !(200...299).contains(response.statusCode) {
                if response.statusCode == 400 {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.showErrorAlert(message: "Email already in use.")
                    }
                } else {
                    print("Server Error - status code: \(response.statusCode)")
                }
                return
            }

            guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                print("Invalid data")
                return
            }
            guard let message = json["message"] as? String else {
                print("Invalid message")
                return
            }
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
        task.resume()
    }

    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    @objc private func didTapSignIn() {
        let vc = LoginController()
        
        if let navigationController = self.navigationController {
            navigationController.pushViewController(vc, animated: true)
        } else {
            // If the current view controller is not embedded in a navigation controller,
            // present the RegisterController modally
            let navController = UINavigationController(rootViewController: vc)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
        }
    }
    
}

extension RegisterController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        if URL.scheme == "terms" {
            self.showWebViewerController(with: "https://policies.google.com/terms?hl=en")
        } else if URL.scheme == "privacy" {
            self.showWebViewerController(with: "https://policies.google.com/privacy?hl=en")
        }
        
        return true
    }
    
    private func showWebViewerController(with urlString: String) {
        let vc = WebViewerController(with: urlString)
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
    }
    
   
}
