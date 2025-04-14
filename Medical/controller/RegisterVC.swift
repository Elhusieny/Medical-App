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
   // @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var btnRegister: UIButton!

    var doctorViewModel = DoctorViewModel()
    var patientViewModel = PatientRegisterViewModel()
    let helperFunctions=HelperFunctions()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the initial placeholder text based on the default selected segment
        updateSpecializationOrIDPlaceholder()

        // Add target for UISegmentedControl to listen for value changes
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)

        // Setup viewModel listeners for Doctor registration
        doctorViewModel.onRegisterSuccess = {
            //self.activityIndicator.stopAnimating()
            self.navigateToLogin()
        }

        doctorViewModel.onRegisterFailure = { error in
            //self.activityIndicator.stopAnimating()
            self.showAlert(message: "Doctor Registration failed: \(String(describing: error))")
        }

        // Setup viewModel listeners for Patient registration
        patientViewModel.onRegisterSuccess = {
          //  self.activityIndicator.stopAnimating()
            self.navigateToLogin()
        }

        patientViewModel.onRegisterFailure = { error in
           // self.activityIndicator.stopAnimating()
            self.showAlert(message: "Patient Registration failed: \(String(describing: error))")
        }
        // 🔽 Add icons to text fields
           helperFunctions.setIcon(for: tfSpecializationOrID, withImage: UIImage(systemName: "person.text.rectangle"))
           helperFunctions.setIcon(for: tfName, withImage: UIImage(systemName: "person"))
           helperFunctions.setIcon(for: tfPassword, withImage: UIImage(systemName: "lock"))
           helperFunctions.setIcon(for: tfConfirmPassword, withImage: UIImage(systemName: "lock.rotation"))
           helperFunctions.setIcon(for: tfEmail, withImage: UIImage(systemName: "envelope"))
           helperFunctions.setIcon(for: tfPhone, withImage: UIImage(systemName: "phone"))
           helperFunctions.setIcon(for: tfAddress, withImage: UIImage(systemName: "house"))
        helperFunctions.setIconButton(for: btnRegister, withImage: UIImage(named: "login"), title: "Sign Up")

    }

    // Action for the Register button
    @IBAction func btnRegister(_ sender: UIButton) {
        if validateFields() {
            //activityIndicator.startAnimating()

            if segmentedControl.selectedSegmentIndex == 0 {
                // Doctor Registration
                let doctorData = PostDoctorData(
                    userName: tfName.text!,
                    specialization: tfSpecializationOrID.text!,
                    email: tfEmail.text!,
                    address: tfAddress.text!,
                    phone: tfPhone.text!,
                    password: tfPassword.text!,
                    confirmPassword: tfConfirmPassword.text!
                )
                doctorViewModel.registerDoctor(with: doctorData)
            } else {
                // Patient Registration
                let patientData = PostPatientData(
                    userName: tfName.text!,
                    nationalID: tfSpecializationOrID.text!,
                    email: tfEmail.text!,
                    address: tfAddress.text!,
                    phone: tfPhone.text!,
                    chronicDiseases: "", // Add additional fields if needed
                    previousOperations: "",
                    allergies: "",
                    currentMedications: "",
                    comments: "",
                    password: tfPassword.text!,
                    confirmPassword: tfConfirmPassword.text!
                )
                patientViewModel.registerPatient(with: patientData)
            }
        }
    }

    // Navigate to the Login screen
    func navigateToLogin() {
        let vc = self.storyboard?.instantiateViewController(identifier: "loginvc") as! LoginVC
        vc.title = "Login"
        self.navigationController?.pushViewController(vc, animated: true)
    }

    // Validation function
    func validateFields() -> Bool {
        guard let name = tfName.text, !name.isEmpty,
              let email = tfEmail.text, !email.isEmpty,
              let address = tfAddress.text, !address.isEmpty,
              let phone = tfPhone.text, !phone.isEmpty,
              let password = tfPassword.text, !password.isEmpty,
              let confirmPassword = tfConfirmPassword.text, !confirmPassword.isEmpty else {
            showAlert(message: "Please fill in all fields.")
            return false
        }

        if password != confirmPassword {
            showAlert(message: "Passwords do not match.")
            return false
        }

        if segmentedControl.selectedSegmentIndex == 0 {
            // Doctor validation
            guard let specialization = tfSpecializationOrID.text, !specialization.isEmpty else {
                showAlert(message: "Please enter specialization.")
                return false
            }
        } else {
            // Patient validation
            guard let nationalID = tfSpecializationOrID.text, !nationalID.isEmpty else {
                showAlert(message: "Please enter national ID.")
                return false
            }
        }

        return true
    }

    // Show alert
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Update Placeholder Based on Segmented Control
    @objc func segmentChanged() {
        updateSpecializationOrIDPlaceholder()
    }

    // Function to update the placeholder text
    func updateSpecializationOrIDPlaceholder() {
        if segmentedControl.selectedSegmentIndex == 0 {
            // Doctor selected
            tfSpecializationOrID.placeholder = "Enter Specialization"
        } else {
            // Patient selected
            tfSpecializationOrID.placeholder = "Enter National ID"
        }
    }
}
