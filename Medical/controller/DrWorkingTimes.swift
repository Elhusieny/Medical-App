import UIKit

class DrWorkingTimes: UIViewController {
    
    let viewModel = DrWorkingTimesViewModel()
    let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
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
    let shortDayTitles = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

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
            let dayTitle = shortDayTitles[index]
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
           if let doctorId = UserDefaults.standard.string(forKey: "DR_ID") {
               print("Doctor ID: \(doctorId)")
               
               viewModel.prepareWorkingTimesData(selectedDays: workingHours, doctorId: doctorId)
               viewModel.postWorkingTimes { result in
                   DispatchQueue.main.async { // Ensure UI updates are on the main thread
                       switch result {
                       case .success(let response):
                           print("Success: \(response)")
                           // Show success message
                           let successAlert = UIAlertController(title: "Success", message: response, preferredStyle: .alert)
                           successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                           self.present(successAlert, animated: true, completion: nil)
                           
                       case .failure(let error):
                           print("Error: \(error.localizedDescription)")
                           // Show error message
                           let errorAlert = UIAlertController(title: "Error", message: "Failed to submit working times: \(error.localizedDescription)", preferredStyle: .alert)
                           errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                           self.present(errorAlert, animated: true, completion: nil)
                       }
                   }
               }
           } else {
               print("Doctor ID not found in UserDefaults")
               // Optionally show an alert if the doctor ID is not found
               let alert = UIAlertController(title: "Error", message: "Doctor ID not found. Please log in again.", preferredStyle: .alert)
               alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
               present(alert, animated: true, completion: nil)
           }
       }
   }
