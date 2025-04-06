
import UIKit

class DrProfileDataVC: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
        @IBOutlet weak var specializationTextField: UITextField!
        @IBOutlet weak var emailTextField: UITextField!
        @IBOutlet weak var phoneNumberTextField: UITextField!
        @IBOutlet weak var addressTextField: UITextField!

        let viewModel = DoctorDataViewModel()
    
        override func viewDidLoad() {
            super.viewDidLoad()
            self.title="Personal Informations"

            let token = KeychainHelper.shared.getToken(forKey: "DR_Token")
            if let token = token {
                fetchDoctorData(token: token)
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
    }
