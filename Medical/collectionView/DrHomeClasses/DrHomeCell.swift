import UIKit

class DrHomeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    func configure(title: String, iconName: String) {
            titleLabel.text = title
            iconImageView.image = UIImage(systemName: iconName)
            iconImageView.tintColor = .white // Set icon color to white
            titleLabel.textColor = .white    // Set text color to white
            setupCellAppearance()
        }

        private func setupCellAppearance() {
            contentView.backgroundColor = UIColor(red: 139/255, green: 0, blue: 0, alpha: 1) // Dark red color

            contentView.layer.cornerRadius = 10
            contentView.layer.borderWidth = 1
            contentView.layer.borderColor = UIColor.systemGray4.cgColor
            contentView.layer.masksToBounds = true

            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.1
            layer.shadowOffset = CGSize(width: 2, height: 2)
            layer.shadowRadius = 4
            layer.masksToBounds = false

            // Adjust the image and label to be centered inside the cell
            adjustImageAndLabelSize()
        }

    private func adjustImageAndLabelSize() {
           // Set image size (increase the size, for example 80x80)
           iconImageView.frame.size = CGSize(width: 80, height: 80) // Larger image size
           iconImageView.contentMode = .scaleAspectFit
           
           // Set label font size and make it bold
           titleLabel.font = UIFont.boldSystemFont(ofSize: 16) // Bold and adjusted font size
           titleLabel.numberOfLines = 2 // Allow for two lines of text if needed
           
           // Make sure the image and label are centered in the cell using Auto Layout
           iconImageView.translatesAutoresizingMaskIntoConstraints = false
           titleLabel.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([
               // Center the image view horizontally and vertically
               iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
               iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -10), // Adjust as needed
               
               // Center the label horizontally below the image view
               titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
               titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 8) // Adjust the spacing as needed
           ])
       }

       override func awakeFromNib() {
           super.awakeFromNib()
           isUserInteractionEnabled = true
       }
   }
