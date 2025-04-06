import UIKit

class DoctorsCollectionViewHandler: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    var viewModel: GetAllDoctorsViewModel
    var didSelectDoctor: ((Doctors) -> Void)? // Closure to handle doctor selection
    
    init(viewModel: GetAllDoctorsViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.doctors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DoctorCell", for: indexPath) as! DoctorsCollectionViewCell
        let doctor = viewModel.doctors[indexPath.item]
        cell.configure(with: doctor)
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedDoctor = viewModel.doctors[indexPath.item]
        didSelectDoctor?(selectedDoctor) // Pass the selected doctor to the closure
    }
}
