import UIKit
import Alamofire

class RegisterVC: UIViewController {
    
    @IBOutlet weak var tfSpecializationOrID: UITextField!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfConfirmPassword: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPhone: UITextField!
    @IBOutlet weak var tfAddress: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  //  @IBOutlet weak var passwordVisibilityButton: UIButton!
    
    var viewModel = DoctorViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup viewModel listeners
        self.title = "Register"
        
        viewModel.onRegisterSuccess = {
            // Hide loader
            self.activityIndicator.stopAnimating()
            
            // Navigate to LoginVC
            let vc = self.storyboard?.instantiateViewController(identifier: "loginvc") as! LoginVC
            vc.title = "Login"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        viewModel.onRegisterFailure = { error in
            // Hide loader
            self.activityIndicator.stopAnimating()
            
            // Show error alert
            self.showAlert(message: "Registration failed: \(String(describing: error))")
        }
    }
    
    // Action for the Segmented Control
    @IBAction func btnSegmentedControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: // First segment (e.g., Doctor)
            tfSpecializationOrID.placeholder = "Enter Specialization"
        case 1: // Second segment (e.g., Patient)
            tfSpecializationOrID.placeholder = "Enter National ID"
        default:
            break
        }
    }
    
    // Action for the Register button
    @IBAction func btnRegister(_ sender: UIButton) {
        if validateFields() {
            // Show loader
            activityIndicator.startAnimating()
            
            let doctorData = PostDoctorData(
                userName: tfName.text!,
                specialization: tfSpecializationOrID.text!,
                email: tfEmail.text!,
                address: tfAddress.text!,
                phone: tfPhone.text!,
                password: tfPassword.text!,
                confirmPassword: tfConfirmPassword.text!
            )
            
            viewModel.registerDoctor(with: doctorData)
        }
    }
    
    /*
    // Action for toggling password visibility
    @IBAction func togglePasswordVisibility(_ sender: UIButton) {
        tfPassword.isSecureTextEntry.toggle()
        tfConfirmPassword.isSecureTextEntry.toggle()
        let imageName = tfPassword.isSecureTextEntry ? "eye.slash" : "eye"
        passwordVisibilityButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
     */
    
    // Validate form fields
    func validateFields() -> Bool {
        guard let name = tfName.text, !name.isEmpty,
              let specialization = tfSpecializationOrID.text, !specialization.isEmpty,
              let email = tfEmail.text, !email.isEmpty,
              let address = tfAddress.text, !address.isEmpty,
              let phone = tfPhone.text, !phone.isEmpty,
              let password = tfPassword.text, !password.isEmpty,
              let confirmPassword = tfConfirmPassword.text, !confirmPassword.isEmpty else {
            showAlert(message: "Please fill in all fields.")
            return false
        }
        
        // Check email format
        if !isValidEmail(email) {
            showAlert(message: "Please enter a valid email address.")
            return false
        }
        
        // Check password match
        if password != confirmPassword {
            showAlert(message: "Passwords do not match.")
            return false
        }
        
        // Add more validations as needed
        return true
    }
    
    // Check email format
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\\.[A-Z|a-z]{2,}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // Show alert
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
