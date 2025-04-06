import UIKit

class HomeVC: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    let viewModel = GetAllDoctorsViewModel()
    var collectionViewHandler: DoctorsCollectionViewHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="Home"
        collectionViewHandler = DoctorsCollectionViewHandler(viewModel: viewModel)
        collectionView.dataSource = collectionViewHandler
        collectionView.delegate = collectionViewHandler
        
        // Set up the closure to handle doctor selection
        collectionViewHandler?.didSelectDoctor = { [weak self] selectedDoctor in
            self?.performSegue(withIdentifier: "showDoctorDetails", sender: selectedDoctor)
        }
        
        fetchDoctors()
    }
    
    func fetchDoctors() {
        let token = KeychainHelper.shared.getToken(forKey: "DR_Token")
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
}
