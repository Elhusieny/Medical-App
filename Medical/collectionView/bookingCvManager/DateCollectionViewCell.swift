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
        

        func configure(with date: String) {
            dateLabel.text = date
        }

        func setupUI() {
            contentView.layer.cornerRadius = 10
                contentView.layer.masksToBounds = true

                // 1) Set the deep-red background
                contentView.backgroundColor = UIColor(red: 139/255,
                                                      green:   0/255,
                                                      blue:    0/255,
                                                      alpha: 1)

                // 2) If you still want a border, you can match it or choose a contrasting color:
                contentView.layer.borderWidth  = 1.5
                contentView.layer.borderColor  = UIColor.white.cgColor
            dateLabel.textColor = .white
            dateLabel.font = UIFont.boldSystemFont(ofSize: 15)
            dateLabel.textAlignment = .center
        }
        
        func highlight() {
            contentView.backgroundColor = UIColor.systemRed
            dateLabel.textColor = .white
        }

        func unhighlight() {
            contentView.backgroundColor = UIColor(named: "CellBackground") ?? UIColor.black
            dateLabel.textColor = .white
        }
    }
