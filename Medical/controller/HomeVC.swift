import UIKit
import SwiftUI

class HomeVC: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    let viewModel = GetAllDoctorsViewModel()
    var collectionViewHandler: DoctorsCollectionViewHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="Home"
 
        self.navigationItem.hidesBackButton = true

        collectionViewHandler = DoctorsCollectionViewHandler(viewModel: viewModel)
        collectionView.dataSource = collectionViewHandler
        collectionView.delegate = collectionViewHandler
        
        // Set up the closure to handle doctor selection
        collectionViewHandler?.didSelectDoctor = { [weak self] selectedDoctor in
            guard let self = self else { return }

            let swiftUIView = DoctorDetailsView(
                doctorName: selectedDoctor.userName ?? "",
                specialization: selectedDoctor.specialization ?? "",
                doctorId: selectedDoctor.id ?? "" ,
                doctorImage: selectedDoctor.imagePath ?? "" // Replace with the actual image name or URL
)
            self.navigationItem.hidesBackButton = true

            let hostingController = UIHostingController(rootView: swiftUIView)
            self.navigationController?.pushViewController(hostingController, animated: true)

        }
        addToolbar()

        fetchDoctors()
    }


    
    func fetchDoctors() {
        let token = KeychainHelper.shared.getToken(forKey: "PT_Token")
        if let token = token {
            viewModel.fetchDoctors(token: token) { success in
                if success {
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        
                    }
                } else {
                    print("Failed to fetch doctors.")
                }
            }
        } else {
            print("No token available.")
        }
    }
    
    // Prepare for segue to DoctorDetailsVC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDoctorDetails", let
            doctorDetailsVC = segue.destination as? DoctorDetailsVC, let selectedDoctor = sender as? Doctors {
            // Pass the selected doctor data to DoctorDetailsVC
            doctorDetailsVC.doctor = selectedDoctor
            print("Doc ID=\(selectedDoctor.id)")
        }
    }
    // MARK: - Toolbar Setup
    private func addToolbar() {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.barTintColor = UIColor(red: 139/255, green: 0, blue: 0, alpha: 1)
        toolbar.tintColor = .white
        
        // Helper to create icon buttons
        func makeBarButtonItem(systemName: String, action: Selector) -> UIBarButtonItem {
            let button = UIButton(type: .system)
            
            // Configure a larger symbol
            let config = UIImage.SymbolConfiguration(pointSize: 26, weight: .bold) // You can adjust size here
            let image = UIImage(systemName: systemName, withConfiguration: config)
            button.setImage(image, for: .normal)
            button.tintColor = .white
            button.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
            button.addTarget(self, action: action, for: .touchUpInside)
            return UIBarButtonItem(customView: button)
        }
        
        // Create each button
        let logoutItem = makeBarButtonItem(systemName: "power", action: #selector(logoutButtonTapped))
        let appointmentsItem = makeBarButtonItem(systemName: "calendar", action: #selector(appointmentsButtonTapped))
        let profileItem = makeBarButtonItem(systemName: "person.circle", action: #selector(profileButtonTapped))
        let notificationsItem = makeBarButtonItem(systemName: "bell", action: #selector(notificationsButtonTapped))
        
        // Optional: add spacing between items
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.items = [
            flexibleSpace,
            logoutItem,
            flexibleSpace,
            appointmentsItem,
            flexibleSpace,
            profileItem,
            flexibleSpace,
            notificationsItem,
            flexibleSpace
        ]
        
        view.addSubview(toolbar)
        
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 45)
        ])
    }
    
    // MARK: - Toolbar Button Actions
    @objc private func logoutButtonTapped() {
        // Perform Logout
        print("Logout tapped")
        logout()
    }
    
    @objc private func appointmentsButtonTapped() {
        // Handle appointment button tap
        print("Appointments tapped")
        openAppointments()
    }
    
    @objc private func profileButtonTapped() {
        // Handle profile button tap
        print("Profile tapped")
        //openProfile()
        openProfileSwiftUI()
    }
    
    @objc private func notificationsButtonTapped() {
        // Handle notifications button tap
        print("Notifications tapped")
        openNotifications()
        
    }
    
    @objc private func openProfileSwiftUI() {
        let profileView = PatientProfileView()
        let hostingController = UIHostingController(rootView: profileView)
        self.navigationController?.pushViewController(hostingController, animated: true)
    }
    
    // MARK: - Open Profile
    private func openProfile() {
        // Navigate to the profile screen (implement navigation here)
        print("Navigate to Profile screen")
        //          let homeVc = self.storyboard?.instantiateViewController(identifier: "drhomevc") as! DrHomeVC
        //          homeVc.title = "DR Home"
        //          self.navigationController?.pushViewController(homeVc, animated: true)
        
        let profileVC =
        storyboard?.instantiateViewController(withIdentifier: "patientprofiledatavc") as! PatientProfileDataVC
        self.navigationController?.pushViewController(profileVC, animated: true)
        
        
    }
    
    // MARK: - Open Appointments
    private func openAppointments() {
        // Navigate to the appointments screen (implement navigation here)
        print("Navigate to Appointments screen")
    }
    
    // MARK: - Open Notifications
    private func openNotifications() {
        // Navigate to the notifications screen (implement navigation here)
        print("Navigate to Notifications screen")
    }
    
    private func logout() {
        // Clear user data (e.g., remove stored credentials or session data)
        UserDefaults.standard.removeObject(forKey: "DR_Email")
        UserDefaults.standard.removeObject(forKey: "DR_Password")  // Add any other relevant keys
        
        // Optional: Clear any other stored data if needed (e.g., keychain, CoreData, etc.)
        // KeychainHelper.remove(key: "user_token")  // Example if you're using Keychain for storing sensitive data
        
        // Perform additional logout tasks if needed (e.g., reset any app states)
        
        // Display logout confirmation alert
        let alert = UIAlertController(title: "Logged Out", message: "You have been logged out successfully.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            // Redirect to the login screen after the alert is dismissed
            if let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginvc") {
                self.navigationController?.setViewControllers([loginVC], animated: true)
            }
        }))
        present(alert, animated: true, completion: nil)
        
        print("Logged out")
    }
}
