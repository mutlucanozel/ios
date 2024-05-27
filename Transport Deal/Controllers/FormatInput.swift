//
//  FormatInput.swift
//  swift-login-system-tutorial
//
//  Created by Mutlu Can on 2.06.2023.
//

import UIKit
func formatPrice(_ price: Decimal) -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .currency
    numberFormatter.currencyCode = "TRY" // You can change the currency code here
    numberFormatter.currencySymbol = "₺" // Set the currency symbol to "₺"
    numberFormatter.positiveFormat = numberFormatter.positiveFormat?.replacingOccurrences(of: "¤", with: "") // Remove the currency symbol placeholder
    let formattedPrice = numberFormatter.string(from: NSDecimalNumber(decimal: price)) ?? ""
    return formattedPrice + " ₺" // Append the currency symbol at the end
}


func formatModelYear(_ year: Int) -> String {
    return "\(year)"
}

func formatPhoneNumber(_ phoneNumber: Int) -> String {
    let numberString = String(phoneNumber)
    let formattedNumber: String
    
    if numberString.count == 10 { // Assuming the phone number has 10 digits
        let areaCode = numberString.prefix(3)
        let prefix = numberString[numberString.index(numberString.startIndex, offsetBy: 3)..<numberString.index(numberString.startIndex, offsetBy: 6)]
        let lineNumber = numberString.suffix(4)
        
        formattedNumber = "0(\(areaCode)) \(prefix)-\(lineNumber)"
    } else {
        formattedNumber = numberString // Return as-is if the phone number is not 10 digits
    }
    
    return formattedNumber
}
