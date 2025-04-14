//
//  HelperFunctions.swift
//  Medical
//
//  Created by Dina Hussieny on 06/04/2025.
//

import Foundation
import UIKit
import SwiftUI
class HelperFunctions{
    
    // Helper function to add icon to text field
    func setIcon(for textField: UITextField, withImage image: UIImage?) {
        let iconImageView = UIImageView(image: image)
        iconImageView.frame = CGRect(x: 5, y: 0, width: 24, height: 24)
        iconImageView.contentMode = .scaleAspectFit
        let paddingView = UIView(frame: CGRect(x: 5, y: 0, width: 30, height: 24))
        paddingView.addSubview(iconImageView)
        iconImageView.image = iconImageView.image?.withRenderingMode(.alwaysTemplate)
        iconImageView.tintColor = UIColor(red: 139/255, green: 0, blue: 0, alpha: 1) // Dark Red
        
        textField.leftView = paddingView
        textField.leftViewMode = .always
    }
    
    func setIconButton(for button: UIButton, withImage image: UIImage?, title: String) {
        guard let image = image else { return }

        // Resize image and enable tinting
        let resizedImage = image.resized(to: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysTemplate)

        var configuration = UIButton.Configuration.plain()
        configuration.image = resizedImage
        configuration.imagePlacement = .leading
        configuration.imagePadding = 10
        configuration.title = title

        button.configuration = configuration
        button.tintColor = .white
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 139/255, green: 0, blue: 0, alpha: 1)
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
    }
    func setIconButton2(for button: UIButton, withImage image: UIImage?, title: String) {
        guard let image = image else { return }

        let resizedImage = image.resized(to: CGSize(width: 20, height: 20)).withRenderingMode(.alwaysTemplate)

        var configuration = UIButton.Configuration.plain()
        configuration.image = resizedImage
        configuration.imagePlacement = .leading
        configuration.imagePadding = 8
        configuration.title = title

        button.configuration = configuration
        button.tintColor = .white
    }
    func styleTextField(_ textField: UITextField, placeholder: String, icon: UIImage? = nil) {
        textField.placeholder = placeholder
        textField.borderStyle = .none
        textField.backgroundColor = UIColor.systemGray6
        textField.layer.cornerRadius = 10
        textField.layer.masksToBounds = true
        textField.setLeftPaddingPoints(12)
        textField.font = UIFont.systemFont(ofSize: 16)
        
        if let icon = icon {
            let iconView = UIImageView(image: icon)
            iconView.tintColor = .gray
            iconView.contentMode = .scaleAspectFit
            iconView.frame = CGRect(x: 0, y: 0, width: 30, height: 20)

            let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
            containerView.addSubview(iconView)
            iconView.center = containerView.center

            textField.leftView = containerView
            textField.leftViewMode = .always
        }
    }


}
struct BackButton: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss() // Navigate back to the previous screen
        }) {
            HStack(spacing: 0) { // Set spacing to 0
                
                Image(systemName: "chevron.left") // Custom back icon
                    .foregroundColor(.black) // Set color
                    .font(.system(size: 15)) // Set size
                Text("Back").foregroundColor(.black).bold()
                
            }
        }
    }
}
