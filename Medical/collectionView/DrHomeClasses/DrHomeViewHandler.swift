import UIKit

class DrHomeCollectionViewHandler: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    var functions: [(String, String)] = [
        ("Add Prescription", "pills.fill"),
        ("Reservations", "calendar.badge.clock"),
        ("Working Times", "clock.fill"),
        ("History", "doc.text.fill")
    ]

    weak var delegate: DrHomeCollectionViewHandlerDelegate?

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return functions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FunctionCell", for: indexPath) as? DrHomeCollectionViewCell else {
            return UICollectionViewCell()
        }

        let (title, icon) = functions[indexPath.item]
        cell.configure(title: title, iconName: icon)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let function = functions[indexPath.item].0
        delegate?.didSelectFunction(function)
    }
}

protocol DrHomeCollectionViewHandlerDelegate: AnyObject {
    func didSelectFunction(_ function: String)
}
