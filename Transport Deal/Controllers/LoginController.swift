import UIKit
import SwiftUI

class LoginController: UIViewController {

    // MARK: - UI Components
    private let headerView = AuthHeaderView(title: "Sign In", subTitle: "Sign in to your account")

    private let emailField = CustomTextField(fieldType: .email)

    private let passwordField = CustomTextField(fieldType: .password)

    private let signInButton = CustomButton(title: "Sign In", hasBackground: true, fontSize: .big)
    private let newUserButton = CustomButton(title: "New User? Create Account.", fontSize: .med)
    private let forgotPasswordButton = CustomButton(title: "Forgot Password?", fontSize: .small)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    private let signInProgressBar: UIProgressView = {
        let progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.isHidden = true
        progressBar.progress = 0.0
        return progressBar
   
    }()

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()

        self.signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        self.newUserButton.addTarget(self, action: #selector(didTapNewUser), for: .touchUpInside)
        self.forgotPasswordButton.addTarget(self, action: #selector(didTapForgotPassword), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

    // MARK: - UI Setup
    private func setupUI() {
        self.view.backgroundColor = .systemBackground

        self.view.addSubview(emailField)
        self.view.addSubview(headerView)
        self.view.addSubview(emailField)
        self.view.addSubview(passwordField)
        self.view.addSubview(signInButton)
        self.view.addSubview(newUserButton)
        self.view.addSubview(forgotPasswordButton)
        self.view.addSubview(signInProgressBar)

        headerView.translatesAutoresizingMaskIntoConstraints = false
        emailField.translatesAutoresizingMaskIntoConstraints = false
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        newUserButton.translatesAutoresizingMaskIntoConstraints = false
        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        signInProgressBar.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.headerView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
            self.headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.headerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.headerView.heightAnchor.constraint(equalToConstant: 222),

            self.emailField.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 12),
            self.emailField.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.emailField.heightAnchor.constraint(equalToConstant: 55),
            self.emailField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),

            self.passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 22),
            self.passwordField.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.passwordField.heightAnchor.constraint(equalToConstant: 55),
            self.passwordField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),

            self.signInButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 22),
            self.signInButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.signInButton.heightAnchor.constraint(equalToConstant: 55),
            self.signInButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),

            self.newUserButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 11),
            self.newUserButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.newUserButton.heightAnchor.constraint(equalToConstant: 44),
            self.newUserButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),

            self.forgotPasswordButton.topAnchor.constraint(equalTo: newUserButton.bottomAnchor, constant: 6),
            self.forgotPasswordButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.forgotPasswordButton.heightAnchor.constraint(equalToConstant: 44),
            self.forgotPasswordButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),

            self.signInProgressBar.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 8),
            self.signInProgressBar.centerXAnchor.constraint(equalTo: signInButton.centerXAnchor),
            self.signInProgressBar.widthAnchor.constraint(equalTo: signInButton.widthAnchor),
            self.signInProgressBar.heightAnchor.constraint(equalToConstant: 4)
        ])
    }

    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Selectors
    @objc private func didTapSignIn() {
        let userEmail = self.emailField.text!
        UserDefaults.standard.set(userEmail, forKey: "userEmail")
        let url = URL(string: "https://admin-backend-4eyl.onrender.com/userlogin")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters: [String: Any] = [
            "email": emailField.text!,
            "password": passwordField.text!
        ]
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            if let error = error {
                print(error)
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "Connection Error, please check internet connection")
                }
                return
            }
            guard let response = response as? HTTPURLResponse else {
                print("Invalid response")
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "Invalid response")
                }
                return
            }
            if !(200...299).contains(response.statusCode) {
                if response.statusCode == 400 {
                    DispatchQueue.main.async {
                        self.showErrorAlert(message: "Email or Password incorrect, please check it and try again!")
                    }
                } else {
                    print("Server Error - status code: \(response.statusCode)")
                    DispatchQueue.main.async {
                        self.showErrorAlert(message: "Server Error - status code: \(response.statusCode)")
                    }
                }
                return
            }

            guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                print("Invalid data")
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "Invalid data")
                }
                return
            }
            guard let token = json["token"] as? String else {
                print("Invalid token")
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "Invalid token")
                }
                return
            }

            DispatchQueue.main.async {
                self.signInProgressBar.isHidden = false
                self.signInProgressBar.setProgress(1.0, animated: true)
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (timer) in
                    // Save token to UserDefaults
                    UserDefaults.standard.set(token, forKey: "token")
                    UserDefaults.standard.set(self.emailField.text!, forKey: "userEmail") // Save the user's email to UserDefaults

                    let vc = ContentView()
                    let hostingController = UIHostingController(rootView: vc)

                    // Check if the current view controller is embedded in a navigation controller
                    if let navigationController = self.navigationController {
                        navigationController.setViewControllers([hostingController], animated: true)
                    } else {
                        // If not embedded in a navigation controller, create a new navigation controller with hostingController as the root view controller
                        let navController = UINavigationController(rootViewController: hostingController)
                        navController.modalPresentationStyle = .fullScreen
                        self.present(navController, animated: true, completion: nil)
                    }
                }
            }
        }
        task.resume()
    }

    @objc private func didTapNewUser() {
        let vc = RegisterController()

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

    @objc private func didTapForgotPassword() {
        let vc = ForgotPasswordController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
