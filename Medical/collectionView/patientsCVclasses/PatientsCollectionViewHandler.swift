

import UIKit

class PatientsCollectionViewHandler: NSObject,UICollectionViewDataSource, UICollectionViewDelegate {
    var viewModel: GetAllPatientsViewModel
    
    init(viewModel: GetAllPatientsViewModel) {
        self.viewModel = viewModel
    }
    weak var delegate: PatientsCollectionViewHandlerDelegate?
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.patients.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "PatientsCell", for: indexPath) as! PatientsCollectionViewCell
        
        let patients = viewModel.patients[indexPath.item]
        cell.configure(with: patients)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let selectedPatient = viewModel.patients[indexPath.row]
            delegate?.didSelectPatient(selectedPatient)
        }
    
}
protocol PatientsCollectionViewHandlerDelegate: AnyObject {
    func didSelectPatient(_ patient: Patients)
}
