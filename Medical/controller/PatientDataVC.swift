
import UIKit

class PatientDataVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView! // Connect this from storyboard

      var patient: Patients? // The selected patient will be passed here
      var patientDetails: [(String, String)] = [] // Array of tuples for the data
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="Patient Data"
        // Set up the table view
        tableView.dataSource = self
        tableView.delegate = self
    
        
        // Fill the array with the patient's data
        if let patient = patient {
            patientDetails = [
                ("Name", patient.userName),
                ("National ID", patient.nationalID),
                ("Patient Code", "\(patient.patientCode)"),
                ("Phone", patient.phone),
                ("Address", patient.address),
                ("Current Medications", "\(patient.currentMedications ?? "Empty")"),
                ("Chronic Disease", "\(patient.chronicDiseases ?? "null")"),
                ("Comments", "\(patient.comments ?? "no Comments")")

            ]
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return patientDetails.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Reuse a table view cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "PatientDetailCell", for: indexPath)
        
        // Get the corresponding patient detail
        let detail = patientDetails[indexPath.row]
        
        // Set the cell's text labels
        cell.textLabel?.text = detail.0   // e.g., "Name", "National ID", "Phone"
        cell.detailTextLabel?.text = detail.1 // e.g., the corresponding value

        return cell
    }

    // MARK: - UITableViewDelegate Methods

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60 // Set the preferred height for each row
    }
}
        

    
