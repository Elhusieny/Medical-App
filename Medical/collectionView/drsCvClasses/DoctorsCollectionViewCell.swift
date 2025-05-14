import UIKit
import SDWebImage

class DoctorsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var laSpecialization: UILabel!
    
    @IBOutlet weak var laName: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    // Configure the cell with doctor's data
    func configure(with doctor: Doctors) {
        setupCell()
        
        layoutSubviews()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 120),
            imageView.heightAnchor.constraint(equalToConstant: 120)
        ])

        laName.text = doctor.userName
        laSpecialization.text = doctor.specialization
        // Set image from assets
        
        // Placeholder (in case loading is slow)
            imageView.image = UIImage(systemName: "person.crop.circle") // Use system image as placeholder

            if let imagePath = doctor.imagePath,
               !imagePath.isEmpty,
               let url = URL(string: imagePath) {
                imageView.sd_setImage(
                    with: url,
                    placeholderImage: UIImage(systemName: "person.crop.circle"), // Use SF Symbol as placeholder
                    options: [.retryFailed, .refreshCached],
                    completed: nil
                )
            } else {
                imageView.image = UIImage(systemName: "person.crop.circle") // Fallback default image
            }
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
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 2
        imageView.contentMode = .scaleAspectFill
    }
}
