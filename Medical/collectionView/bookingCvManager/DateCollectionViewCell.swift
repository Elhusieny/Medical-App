import UIKit
class DateCollectionViewCell: UICollectionViewCell {
    override func awakeFromNib() {
          super.awakeFromNib()
          setupUI()
      }

    @IBOutlet weak var dateLabel: UILabel! {
            didSet {
                dateLabel.isUserInteractionEnabled = true // Ensure this is set
            }
        }
        
    let dateLabel1: UILabel = {
           let label = UILabel()
           label.translatesAutoresizingMaskIntoConstraints = false
           label.font = UIFont.systemFont(ofSize: 14)
           label.textColor = .black
           return label
       }()
    
    func configure(with date: String) {
        dateLabel.text = date
    }
    
    func setupUI() {
        self.contentView.layer.cornerRadius = 10 // Set the desired radius
        self.contentView.layer.masksToBounds = true
        // Set border properties
        self.contentView.layer.borderWidth = 2.0 // Set the desired border width
            self.contentView.layer.borderColor = UIColor.white.cgColor // Set the desired border color
    }
    func highlight() {
           self.contentView.backgroundColor = UIColor.lightGray // Change to desired highlight color
       }

       func unhighlight() {
           self.contentView.backgroundColor = UIColor.clear // Change to your original background color
       }
}
   
