
import UIKit

class PatientsVC: UIViewController,PatientsCollectionViewHandlerDelegate {
   

    @IBOutlet weak var collectionView: UICollectionView!
    let viewModel = GetAllPatientsViewModel()
    var collectionViewHandler: PatientsCollectionViewHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="All Patients"

        collectionViewHandler = PatientsCollectionViewHandler(viewModel: viewModel)
        collectionViewHandler?.delegate = self

        collectionView.dataSource = collectionViewHandler
        collectionView.delegate = collectionViewHandler
        fetchPatients()
    }
    func fetchPatients() {
        let token = KeychainHelper.shared.getToken(forKey: "DR_Token")
        if let token = token {
            viewModel.fetchPatients(token: token) { success in
                if success {
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()}}
                else {print("Failed to fetch doctors.")}}
        } else {
            print("No token available.")
            
        }
        
    }
    func didSelectPatient(_ patient: Patients) {
            if let detailVC = storyboard?.instantiateViewController(withIdentifier: "patientdatavc") as? PatientDataVC {
                detailVC.patient = patient
                navigationController?.pushViewController(detailVC, animated: true)
            }
        }
}
