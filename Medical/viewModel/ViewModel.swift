import Foundation
class DoctorViewModel {
    
    // Public closure to notify the ViewController of the result
    var onRegisterSuccess: (() -> Void)?
    var onRegisterFailure: ((Error?) -> Void)?
    
    // Call this method to register a doctor
    func registerDoctor(with data: PostDoctorData) {
        DataServiceDrRegister.shared.registerDoctor(doctorData: data) { [weak self] success, error in
            if success {
                self?.onRegisterSuccess?()
            } else {
                self?.onRegisterFailure?(error)
            }
        }
    }
}

