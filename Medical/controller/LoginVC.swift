import UIKit

class LoginVC: UIViewController {

    // Outlets for the text fields
    @IBOutlet weak var tfNameorID: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="Login"
        // Any additional setup after loading the view.
    }

    // Action for the Login button
    @IBAction func btnLogin(_ sender: UIButton) {
        // Validate that the name/ID and password are not empty
        guard let nameORid = tfNameorID.text, !nameORid.isEmpty else {
            print("Name or ID is required")
            return
        }
        
        guard let password = tfPassword.text, !password.isEmpty else {
            print("Password is required")
            return
        }

        // Add login logic here (e.g., API call, authentication check, etc.)
        print("Logging in with Name/ID: \(nameORid) and Password: \(password)")
    }

    // Action for the Segmented Control
    @IBAction func btnSegmentedControl(_ sender: UISegmentedControl) {
        // Switch based on which segment is selected
        switch sender.selectedSegmentIndex {
        case 0: // First segment (e.g., Doctor)
            tfNameorID.placeholder = "Enter Doctor Name"
        case 1: // Second segment (e.g., Patient)
            tfNameorID.placeholder = "Enter National ID"
        default:
            break
        }
    }
   
}
