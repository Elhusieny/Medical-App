import UIKit

class DrWorkingTimes: UIViewController {
    
    let viewModel = DrWorkingTimesViewModel()
    let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    var selectedDays: [String] = []
    var workingHours: [String: (startTime: Date, endTime: Date)] = [:]
    var existingWorkingDayId: Int? = nil
    var existingWorkingTimes: [DoctorWorkingDays] = []  // Store fetched working times
    var selectedWorkingDay: DoctorWorkingDays?
    // Assuming you have linked buttons from the storyboard
    @IBOutlet weak var mondayButton: UIButton!
    @IBOutlet weak var tuesdayButton: UIButton!
    @IBOutlet weak var wednesdayButton: UIButton!
    @IBOutlet weak var thursdayButton: UIButton!
    @IBOutlet weak var fridayButton: UIButton!
    @IBOutlet weak var saturdayButton: UIButton!
    @IBOutlet weak var sundayButton: UIButton!
    
    let helperFunctions = HelperFunctions()
    
    @IBOutlet weak var btnSubmitWorkintTimes: UIButton!
    @IBOutlet weak var btnShowSchedule: UIButton!
    let shortDayTitles = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Working Times"
        
        // Setup the back button and other UI elements
        setupNavigationBar()
        
        // Configure buttons
        configureButtons()

        // Fetch existing working days
        fetchExistingWorkingTimes()
        
    }

    func setupNavigationBar() {
        let backImage = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate)
        let backButton = UIButton(type: .system)
        backButton.setImage(backImage, for: .normal)
        backButton.setTitle(" Back", for: .normal)
        backButton.tintColor = .black
        backButton.setTitleColor(.black, for: .normal)
        backButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        
        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backBarButtonItem
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
            let dayTitle = shortDayTitles[index]
            let icon = UIImage(systemName: "calendar")
            helperFunctions.setIconButton2(for: button, withImage: icon, title: dayTitle)
            styleAsWorkingTimeButton(button)
        }
        
        styleAsWorkingTimeButton(btnSubmitWorkintTimes)
        styleAsWorkingTimeButton(btnShowSchedule)
    }
    
    func styleAsWorkingTimeButton(_ button: UIButton) {
        button.setTitleColor(.white, for: .normal)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.backgroundColor = UIColor(red: 139/255, green: 0, blue: 0, alpha: 1)
        button.layer.cornerRadius = 20
        button.tintColor = .white
    }

    // Fetch existing working times
    func fetchExistingWorkingTimes() {
        guard let doctorId = UserDefaults.standard.string(forKey: "DR_ID") else { return }
        guard let token = KeychainHelper.shared.getToken(forKey: "DR_Token") else { return }

        viewModel.fetchWorkingDays(token: token, doctorId: doctorId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedWorkingDays):
                    self.existingWorkingTimes = fetchedWorkingDays
                    
                    // ✅ THIS PART IS VERY IMPORTANT
                    if let firstWorkingDay = fetchedWorkingDays.first {
                        self.existingWorkingDayId = firstWorkingDay.id
                        print("Fetched Existing Working Day ID: \(String(describing: self.existingWorkingDayId))")
                    } else {
                        print("No existing working day found.")
                    }
                    
                case .failure(let error):
                    print("Failed fetching working times: \(error.localizedDescription)")
                }
            }
        }
    }

    func loadExistingWorkingTimesIntoUI() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"  // Updated to 24-hour format

        for day in existingWorkingTimes {
            if let startTime = dateFormatter.date(from: day.sunDayFrom ?? ""),
               let endTime = dateFormatter.date(from: day.sunDayTo ?? "") {
                workingHours["Sunday"] = (startTime, endTime)
            }
            // Repeat for other days...

            // Mark selected days
            if workingHours["Sunday"] != nil {
                selectedDays.append("Sunday")
                // Update the button UI for Sunday (color change, etc.)
                sundayButton.layer.borderColor = UIColor.systemGreen.cgColor
                sundayButton.setTitleColor(.systemGreen, for: .normal)
            }
        }
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
        startTimeStack.spacing = 3
        startTimeStack.alignment = .center
        startTimeStack.translatesAutoresizingMaskIntoConstraints = false
        
        let endTimeStack = UIStackView(arrangedSubviews: [endLabel, endTimePicker])
        endTimeStack.axis = .horizontal
        endTimeStack.spacing = 3
        endTimeStack.alignment = .center
        endTimeStack.translatesAutoresizingMaskIntoConstraints = false
        
        let mainStack = UIStackView(arrangedSubviews: [startTimeStack, endTimeStack])
        mainStack.axis = .vertical
        mainStack.spacing = 5
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
          guard let doctorId = UserDefaults.standard.string(forKey: "DR_ID") else {
              showAlert(title: "Error", message: "Doctor ID not found. Please log in again.")
              return
          }
          print("Working hours before submission: \(workingHours)")
          print("Existing Working Day ID: \(String(describing: existingWorkingDayId))")

          // Prepare the data for posting or updating (working hours and the doctor ID)
          viewModel.prepareWorkingTimesData(selectedDays: workingHours, doctorId: doctorId, existingModelId: existingWorkingDayId)
          
          // Check if we are updating or creating new working times
          if let existingWorkingDayId = existingWorkingDayId {
              // If there's an existing working day, update it
              print("Updating existing working times with ID: \(existingWorkingDayId)")
              viewModel.updateWorkingTimes { result in
                  DispatchQueue.main.async {
                      switch result {
                      case .success(let message):
                          self.showAlert(title: "Success put", message: message)
                          print(message)
                          // Optionally, refresh UI with the updated working times
                      case .failure(let error):
                          self.showAlert(title: "Error", message: "Failed to update working times: \(error.localizedDescription)")
                          print(error)

                      }
                  }
              }
          } else {
              // If there's no existing working day ID, create new working times
              print("Creating new working times.")
              viewModel.postWorkingTimes { result in
                  DispatchQueue.main.async {
                      switch result {
                      case .success(let message):
                          self.showAlert(title: "Success post", message: message)
                          // Optionally, refresh UI with the new working times
                      case .failure(let error):
                          self.showAlert(title: "Error", message: "Failed to create working times: \(error.localizedDescription)")
                      }
                  }
              }
          }
      }


    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
