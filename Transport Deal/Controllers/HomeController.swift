import SwiftUI
import StripePaymentsUI
import UIKit
import Combine

struct Product: Codable, Equatable, Hashable {
    let name: String
    let price: Decimal
    let description: String
    let category: String
    let image: String
    let phoneno: Int
    let Km: Int
    let modelyear: Int
}

class ViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var selectedCategory: String?
    @Published var userEmail: String?
    @Published var cusid: String? = nil
    
    
    func fetchProducts() {
        guard let url = URL(string: "https://admin-backend-4eyl.onrender.com/products") else {
            return
        }
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let data = data, error == nil else {
                print("Error fetching products:", error?.localizedDescription ?? "")
                return
            }
            do {
                let decoder = JSONDecoder()
                let decodedProducts = try decoder.decode([Product].self, from: data)

                DispatchQueue.main.async {
                    self?.products = decodedProducts
                }
            } catch {
                print("Error decoding products:", error.localizedDescription)
            }
        }.resume()
    }
}

var globalCusid: String?

func fetchUser(userEmail: String, completion: @escaping (String?) -> Void) {
    guard let url = URL(string: "https://admin-backend-4eyl.onrender.com/users/cusid?email=\(userEmail)") else {
        completion(nil)
        return
    }

    URLSession.shared.dataTask(with: url) { (data, response, error) in
        if let error = error {
            print("Error fetching user:", error.localizedDescription)
            completion(nil)
            return
        }

        guard let data = data else {
            print("No data received")
            completion(nil)
            return
        }

        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            let cusid = json?["cusid"] as? String

            DispatchQueue.main.async {
                globalCusid = cusid // Global variable is updated with cusid value
                completion(cusid) // Completion handler with updated cusid value
            }
        } catch {
            print("Error decoding JSON:", error.localizedDescription)
            completion(nil)
        }
    }.resume()
}

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    @State private var userEmail: String? = nil
    @State private var cusid: String? = nil
    @State private var isKeyboardVisible = false // New state variable to track keyboard visibility

    var body: some View {
        TabView {
            HomeView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "house")
                        .foregroundColor(Color(hex: "AFD3E2"))
                    Text("Homepage")
                }
            AccountView(userEmail: userEmail, cusid: $cusid)
                .tabItem {
                    Image(systemName: "person")
                        .foregroundColor(Color(hex: "AFD3E2"))
                    Text("Account")
                }
                .onTapGesture {
                    // Resign the keyboard when tapping on "Account" tab
                    if isKeyboardVisible {
                        UIApplication.shared.windows.first?.endEditing(true)
                    }
                }
        }
        .onAppear {
            userEmail = UserDefaults.standard.string(forKey: "userEmail")
            viewModel.fetchProducts()

            if let userEmail = userEmail {
                fetchUser(userEmail: userEmail) { cusid in
                    DispatchQueue.main.async {
                        self.cusid = cusid // Update cusid value when fetchUser is completed
                    }
                }
            }
            
            // Register for keyboard notifications
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
                isKeyboardVisible = true
            }
            
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                isKeyboardVisible = false
            }
        }
    }

    func updateCusid(_ cusid: String?) {
        self.cusid = cusid
    }
}


struct HomeView: View {
    @ObservedObject var viewModel: ViewModel
    @State private var selectedCategory: String?
    @State private var searchText: String = ""
    @State private var isKeyboardVisible = false // New state variable to track keyboard visibility

    let categoryColors: [String: Color] = [
        "All": Color.blue.opacity(0.7),
        "Car": Color.blue.opacity(0.7),
        "Tractor": Color.blue.opacity(0.7),
        "Motorcycle": Color.blue.opacity(0.7)
    ]

    var filteredProducts: [Product] {
        if let selectedCategory = selectedCategory {
            return viewModel.products.filter { $0.category == selectedCategory }
        } else {
            return viewModel.products
        }
    }
    var searchedProducts: [Product] {
        if searchText.isEmpty {
            return filteredProducts
        } else {
            return filteredProducts.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 6) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.blue)
                        .padding(.leading, 8)
                    
                    TextField("Search by word or store name", text: $searchText)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: .gray, radius: 8, x: 0, y: 4)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal)
                .gesture(
                    TapGesture()
                        .onEnded { _ in
                            if isKeyboardVisible {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }
                        }
                )

                ScrollView(.horizontal, showsIndicators: false) {
                    Spacer().frame(height: 6)
                    HStack(spacing: 10) {
                        ForEach(categoryColors.keys.sorted(), id: \.self) { category in
                            Button(action: {
                                selectedCategory = category == "All" ? nil : category
                                viewModel.selectedCategory = selectedCategory
                            }) {
                                Text(category)
                                    .font(.headline)
                                    .padding(.vertical, 16)
                                    .padding(.horizontal, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(categoryColors[category] ?? Color.gray.opacity(0.02))
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                ScrollView {
                    Spacer()
                    LazyVStack(spacing: 16) {
                        ForEach(searchedProducts, id: \.self) { product in
                            NavigationLink(destination: ProductDetailsView(product: product)) {
                                ProductRowView(product: product)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
            .background(Color.white) // Background color is set here
            .refreshable {
                viewModel.fetchProducts()
            }
            .navigationBarTitleDisplayMode(.inline) // Set the navigation bar title display mode to inline
            .navigationBarTitle("Vehicles")
            .foregroundColor(.blue)
        }
        .onTapGesture {
            // Resign the keyboard when tapping outside of the search bar
            if isKeyboardVisible {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
        .onAppear {
            // Register for keyboard notifications
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
                isKeyboardVisible = true
            }
            
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                isKeyboardVisible = false
            }
            
        }
    }
}


    struct ProductDetailsView: View {
        let product: Product
        @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
        @State private var number = ""
        @State private var expMonth = 1
        @State private var expYear = 23
        @State private var cvc = ""
        @State private var showAlert = false
        @State private var alertMessage = ""
        
        func payDeposit() {
            let amount = String(describing: product.price)
            let name = product.name // Set the desired payment amount
            
            guard !number.isEmpty, !cvc.isEmpty else {
                alertMessage = "Please enter number, cvv, expiry month and expiry year"
                showAlert = true
                return
            }
            
            let params: [String: Any] = [
                "userId": globalCusid,
                "cost": amount,
                "name": name,
                "number": number,
                "cvc": cvc,
                "expmonth": expMonth,
                "expyear": expYear
            ]
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: params) else {
                print("Failed to serialize JSON")
                return
            }
            
            guard let url = URL(string: "https://admin-backend-4eyl.onrender.com/transactions") else {
                print("Invalid URL")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Error making payment:", error.localizedDescription)
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    return
                }
                
                if let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let status = responseJSON["status"] as? String {
                    DispatchQueue.main.async {
                        if status == "succeeded" {
                            alertMessage = "Payment succeeded!"
                        } else if status == "declined" {
                            alertMessage = "Your card was declined."
                        } else {
                            alertMessage = "Payment error occurred."
                        }
                        showAlert = true
                    }
                } else {
                    print("Invalid response")
                }
            }.resume()
        }
        
        
        var body: some View {
            ScrollView {
                
                VStack(alignment: .leading, spacing: 32) {
                    Spacer().frame(height: 36)
                    RemoteImage(urlString: product.image)
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(10)
                    HStack {
                        Spacer()

                        Text("Phone: \(formatPhoneNumber(product.phoneno))")
                            .font(.title2)
                            .foregroundColor(.secondary)

                        Button(action: {
                            let formattedPhoneNumber = "0" + String(product.phoneno)
                            
                            guard let url = URL(string: "tel://\(formattedPhoneNumber)"),
                                  UIApplication.shared.canOpenURL(url) else {
                                return
                            }
                            
                            UIApplication.shared.open(url)
                        }) {
                            Image(systemName: "phone.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                        }

                        Spacer()
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Spacer()
                           
                        }
                        Text("Price: ")
                            .font(.custom("Lato-Bold", size: 22))
                            .foregroundColor(.blue)
                            + Text("\(formatPrice(product.price))")
                        
                        Text("Description: ")
                            .font(.custom("Lato-Regular", size: 22))
                            .foregroundColor(.blue)
                            + Text("\(product.description)")
                        
                        Text("Category: ")
                            .font(.custom("Lato-Regular", size: 22))
                            .foregroundColor(.blue)
                            + Text("\(product.category)")
                        
                        Text("Km: ")
                            .font(.custom("Lato-Regular", size: 22))
                            .foregroundColor(.blue)
                            + Text("\(product.Km)")
                        
                        Text("Model Year: ")
                            .font(.custom("Lato-Regular", size: 22))
                            .foregroundColor(.blue)
                            + Text("\(formatModelYear(product.modelyear))")
                    }

                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .gray, radius: 8, x: 0, y: 4)
                    .fixedSize(horizontal: false, vertical: true) // Set fixed height
                    
                    
                    VStack(spacing: 16) {
                        Text("Enter your card details")
                            .font(.title)
                            .foregroundColor(.blue)
                            .font(.custom("AmericanTypewriter", size: 28)) // Set custom font
                        
                        TextField("Card Number", text: $number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        HStack(spacing: 2) {
                            Text("Month")
                                .font(.headline)
                                .font(.custom("AmericanTypewriter", size: 18)) // Set custom font
                            
                            Picker(selection: $expMonth, label: Text("Month")) {
                                ForEach(1...12, id: \.self) { month in
                                    Text("\(month)")
                                        .tag(month)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 100)
                            .clipped()
                            .cornerRadius(20)
                            .shadow(color: .gray, radius: 4, x: 0, y: 2)
                            
                            Text("Year")
                                .font(.headline)
                                .font(.custom("AmericanTypewriter", size: 18)) // Set custom font
                            
                            Picker("Expiration Year", selection: $expYear) {
                                ForEach(23...33, id: \.self) { year in
                                    Text("\(year)")
                                        .tag(year)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 100)
                            .clipped()
                            .cornerRadius(20)
                            .shadow(color: .gray, radius: 4, x: 0, y: 2)
                        }
                        
                        TextField("CVC", text: $cvc)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: {
                            payDeposit()
                        }) {
                            Text("Pay Deposit")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(18)
                        }.alert(isPresented: $showAlert) {
                            Alert(title: Text("Payment Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                        }
                        .padding(.top, 5)
                        
                        Text("The down payment is 1% of the advertising fee. Please contact the advertiser before paying.")
                            .foregroundColor(.red)
                            .opacity(0.6)
                            
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .gray, radius: 8, x: 0, y: 4)
                }
                .padding()
                .navigationBarHidden(true)
                            .overlay(
                                
                                VStack {
                                              HStack {
                                                  Button(action: {
                                                      presentationMode.wrappedValue.dismiss()
                                                  }) {
                                                      Image(systemName: "chevron.left")
                                                          .foregroundColor(.blue)
                                                          .font(.title)
                                                  }
                                                  
                                                  Spacer()
                                                  
                                                  Text(product.name)
                                                      .foregroundColor(.blue)
                                                      .font(.system(size: 24, weight: .bold))
                                                      .frame(maxWidth: .infinity)
                                                      .multilineTextAlignment(.center)
                                              }
                                              .padding(.top, 8)
                                              
                                              Spacer().frame(height: 36)
                                          }
                                          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                          .padding(.horizontal, 16)
                                          .overlay(
                                              VStack {
                                                  Spacer()
                                              }
                                              .frame(maxWidth: .infinity, maxHeight: .infinity)
                                              .padding(.top, 16)
                                              .padding(.leading, 16)
                                              , alignment: .topLeading
                                          )
                                      )}
                                  
                              
        }
          
    }
struct AccountView: View {
    let userEmail: String?
   @Binding var cusid: String? // Add cusid parameter

    
    @State private var isSigningOut = false
    @State private var showSignOutAlert = false
    @State private var signOutProgress = 0.0
    
    let signOutDelay = 2.0

    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
                    Text("Welcome ")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.blue)
                    .opacity(0.65)
            Rectangle()
                .foregroundColor(Color.blue)
                .opacity(0.4)
                .frame(height: 3)
            HStack(spacing: 16)
            {
                Text("Email:")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color.blue)
                    .opacity(0.55)
                
                Text(userEmail ?? "")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.black)
                    .opacity(0.55)
                
            }
            Rectangle()
                .foregroundColor(Color.blue)
                .opacity(0.4)
                .frame(height: 1)
            HStack(spacing: 16)
            {
                Text("Customer ID:")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color.blue)
                    .opacity(0.55)
                
                Text(cusid ?? "")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color.black)
                    .opacity(0.55)
            }
            Rectangle()
                .foregroundColor(Color.blue)
                .opacity(0.55)
                .frame(height: 1)
                    
            if isSigningOut {
                VStack {
                    ProgressView(value: signOutProgress, total: 1.0)
                    Text("Logging Out")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.red)
                        .opacity(0.55)
                }
            } else {
                Button(action: {
                    showSignOutAlert = true
                }) {
                    Text("Log Out")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.red)
                        .opacity(0.55)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showSignOutAlert = true
                        }) {
                            Image(systemName: "power")
                                .imageScale(.large)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle("Account")
        .alert(isPresented: $showSignOutAlert) {
            Alert(
                title: Text("Log Out!"),
                message: Text("Are you sure you want to log out?"),
                primaryButton: .cancel(),
                secondaryButton: .destructive(
                    Text("Yes"),
                    action: {
                        didTapSignOut()
                    }
                )
            )
            
        }
    }
    private func didTapSignOut() {
           isSigningOut = true
           
           for i in 0...Int(signOutDelay * 10) {
               DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) / 10.0) {
                   signOutProgress = Double(i) / (signOutDelay * 10.0)
                   if signOutProgress >= 1.0 {
                       // Clear token from UserDefaults
                       UserDefaults.standard.removeObject(forKey: "token")
                       
                       // Reset signing out state
                       isSigningOut = false
                       
                       // Present the login screen
                       let loginController = LoginController()
                        UIApplication.shared.windows.first?.rootViewController = loginController
                        UIApplication.shared.windows.first?.makeKeyAndVisible()
                   }
               }
           }
       }
   }
struct ProductRowView: View {
    let product: Product
    @State private var showDetails: Bool = false
    
    var body: some View {
      
        HStack() {
            Text(product.name)
                .font(.headline)
                .foregroundColor(.primary)
                .layoutPriority(1)
            
            Spacer()
            RemoteImage(urlString: product.image)
                .frame(width: 100, height: 100) // Adjust the size of the image view
                .cornerRadius(13) // Adjust the corner radius
            
            
            
            if showDetails {
                Text("Price: \(formatPrice(product.price))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Description: \(product.description)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Category: \(product.category)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Km: \(product.Km)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Model Year: \(formatModelYear(product.modelyear))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .gray, radius: 8, x: 0, y: 4)
        .fixedSize(horizontal: false, vertical: true)
    }
    
    
}



struct RemoteImage: View {
    let urlString: String
    @StateObject private var imageLoader = ImageLoader()

    var body: some View {
        Group {
            if let image = imageLoader.image {
                Image(uiImage: image)
                    .resizable()
            } else {
                // Placeholder image while loading
                Image(systemName: "photo")
                    .resizable()
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            imageLoader.loadImage(from: urlString)
        }
        .onDisappear {
            imageLoader.cancel()
        }
    }
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var task: URLSessionDataTask?

    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }

        task = URLSession.shared.dataTask(with: url) { (data, _, _) in
            guard let data = data, let image = UIImage(data: data) else {
                return
            }
            DispatchQueue.main.async {
                self.image = image
            }
        }
        task?.resume()
    }

    func cancel() {
        task?.cancel()
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
    extension Color {
        init(hex: String) {
            let scanner = Scanner(string: hex)
            var rgbValue: UInt64 = 0
            
            if scanner.scanHexInt64(&rgbValue) {
                let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
                let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
                let blue = Double(rgbValue & 0x0000FF) / 255.0
                
                self.init(red: red, green: green, blue: blue)
                return
            }
            
            self.init(red: 0, green: 0, blue: 0)
        }

}
