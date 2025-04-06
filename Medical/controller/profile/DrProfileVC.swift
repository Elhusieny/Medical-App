import UIKit

class DoctorProfileVC: UIViewController {

    var gradientLayer: CAGradientLayer?

    @IBOutlet weak var exampleView: UIView! // Assuming you have a UIView connected via IBOutlet
    @IBOutlet weak var laAppointments: UILabel!
    @IBOutlet weak var laPersonalInfo: UILabel!
    @IBOutlet weak var laFaqs: UILabel!
    @IBOutlet weak var laLogout: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="Profile"
        // Set corner radius
        exampleView.layer.cornerRadius = 20 // Adjust the radius as needed
        exampleView.layer.masksToBounds = true // Ensure that subviews are clipped to the rounded corners

        // Set up gradient background
        setupGradientBackground()

        // Set icons for labels
        setIconAtEnd(for: laPersonalInfo, withImage:  UIImage(named: "arrowRight"))
        setIconAtEnd(for: laFaqs, withImage:  UIImage(named: "arrowRight"))
        setIconAtEnd(for: laLogout, withImage:  UIImage(named: "arrowRight"))
        setIconAtEnd(for: laAppointments, withImage:  UIImage(named: "arrowRight"))

        // Add tap gesture recognizers
        addTapGestureToLabel(label: laPersonalInfo, action: #selector(personalInfoTapped))
        addTapGestureToLabel(label: laAppointments, action: #selector(appointmentsTapped))
        addTapGestureToLabel(label: laFaqs, action: #selector(faqsTapped))
        addTapGestureToLabel(label: laLogout, action: #selector(logoutTapped))
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Ensure the gradient layer's frame matches the view's bounds
        gradientLayer?.frame = view.bounds
    }

    private func setupGradientBackground() {
        // Remove any existing gradient layer to avoid stacking
        gradientLayer?.removeFromSuperlayer()

        // Create and configure the gradient layer
        gradientLayer = CAGradientLayer()
        gradientLayer?.colors = [UIColor.green.cgColor, UIColor.white.cgColor]
        gradientLayer?.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer?.endPoint = CGPoint(x: 0, y: 1)

        if let gradientLayer = gradientLayer {
            gradientLayer.frame = view.bounds
            view.layer.insertSublayer(gradientLayer, at: 0)
        }
    }

    // Helper function to add an icon at the end of a UILabel with padding
    func setIconAtEnd(for label: UILabel, withImage image: UIImage?) {
        guard let image = image else { return }

        // Create an NSTextAttachment with the image
        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(x: 0, y: -5, width: 24, height: 24) // Adjust image size and position

        // Create an attributed string with the label text
        let attributedString = NSMutableAttributedString(string: label.text ?? "")

        // Add space before the image
        let spaceString = NSAttributedString(string: "  ") // This adds space between the text and the image
        attributedString.append(spaceString)

        // Append the image at the end of the label text
        let imageString = NSAttributedString(attachment: attachment)
        attributedString.append(imageString)

        // Set the label's attributedText
        label.attributedText = attributedString
    }

    // Add tap gesture recognizer to a label
    private func addTapGestureToLabel(label: UILabel, action: Selector) {
        let tapGesture = UITapGestureRecognizer(target: self, action: action)
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tapGesture)
    }

    // Action when laPersonalInfo is tapped
    @objc func personalInfoTapped() {
        navigateToDoctorDataVC()
    }

    // Action when laAppointments is tapped
    @objc func appointmentsTapped() {
        navigateToDoctorDataVC()
    }

    // Action when laFaqs is tapped
    @objc func faqsTapped() {
        navigateToDoctorDataVC()
    }

    // Action when laLogout is tapped
    @objc func logoutTapped() {
        navigateToDoctorDataVC()
    }

    // Navigate to DoctorDataViewController
    private func navigateToDoctorDataVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let doctorDataVC = storyboard.instantiateViewController(withIdentifier: "drprofiledatavc") as? DrProfileDataVC {
            navigationController?.pushViewController(doctorDataVC, animated: true)
        }
    }
}
