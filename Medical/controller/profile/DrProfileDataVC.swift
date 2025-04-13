
import UIKit

class DrProfileDataVC: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
        @IBOutlet weak var specializationTextField: UITextField!
        @IBOutlet weak var emailTextField: UITextField!
        @IBOutlet weak var phoneNumberTextField: UITextField!
        @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfConfirmPassword: UITextField!

    @IBOutlet weak var btnSaveChanges: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    let helperFuctions=HelperFunctions()

        let viewModel = DoctorDataViewModel()
    
        override func viewDidLoad() {
            super.viewDidLoad()
            self.title="Profile"
            // Create a back button with SF Symbol and black tint
            let backImage = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate)
            let backButton = UIButton(type: .system)
            backButton.setImage(backImage, for: .normal)
            backButton.setTitle(" Back", for: .normal)
            backButton.tintColor = .black
            backButton.setTitleColor(.black, for: .normal)
         // 💪 Set bold system font
             backButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

            let backBarButtonItem = UIBarButtonItem(customView: backButton)
            navigationItem.leftBarButtonItem = backBarButtonItem
            let token = KeychainHelper.shared.getToken(forKey: "DR_Token")
            if let token = token {
                fetchDoctorData(token: token)
            }
            helperFuctions.styleTextField(nameTextField, placeholder: "Full Name", icon: UIImage(systemName: "person"))
            helperFuctions.styleTextField(specializationTextField, placeholder: "Specialization", icon: UIImage(systemName: "cross.case"))
            helperFuctions.styleTextField(emailTextField, placeholder: "Email", icon: UIImage(systemName: "envelope"))
            helperFuctions.styleTextField(phoneNumberTextField, placeholder: "Phone Number", icon: UIImage(systemName: "phone"))
            helperFuctions.styleTextField(addressTextField, placeholder: "Address", icon: UIImage(systemName: "house"))
            helperFuctions.styleTextField(tfPassword, placeholder: "Password", icon: UIImage(systemName: "lock"))
            helperFuctions.styleTextField(tfConfirmPassword, placeholder: "Confirm Password", icon: UIImage(systemName: "lock.rotation"))
            helperFuctions.setIconButton(for: btnSaveChanges, withImage: UIImage(systemName: "square.and.arrow.down"), title: "Save Changes")
        }

    @IBAction func saveChangesTapped(_ sender: UIButton) {
        guard let token = KeychainHelper.shared.getToken(forKey: "DR_Token") else {
            showAlert(message: "Not logged in.")
            return
        }

        // Check for password fields
        guard let password = tfPassword.text, !password.isEmpty,
              let confirmPassword = tfConfirmPassword.text, !confirmPassword.isEmpty else {
            showAlert(message: "Please enter both password and confirm password.")
            return
        }

        // Build request
        viewModel.putProfile = UpdateDoctorProfileRequest(
            id: viewModel.doctor?.id ?? "",
            userName: nameTextField.text ?? "",
            specialization: specializationTextField.text ?? "",
            email: emailTextField.text ?? "",
            phone: phoneNumberTextField.text ?? "",
            address: addressTextField.text ?? "",
            password: password,
            confirmPassword: confirmPassword,
            medicineDescriptions: nil,
            doctorWorkingTime: nil,
            doctorWorkingDaysOfWeek: nil
        )

        viewModel.updateDoctorProfile(token: token) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showAlert(message: error)
                } else {
                    self?.showAlert(message: "Doctor profile updated successfully.")
                }
            }
        }
    }

    func fetchDoctorData(token: String) {
            viewModel.fetchDoctorData(token: token) {
                DispatchQueue.main.async {
                    if let error = self.viewModel.error {
                        self.showAlert(message: "Error: \(error)")
                        print(error)
                    } else if let doctor = self.viewModel.doctor {
                        self.updateUI(with: doctor)
                        print(doctor.specialization)
                    }
                }
            }
        }

        func updateUI(with doctor: DoctorData) {
            // Set the text fields' text to the doctor's information
            nameTextField.text = doctor.userName
            specializationTextField.text = doctor.specialization
            emailTextField.text = doctor.email
            phoneNumberTextField.text = doctor.phoneNumber
            addressTextField.text = doctor.address
        }

        func showAlert(message: String) {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height + 20, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    @objc func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    }
