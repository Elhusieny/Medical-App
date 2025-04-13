
import UIKit

class PatientProfileDataVC: UIViewController {
    let viewModel = PatientProfileViewModel()
    
    // IBOutlets
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPhone: UITextField!
    @IBOutlet weak var tfAddress: UITextField!
    @IBOutlet weak var tfNatinalID: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tfConfirmPassword: UITextField!
    @IBOutlet weak var btnSaveChanges: UIButton!
    
    let helperFuctions=HelperFunctions()
    // Add other fields as needed...
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
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
        
        
        helperFuctions.styleTextField(tfName, placeholder: "Full Name", icon: UIImage(systemName: "person"))
        helperFuctions.styleTextField(tfNatinalID, placeholder: "NationalID", icon: UIImage(systemName: "person.text.rectangle"))
        helperFuctions.styleTextField(tfEmail, placeholder: "Email", icon: UIImage(systemName: "envelope"))
        helperFuctions.styleTextField(tfPhone, placeholder: "Phone Number", icon: UIImage(systemName: "phone"))
        helperFuctions.styleTextField(tfAddress, placeholder: "Address", icon: UIImage(systemName: "house"))
        helperFuctions.styleTextField(tfPassword, placeholder: "Password", icon: UIImage(systemName: "lock"))
        helperFuctions.styleTextField(tfConfirmPassword, placeholder: "Confirm Password", icon: UIImage(systemName: "lock.rotation"))

        helperFuctions.setIconButton(for: btnSaveChanges, withImage: UIImage(systemName: "square.and.arrow.down"), title: "Save Changes")

        
    }
    func loadData() {
        guard let id = UserDefaults.standard.string(forKey: "PT_ID"),
              let token = KeychainHelper.shared.getToken(forKey: "PT_Token") else {
            Utilities.showAlert(on: self, title: "Error", message: "User not logged in.")
            return
        }
        
        viewModel.fetchProfile(id: id, token: token) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    Utilities.showAlert(on: self!, title: "Error", message: error)
                } else if let profile = self?.viewModel.profile {
                    self?.populateFields(with: profile)
                }
            }
        }
    }
    
    func populateFields(with profile: PatientProfile) {
        tfName.text = profile.userName
        tfEmail.text = profile.email
        tfPhone.text = profile.phone
        tfAddress.text = profile.address
        tfNatinalID.text=profile.nationalID
        //tfPassword.text=profile
        
        // Populate the rest...
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
   
    @IBAction func saveChangesTapped(_ sender: UIButton) {
        print("Save Changes Tapped")
        
        // Check if the user is logged in and get the token
        guard let token = KeychainHelper.shared.getToken(forKey: "PT_Token") else {
            Utilities.showAlert(on: self, title: "Error", message: "Not logged in.")
            return
        }
        
        // Check if both password and confirm password are empty
        if (tfPassword.text?.isEmpty == true || tfConfirmPassword.text?.isEmpty == true) {
            Utilities.showAlert(on: self, title: "Error", message: "Please enter both password and confirm password.")
            return
        }
        
        // If putProfile is nil, initialize it with existing profile data and new data from the UI
        if viewModel.putProfile == nil {
            viewModel.putProfile = UpdatePatientProfileRequest(
                id: viewModel.profile?.id ?? "",  // Ensure profile is not nil
                nationalID: viewModel.profile?.nationalID ?? "",
                patientCode: viewModel.profile?.patientCode ?? 0,
                userName: tfName.text ?? "",
                email: tfEmail.text ?? "",
                phone: tfPhone.text ?? "",
                address: tfAddress.text ?? "",
                chronicDiseases: "",  // Assuming empty for now
                previousOperations: "",  // Assuming empty for now
                allergies: "",  // Assuming empty for now
                currentMedications: "",  // Assuming empty for now
                comments: "",  // Assuming empty for now
                password: (tfPassword.text?.isEmpty == true ? viewModel.profile?.password : tfPassword.text) ?? viewModel.profile?.password ?? "",
                ConfirmPassword: (tfConfirmPassword.text?.isEmpty == true ? viewModel.profile?.password : tfConfirmPassword.text) ?? viewModel.profile?.password ?? ""
            )
        }
        
        // Print out the data to be updated
        print("Updating profile with data: \(String(describing: viewModel.putProfile))")
        
        // Call updateProfile to save the changes using Alamofire
        viewModel.updateProfile(token: token) { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }  // Safe unwrap self
                
                if let error = error {
                    Utilities.showAlert(on: self, title: "Error", message: error)
                } else {
                    Utilities.showAlert(on: self, title: "Success", message: "Profile updated successfully!")
                }
            }
        }
    }
    @objc func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}


extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}



   

       
      
