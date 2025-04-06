
import UIKit

class TimeCollectionViewCell: UICollectionViewCell {
    
    override func awakeFromNib() {
            super.awakeFromNib()
            setupUI()
        }
    @IBOutlet weak var timeLabel: UILabel!
    let timeLabel1: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = .gray
            return label
        }()

    func configure(with time: ResultInterval) {
        timeLabel.text = "\(time.intervalStart) - \(time.intervalEnd)"
    }
    
    func setupUI() {
            self.contentView.layer.cornerRadius = 10 // Set the desired radius
            self.contentView.layer.masksToBounds = true

        // Set border properties
        self.contentView.layer.borderWidth = 2.0 // Set the desired border width
            self.contentView.layer.borderColor = UIColor.white.cgColor // Set the desired border color
        }
   
}
