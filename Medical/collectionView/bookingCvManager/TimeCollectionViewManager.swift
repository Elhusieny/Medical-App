import UIKit
import Foundation
class TimeCollectionViewManager: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    private var times: [ResultInterval] = []
    var onTimeSelected: ((ResultInterval) -> Void)?

    func setTimes(_ newTimes: [ResultInterval]) {
        times = newTimes
        // Log the number of times set for debugging
        print("Number of times set: \(times.count)")
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return times.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeCell", for: indexPath) as! TimeCollectionViewCell
        let time = times[indexPath.item]
        cell.configure(with: time) // Make sure this method is defined in TimeCollectionViewCell
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedTime = times[indexPath.item]
        print("Selected Time: \(selectedTime)") // Debugging output
        onTimeSelected?(selectedTime)
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50) // Example size
    }

}
