

import UIKit

class PatientsCollectionViewCell: UICollectionViewCell {
    
    
     @IBOutlet weak var laNationalID: UILabel!
     
     @IBOutlet weak var laName: UILabel!
     
     @IBOutlet weak var imageView: UIImageView!
     // Configure the cell with doctor's data
         func configure(with patient: Patients) {
             laName.text = patient.userName
             laNationalID.text = patient.nationalID
             // Set image from assets
                     imageView.image = UIImage(named: "patients")
             imageView.contentMode = .scaleAspectFit
             setupCell()
         }
    override func awakeFromNib() {
            super.awakeFromNib()
            // Enable user interaction
            self.isUserInteractionEnabled = true
        }
    private func setupCell() {
            // Set the corner radius
            self.contentView.layer.cornerRadius = 10.0
            self.contentView.layer.masksToBounds = true // Ensures the content clips to the rounded corners

            // Optionally, add a border to the cell
            self.contentView.layer.borderWidth = 1.0
            self.contentView.layer.borderColor = UIColor.lightGray.cgColor

            // Apply shadow to the whole cell (outside content view)
            self.layer.shadowColor = UIColor.white.cgColor
            self.layer.shadowOpacity = 0.2
            self.layer.shadowRadius = 4
            self.layer.shadowOffset = CGSize(width: 2, height: 2)
            self.layer.masksToBounds = false // Allow shadow to appear outside the bounds
        }
   
    
    
}
