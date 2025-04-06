import UIKit
class DateCollectionViewManager: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {

    var dates: [String] = []
    var onDateSelected: ((String) -> Void)?

    func setDates(_ dates: [String]) {
        self.dates = dates
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dates.count
    }


func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as! DateCollectionViewCell
        cell.configure(with: dates[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedDate = dates[indexPath.row]
        onDateSelected?(selectedDate)
    }
}
