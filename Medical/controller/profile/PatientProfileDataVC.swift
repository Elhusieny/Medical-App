
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
    @IBOutlet weak var profileImageView: UIImageView!

    let helperFuctions=HelperFunctions()
    // Add other fields as needed...
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100)
        ])

        profileImageView.layer.cornerRadius = 50 // Half of 100
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderWidth = 2
        profileImageView.layer.borderColor = UIColor.darkRed.cgColor


        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectImage))
           profileImageView.isUserInteractionEnabled = true
           profileImageView.addGestureRecognizer(tapGesture)
        
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
    
    func populateFields(with profile: GetPatientProfileData) {
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
        
        guard let token = KeychainHelper.shared.getToken(forKey: "PT_Token") else {
            Utilities.showAlert(on: self, title: "Error", message: "Not logged in.")
            return
        }
        
        if tfPassword.text?.isEmpty == true || tfConfirmPassword.text?.isEmpty == true {
            Utilities.showAlert(on: self, title: "Error", message: "Please enter both password and confirm password.")
            return
        }

        // Capture previously selected image
        var selectedImage: UIImage? = nil

        if let imageData = viewModel.putProfile?.image {
            selectedImage = UIImage(data: imageData)
        } else {
            selectedImage = profileImageView.image
        }

        // Rebuild full putProfile with all updated fields and the image
        viewModel.putProfile = UpdatePatientProfileRequest(
            id: viewModel.profile?.id ?? "",
            nationalID: viewModel.profile?.nationalID ?? "",
            patientCode: viewModel.profile?.patientCode ?? 0,
            userName: tfName.text ?? "",
            email: tfEmail.text ?? "",
            phone: tfPhone.text ?? "",
            address: tfAddress.text ?? "",
            chronicDiseases: viewModel.profile?.chronicDiseases ?? "",
            previousOperations: viewModel.profile?.previousOperations ?? "",
            allergies: viewModel.profile?.allergies ?? "",
            currentMedications: viewModel.profile?.currentMedications ?? "",
            comments: viewModel.profile?.comments ?? "",
            password: tfPassword.text ?? viewModel.profile?.password ?? "",
            ConfirmPassword: tfConfirmPassword.text ?? viewModel.profile?.password ?? "",
            image: selectedImage?.jpegData(compressionQuality: 0.8)
        )

        print("Updating profile with data: \(String(describing: viewModel.putProfile))")

        viewModel.updateProfileWithImage(token: token) { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let error = error {
                    Utilities.showAlert(on: self, title: "Error", message: error)
                } else {
                    Utilities.showAlert(on: self, title: "Success", message: "Profile updated successfully!")
                }
            }
        }
    }

    @objc func selectImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
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
extension PatientProfileDataVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            profileImageView.image = image
            
            // Assign or create the putProfile with the selected image
            if let _ = viewModel.putProfile {
                viewModel.putProfile?.image = image.jpegData(compressionQuality: 0.8)
            } else if let profile = viewModel.profile {
                viewModel.putProfile = UpdatePatientProfileRequest(
                    id: profile.id,
                    nationalID: profile.nationalID,
                    patientCode: profile.patientCode,
                    userName: tfName.text ?? profile.userName,
                    email: tfEmail.text ?? profile.email,
                    phone: tfPhone.text ?? profile.phone,
                    address: tfAddress.text ?? profile.address,
                    chronicDiseases: profile.chronicDiseases ?? "",
                    previousOperations: profile.previousOperations ?? "",
                    allergies: profile.allergies ?? "",
                    currentMedications: profile.currentMedications ?? "",
                    comments: profile.comments ?? "",
                    password: tfPassword.text ?? "",
                    ConfirmPassword: tfConfirmPassword.text ?? "",
                    image: image.jpegData(compressionQuality: 0.8) // ✅ convert here
                )
            }
        }
    }

}



   

       
      
