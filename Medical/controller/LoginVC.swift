import UIKit

class LoginVC: UIViewController {

    @IBOutlet weak var tfNameorID: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var switchBtnRememberme: UISwitch!
    @IBOutlet weak var btnLoginn: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    let helperFunctions=HelperFunctions()
    // ViewModel instances
    private let doctorViewModel = DoctorLoginViewModel()
    private let patientViewModel = PatientLoginViewModel()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
           view.addGestureRecognizer(tap)
        
        // Set the color of the thumb and the background of the switch
           switchBtnRememberme.onTintColor = UIColor(red: 139/255, green: 0, blue: 0, alpha: 1) // Red background color
           switchBtnRememberme.thumbTintColor = .white // White thumb color
        helperFunctions.styleTextField(tfNameorID, placeholder: "Name or ID", icon: UIImage(named: "user"))
        helperFunctions.styleTextField(tfPassword, placeholder: "Password", icon: UIImage(named: "password"))

            setIconButton(for: btnLoginn, withImage: UIImage(named: "login"), title: "Login")
            
        // Initial placeholder update
           updatePlaceholder()
           
         
        // Retrieve the selected segment index from UserDefaults and set it
        if let savedSegmentIndex = UserDefaults.standard.value(forKey: "selectedSegmentIndex") as? Int {
            segmentedControl.selectedSegmentIndex = savedSegmentIndex
        }

        // Pre-fill credentials based on the selected segment
        let selectedIndex = segmentedControl.selectedSegmentIndex
        switch selectedIndex {
        case 0: // Doctor
            if let savedEmail = UserDefaults.standard.string(forKey: "DR_Email"),
               let savedPassword = UserDefaults.standard.string(forKey: "DR_Password") {
                tfNameorID.text = savedEmail
                tfPassword.text = savedPassword
                switchBtnRememberme.isOn = true
            }
        case 1: // Patient
            if let savedPatientEmail = UserDefaults.standard.string(forKey: "PT_Email"),
               let savedPatientPassword = UserDefaults.standard.string(forKey: "PT_Password") {
                tfNameorID.text = savedPatientEmail
                tfPassword.text = savedPatientPassword
                switchBtnRememberme.isOn = true
            }
        default:
            break
        }

            
            // Add target for segmented control
            segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        }


    // Action for the Login button
    @IBAction func btnLogin(_ sender: UIButton) {
        guard let nameORid = tfNameorID.text, !nameORid.isEmpty else {
            showAlert(message: "Email is required")
            return
        }

        guard let password = tfPassword.text, !password.isEmpty else {
            showAlert(message: "Password is required")
            return
        }

        let rememberMe = switchBtnRememberme.isOn

        // Determine which login process to use based on the segmented control
        if segmentedControl.selectedSegmentIndex == 0 {
            // Doctor login
            let loginData = DoctorLoginData(email: nameORid, password: password, rememberMe: rememberMe)
            doctorViewModel.login(doctorLoginData: loginData) { result in
                self.handleLoginResult(result)
            }
        } else {
            // Patient login
            let loginData = PatientLoginData(email: nameORid, password: password, rememberMe: rememberMe)
            patientViewModel.login(patientLoginData: loginData) { result in
                self.handleLoginResult(result)
            }
        }
    }

    private func handleLoginResult<T>(_ result: Result<T, Error>) {
        switch result {
        case .success(let response):
            if let doctorResponse = response as? DoctorLoginResponse {
                print("Doctor login successful! Token: \(doctorResponse.token)")
                UserDefaults.standard.set(doctorResponse.email, forKey: "DREmail")
                UserDefaults.standard.set(doctorResponse.id, forKey: "DR_ID")
                print(doctorResponse.id)

                // Save email and password if "Remember Me" is enabled for doctor
                if switchBtnRememberme.isOn {
                    UserDefaults.standard.set(doctorResponse.email, forKey: "DR_Email")
                    UserDefaults.standard.set(tfPassword.text, forKey: "DR_Password") // Save the password
                }

                // Navigate to HomeVc
                let homeVc = self.storyboard?.instantiateViewController(identifier: "drhomevc") as! DrHomeVC
                homeVc.title = "DR Home"
                self.navigationController?.pushViewController(homeVc, animated: true)

                KeychainHelper.shared.saveToken(token: doctorResponse.token, forKey: "DR_Token")
                UserDefaults.standard.set(doctorResponse.userName, forKey: "DR_Name")
                

            } else if let patientResponse = response as? PatientLoginResponse {
                print("Patient login successful! Token: \(patientResponse.token)")
                UserDefaults.standard.set(patientResponse.email, forKey: "PT_email")
                KeychainHelper.shared.saveToken(token: patientResponse.token, forKey: "PT_Token")
                UserDefaults.standard.set(patientResponse.id, forKey: "PT_ID")
                print(patientResponse.id)

                // Save patient email and password if "Remember Me" is enabled
                if switchBtnRememberme.isOn {
                    UserDefaults.standard.set(patientResponse.email, forKey: "PT_Email")
                    UserDefaults.standard.set(tfPassword.text, forKey: "PT_Password") // Save the password
                }

                // Navigate to HomeVc
                let homeVc = self.storyboard?.instantiateViewController(identifier: "homevc") as! HomeVC
                homeVc.title = "Patient Home"
                self.navigationController?.pushViewController(homeVc, animated: true)
            }
        case .failure(let error):
            showAlert(message: "Login failed: \(error.localizedDescription)")
        }
    }



    // Update placeholder text based on segmented control
   
    @objc func segmentChanged() {
        // Save the selected segment index
        UserDefaults.standard.set(segmentedControl.selectedSegmentIndex, forKey: "selectedSegmentIndex")
        
        // Update the placeholder text based on selected segment
        updatePlaceholder()
    }


    func updatePlaceholder() {
        if segmentedControl.selectedSegmentIndex == 0 {
            tfNameorID.placeholder = "Enter email"
        } else {
            tfNameorID.placeholder = "Enter email"
        }
    }

    // Helper function to show an alert
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // Helper function to add icon to text field
    func setIcon(for textField: UITextField, withImage image: UIImage?) {
        let iconImageView = UIImageView(image: image)
        iconImageView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
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
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }


}
