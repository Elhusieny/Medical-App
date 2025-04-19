import UIKit

class TimeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    func configure(with time: ResultInterval) {
        timeLabel.text = "\(time.intervalStart) - \(time.intervalEnd)"
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
        
        timeLabel.textColor = .white
        timeLabel.font = UIFont.boldSystemFont(ofSize: 16)
        timeLabel.textAlignment = .center
    }
    
    func highlight() {
        contentView.backgroundColor = UIColor.systemRed
        timeLabel.textColor = .white
    }

    func unhighlight() {
        contentView.backgroundColor = UIColor(named: "CellBackground") ?? UIColor.black
        timeLabel.textColor = .white
    }
}
