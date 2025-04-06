import UIKit

class LoginVC: UIViewController {

    @IBOutlet weak var tfNameorID: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var switchBtnRememberme: UISwitch!
    @IBOutlet weak var btnLoginn: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    // ViewModel instances
    private let doctorViewModel = DoctorLoginViewModel()
    private let patientViewModel = PatientLoginViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setIcon(for: tfNameorID, withImage: UIImage(named: "user"))
        setIcon(for: tfPassword, withImage: UIImage(named: "password"))
        setIconButton(for: btnLoginn, withImage: UIImage(named: "login"), title: "Login")

        // Initial placeholder update
        updatePlaceholder()
        
        // Add target for segmented control
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }

    // Action for the Login button
    @IBAction func btnLogin(_ sender: UIButton) {
        guard let nameORid = tfNameorID.text, !nameORid.isEmpty else {
            showAlert(message: "Name or ID is required")
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
            let loginData = DoctorLoginData(userName: nameORid, password: password, rememberMe: rememberMe)
            doctorViewModel.login(doctorLoginData: loginData) { result in
                self.handleLoginResult(result)
            }
        } else {
            // Patient login
            let loginData = PatientLoginData(nationalID: nameORid, password: password, rememberMe: rememberMe)
            patientViewModel.login(patientLoginData: loginData) { result in
                self.handleLoginResult(result)
            }
        }
    }

    // Modified handleLoginResult function to handle both Doctor and Patient login responses
    private func handleLoginResult<T>(_ result: Result<T, Error>) {
        switch result {
        case .success(let response):
            if let doctorResponse = response as? DoctorLoginResponse {
                print("Doctor login successful! Token: \(doctorResponse.token)")
                UserDefaults.standard.set(doctorResponse.userName, forKey: "DR_UserName")
                UserDefaults.standard.set(doctorResponse.id, forKey: "DR_ID")
                print(doctorResponse.id)

                KeychainHelper.shared.saveToken(token: doctorResponse.token, forKey: "DR_Token")
            } else if let patientResponse = response as? PatientLoginResponse {
                print("Patient login successful! Token: \(patientResponse.token)")
                UserDefaults.standard.set(patientResponse.userName, forKey: "PT_UserName")
                KeychainHelper.shared.saveToken(token: patientResponse.token, forKey: "PT_Token")
                UserDefaults.standard.set(patientResponse.id, forKey: "PT_ID")

                
            }
            
            // Navigate to HomeVc
            let homeVc = self.storyboard?.instantiateViewController(identifier: "homevc") as! HomeVC
            homeVc.title = "Home"
            self.navigationController?.pushViewController(homeVc, animated: true)

        case .failure(let error):
            showAlert(message: "Login failed: \(error.localizedDescription)")
        }
    }


    // Update placeholder text based on segmented control
    @objc func segmentChanged() {
        updatePlaceholder()
    }

    func updatePlaceholder() {
        if segmentedControl.selectedSegmentIndex == 0 {
            tfNameorID.placeholder = "Enter Doctor Name"
        } else {
            tfNameorID.placeholder = "Enter National ID"
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


}
