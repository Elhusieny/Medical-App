import UIKit

class DrWorkingTimes: UIViewController {
    
    let viewModel = DrWorkingTimesViewModel()
    let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    var selectedDays: [String] = []
    var workingHours: [String: (startTime: Date, endTime: Date)] = [:]
    
    // Assuming you have linked buttons from the storyboard
    @IBOutlet weak var mondayButton: UIButton!
    @IBOutlet weak var tuesdayButton: UIButton!
    @IBOutlet weak var wednesdayButton: UIButton!
    @IBOutlet weak var thursdayButton: UIButton!
    @IBOutlet weak var fridayButton: UIButton!
    @IBOutlet weak var saturdayButton: UIButton!
    @IBOutlet weak var sundayButton: UIButton!
    let helperFunctions=HelperFunctions()
    
    @IBOutlet weak var btnSubmitWorkintTimes: UIButton!
    @IBOutlet weak var btnShowSchedule: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Working Times"
        
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
        
        configureButtons()
    }
    @objc func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func configureButtons() {
        let buttons: [UIButton] = [
            mondayButton, tuesdayButton, wednesdayButton,
            thursdayButton, fridayButton, saturdayButton, sundayButton
        ]
        
        for (index, button) in buttons.enumerated() {
            let dayTitle = daysOfWeek[index]
            let icon = UIImage(systemName: "calendar") // Or any other image you prefer
            helperFunctions.setIconButton2(for: button, withImage: icon, title: dayTitle)
            styleAsWorkingTimeButton(button)
        }
        
        styleAsWorkingTimeButton(btnSubmitWorkintTimes)
        styleAsWorkingTimeButton(btnShowSchedule)
    }
    
    
    
    @IBAction func toggleDaySelection(_ sender: UIButton) {
        let day = daysOfWeek[sender.tag]
        
        if selectedDays.contains(day) {
            selectedDays.removeAll { $0 == day }
            sender.layer.borderColor = UIColor.white.cgColor
            sender.setTitleColor(.white, for: .normal)
        } else {
            selectedDays.append(day)
            sender.layer.borderColor = UIColor.systemGreen.cgColor
            sender.setTitleColor(.systemGreen, for: .normal)
            showTimePicker(for: day)
        }
    }
    
    
    
    func styleAsWorkingTimeButton(_ button: UIButton) {
        button.setTitleColor(.white, for: .normal)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.backgroundColor = UIColor(red: 139/255, green: 0, blue: 0, alpha: 1)
        button.layer.cornerRadius = 20
        button.tintColor = .white
        
        
    }
    
    func showTimePicker(for day: String) {
        let alertController = UIAlertController(title: "Select Working Hours for \(day)", message: "\n\n\n\n\n\n\n", preferredStyle: .alert)
        
        let containerView = UIView(frame: CGRect(x: 10, y: 50, width: 260, height: 160))
        
        let startLabel = UILabel()
        startLabel.text = "Start Time:"
        startLabel.font = UIFont.systemFont(ofSize: 14)
        startLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let startTimePicker = UIDatePicker()
        startTimePicker.datePickerMode = .time
        startTimePicker.preferredDatePickerStyle = .wheels
        startTimePicker.translatesAutoresizingMaskIntoConstraints = false
        
        let endLabel = UILabel()
        endLabel.text = "End Time:"
        endLabel.font = UIFont.systemFont(ofSize: 14)
        endLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let endTimePicker = UIDatePicker()
        endTimePicker.datePickerMode = .time
        endTimePicker.preferredDatePickerStyle = .wheels
        endTimePicker.translatesAutoresizingMaskIntoConstraints = false
        
        let startTimeStack = UIStackView(arrangedSubviews: [startLabel, startTimePicker])
        startTimeStack.axis = .horizontal
        startTimeStack.spacing = 10
        startTimeStack.alignment = .center
        startTimeStack.translatesAutoresizingMaskIntoConstraints = false
        
        let endTimeStack = UIStackView(arrangedSubviews: [endLabel, endTimePicker])
        endTimeStack.axis = .horizontal
        endTimeStack.spacing = 10
        endTimeStack.alignment = .center
        endTimeStack.translatesAutoresizingMaskIntoConstraints = false
        
        let mainStack = UIStackView(arrangedSubviews: [startTimeStack, endTimeStack])
        mainStack.axis = .vertical
        mainStack.spacing = 20
        mainStack.alignment = .fill
        mainStack.distribution = .fillEqually
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            mainStack.topAnchor.constraint(equalTo: containerView.topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            startLabel.widthAnchor.constraint(equalToConstant: 100),
            endLabel.widthAnchor.constraint(equalToConstant: 100)
        ])
        
        alertController.view.addSubview(containerView)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            let startTime = startTimePicker.date
            let endTime = endTimePicker.date
            
            if endTime > startTime {
                self.workingHours[day] = (startTime: startTime, endTime: endTime)
            } else {
                let errorAlert = UIAlertController(title: "Invalid Time", message: "End time must be after start time.", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func showSchedule() {
        var schedule = ""
        for day in selectedDays {
            if let times = workingHours[day] {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                let startTimeString = dateFormatter.string(from: times.startTime)
                let endTimeString = dateFormatter.string(from: times.endTime)
                schedule += "\(day): \(startTimeString) - \(endTimeString)\n"
            }
        }
        let alert = UIAlertController(title: "Doctor's Schedule", message: schedule.isEmpty ? "No schedule selected" : schedule, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func submitWorkingTimes() {
        if let doctorId = UserDefaults.standard.string(forKey: "DR_ID") {
            print("Doctor ID: \(doctorId)")
            
            // Prepare the working times data
            self.viewModel.prepareWorkingTimesData(selectedDays: self.workingHours, doctorId: doctorId)
            print("Prepared working times: \(String(describing: self.viewModel.workingTimes))")
            
            // Check if working times are already available
            if let existingTimes = self.viewModel.workingTimes {
                // If there are existing times, update them
                self.viewModel.updateWorkingTimes { updateResult in
                    DispatchQueue.main.async {
                        switch updateResult {
                        case .success(let response):
                            print("Working times updated successfully: \(response)")
                            self.showSuccessAlert(message: "Working times updated successfully.")
                        case .failure(let error):
                            print("Error updating working times: \(error.localizedDescription)")
                            self.showErrorAlert(error: error)
                        }
                    }
                }
            } else {
                // If no existing working times, create new ones
                self.viewModel.postWorkingTimes { postResult in
                    DispatchQueue.main.async {
                        switch postResult {
                        case .success(let response):
                            print("Working times created successfully: \(response)")
                            self.showSuccessAlert(message: "Working times created successfully.")
                        case .failure(let error):
                            print("Error creating working times: \(error.localizedDescription)")
                            self.showErrorAlert(error: error)
                        }
                    }
                }
            }
        } else {
            print("Doctor ID not found in UserDefaults")
            self.showErrorAlert(error: NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Doctor ID not found. Please log in again."]))
        }
    }

    // Helper function to validate time format
    func isValidTimeFormat(timeString: String?) -> Bool {
        guard let time = timeString else { return false }
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm" // Example time format (24-hour format)
        return timeFormatter.date(from: time) != nil
    }

    func hasValidWorkingTimes(_ workingTimes: DoctorWorkingTimes) -> Bool {
        // Check if any of the times are non-nil and have a valid time format
        return (isValidTimeFormat(timeString: workingTimes.sunDayFrom) ||
                isValidTimeFormat(timeString: workingTimes.monDayFrom) ||
                isValidTimeFormat(timeString: workingTimes.tuesDayFrom) ||
                isValidTimeFormat(timeString: workingTimes.wednesDayFrom) ||
                isValidTimeFormat(timeString: workingTimes.thursDayFrom) ||
                isValidTimeFormat(timeString: workingTimes.friDayFrom) ||
                isValidTimeFormat(timeString: workingTimes.saturDayFrom))
    }
    // Check if the working times object has any valid data
//    func hasValidWorkingTimes(_ workingTimes: DoctorWorkingTimes) -> Bool {
//        // Check for non-nil values in working days (you can adjust this depending on the fields you want to check)
//        return workingTimes.sunDayFrom != nil || workingTimes.monDayFrom != nil || workingTimes.tuesDayFrom != nil ||
//        workingTimes.wednesDayFrom != nil || workingTimes.thursDayFrom != nil || workingTimes.friDayFrom != nil ||
//        workingTimes.saturDayFrom != nil
//    }
    
    // Show success alert
    func showSuccessAlert(message: String) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Show error alert
    func showErrorAlert(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
