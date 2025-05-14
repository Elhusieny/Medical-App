import UIKit
import SwiftUI

import Foundation
class DrHomeVC: UIViewController, DrHomeCollectionViewHandlerDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    private let handler = DrHomeCollectionViewHandler()
    //
    //    @IBOutlet weak var btnAddNewPresiption: UIButton!
    //    @IBOutlet weak var btnAllReservations: UIButton!
    //    @IBOutlet weak var btnMyWorkingTimes: UIButton!
    //    @IBOutlet weak var btnPresiptionHistory: UIButton!
    let helperFunctions = HelperFunctions()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.hidesBackButton = true

        collectionView.dataSource = handler
        collectionView.delegate = handler
        handler.delegate = self
        
        // Set up the layout for two columns
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let numberOfColumns: CGFloat = 2
            let padding: CGFloat = 10 // Adjust the padding as needed
            let totalPadding = (numberOfColumns + 1) * padding
            _ = (collectionView.frame.width - totalPadding) / numberOfColumns
            
            // Set the cell size to 150x150
            layout.itemSize = CGSize(width: 150, height: 150) // Set width and height to 150
            layout.minimumInteritemSpacing = padding
            layout.minimumLineSpacing = padding
            layout.sectionInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
            
        }
        
        //        helperFunctions.setIconButton(for: btnAddNewPresiption, withImage: UIImage(systemName: "pills.fill"), title: "Add New Prescription")
        //        helperFunctions.setIconButton(for: btnAllReservations, withImage: UIImage(systemName: "calendar.badge.clock"), title: "All Reservations")
        //        helperFunctions.setIconButton(for: btnMyWorkingTimes, withImage: UIImage(systemName: "clock.fill"), title: "My Working Times")
        //        helperFunctions.setIconButton(for: btnPresiptionHistory, withImage: UIImage(systemName: "doc.text.fill"), title: "Prescription History")
        
        // Add the toolbar and menu button
        addToolbar()
    }
    
    func didSelectFunction(_ function: String) {
        print("Tapped function: \(function)")
        
        switch function {
        case "Add Prescription":
            navigateToSwiftUIScreen()
        case "Reservations":
            navigateToDrReservations()
        case "Working Times":
            navigateToViewController(withIdentifier: "drworkingtimes")
        case "History":
            navigateToRoshetaHistoryScreen()
        default:
            break
        }
    }
    
    private func navigateToViewController(withIdentifier identifier: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: identifier) as? UIViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    private func navigateToRoshetaHistoryScreen() {
        let roshetaHistory = RoshetaHistoryScreen()
        let hostingController = UIHostingController(rootView: roshetaHistory)
        navigationController?.pushViewController(hostingController, animated: true)
    }
    private func navigateToDrReservations() {
        let doctorReservations = GetDoctorReservations(doctorId: UserDefaults.standard.string(forKey: "DR_ID") ?? "")
        let hostingController = UIHostingController(rootView: doctorReservations)
        navigationController?.pushViewController(hostingController, animated: true)
    }
    private func navigateToSwiftUIScreen() {
        let roshetaView = RoshetaScreen()
        let hostingController = UIHostingController(rootView: roshetaView)
        navigationController?.pushViewController(hostingController, animated: true)
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
        openProfileSwiftUI()
    }
    
    @objc private func notificationsButtonTapped() {
        // Handle notifications button tap
        print("Notifications tapped")
        openNotifications()
    }
    
    // MARK: - Open Profile
    private func openProfile() {
        // Navigate to the profile screen (implement navigation here)
        print("Navigate to Profile screen")
        //          let homeVc = self.storyboard?.instantiateViewController(identifier: "drhomevc") as! DrHomeVC
        //          homeVc.title = "DR Home"
        //          self.navigationController?.pushViewController(homeVc, animated: true)
        
        let profileVC =
        storyboard?.instantiateViewController(withIdentifier: "drprofiledatavc") as! DrProfileDataVC
        self.navigationController?.pushViewController(profileVC, animated: true)
        
        
    }
    @objc private func openProfileSwiftUI() {
        let profileView = DoctorProfileView()
        let hostingController = UIHostingController(rootView: profileView)
        self.navigationController?.pushViewController(hostingController, animated: true)
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
//    @objc func backTapped() {
//        navigationController?.popViewController(animated: true)
//    }
    
    
}
