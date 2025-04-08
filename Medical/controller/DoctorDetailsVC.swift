import UIKit
import Combine

class DoctorDetailsVC: UIViewController {
    
    @IBOutlet weak var laDocSpecialization: UILabel!
    @IBOutlet weak var laDocName: UILabel!
    @IBOutlet weak var doctorView: UIView!
    
    var doctor: Doctors? // Doctor data passed from HomeVC
    var doctorId: String?
    
    @IBOutlet weak var collectionViewDates: UICollectionView!
    @IBOutlet weak var collectionViewTimes: UICollectionView!
    
    @IBOutlet weak var bookButton: UIButton!
    
    private let viewModel = BookingViewModel()
    private let dateCollectionViewManager = DateCollectionViewManager()
    private let timeCollectionViewManager = TimeCollectionViewManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Doctor Details"
        
        // Set corner radius for doctor view
        doctorView.layer.cornerRadius = 20
        doctorView.layer.masksToBounds = true
        
        // Display doctor data
        if let doctor = doctor {
            laDocName.text = doctor.userName
            laDocSpecialization.text = doctor.specialization
            doctorId = doctor.id
        }
        //collectionViewTimes.backgroundColor = .red // For testing visibility
        
        
        setupCollectionViews()
        fetchDoctorTimes()
        
        // Set up book appointment button action
        bookButton.addTarget(self, action: #selector(bookAppointment), for: .touchUpInside)
    }
    
    private func setupCollectionViews() {
        collectionViewDates.delegate = dateCollectionViewManager
        collectionViewDates.dataSource = dateCollectionViewManager
        
        collectionViewTimes.delegate = timeCollectionViewManager
        collectionViewTimes.dataSource = timeCollectionViewManager
        
        dateCollectionViewManager.onDateSelected = { selectedDate in
            self.viewModel.selectedDate = selectedDate
            self.updateTimes(for: selectedDate)
            self.updateBookingButtonState() // Update button state
        }
        
        timeCollectionViewManager.onTimeSelected = { selectedTime in
            self.viewModel.selectedTime = selectedTime
            self.updateBookingButtonState() // Update button state
        }
        
        // Ensure these lines are present
        collectionViewDates.allowsSelection = true
        collectionViewTimes.allowsSelection = true
    }
    
    
    private func fetchDoctorTimes() {
        guard let token = KeychainHelper.shared.getToken(forKey: "DR_Token") else {
            print("No token available.")
            return
        }
        
        guard let doctorId = doctorId else {
            print("No doctor ID available.")
            return
        }
        
        viewModel.fetchDoctorTimes(token: token, doctorId: doctorId) {
            DispatchQueue.main.async {
                print("Available Times: \(self.viewModel.availableTimes)")
                self.updateDates()
            }
        }
    }
    
    
    private func updateDates() {
        let dates = viewModel.availableTimes.map { String($0.intervalStart.split(separator: "T")[0]) }
        let uniqueDates = Array(Set(dates)).sorted() // Sort the dates if needed
        print("Unique Dates: \(uniqueDates)") // Add this to check the extracted dates
        dateCollectionViewManager.setDates(uniqueDates)
        collectionViewDates.reloadData()
    }
    private func updateTimes(for date: String) {
        let times = viewModel.availableTimes.filter { $0.intervalStart.split(separator: "T")[0] == date }
        
        // Debugging output
        print("Filtered Times for \(date): \(times)") // Check the filtered times
        
        // Ensure we are passing the correct ResultInterval objects
        timeCollectionViewManager.setTimes(times)
        collectionViewTimes.reloadData()
    }
    
    private func updateBookingButtonState() {
        bookButton.isEnabled = viewModel.selectedDate != nil && viewModel.selectedTime != nil
    }
    
    @objc private func bookAppointment() {
        guard let token = KeychainHelper.shared.getToken(forKey: "PT_Token") else {
            print("No token available.")
            return
        }
        
        guard let patientId = UserDefaults.standard.string(forKey: "PT_ID") else {
            print("No patient ID found in UserDefaults.")
            return
        }
        
        viewModel.bookAppointment(token: token, patientId: patientId) { success in
            DispatchQueue.main.async {
                if success {
                    // Handle successful booking, e.g., show a success message or navigate to a confirmation screen
                    let alert = UIAlertController(title: "Success", message: "Appointment booked successfully!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                } else {
                    // Handle booking failure, e.g., show an error message
                    let alert = UIAlertController(title: "Error", message: "Failed to book appointment. Please try again.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}

