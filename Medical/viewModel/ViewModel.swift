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
                self?.onRegisterFailure?(error ?? NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"]))
            }
        }
    }
}
class DoctorLoginViewModel {
    
    // Function to handle login
    func login(doctorLoginData: DoctorLoginData, completion: @escaping (Result<DoctorLoginResponse, Error>) -> Void) {
        DoctorLoginDataService.sharedDrLogin.login(doctorLoginData: doctorLoginData) { result in
            completion(result) // Pass the result back to the caller
        }
    }
}
class GetAllDoctorsViewModel {

        var doctors: [Doctors] = []
        
        func fetchDoctors(token: String, completion: @escaping (Bool) -> Void) {
            GetAllDoctorsDataServices.shared.fetchDoctors(token: token) { result in
                switch result {
                case .success(let doctors):
                    self.doctors = doctors
                    completion(true)
                case .failure(let error):
                    print("Error fetching doctors: \(error)")
                    completion(false)
                }
            }
        }
    }
class GetAllPatientsViewModel{
    var patients:[Patients]=[]
    func fetchPatients(token: String, completion: @escaping (Bool) -> Void)
    {
        GetAllPatientsDataServices.shared.fetchPatientsData(token: token)
        {
             result in
               switch result {
               case .success(let patients):
                   self.patients = patients
                   completion(true)
               case .failure(let error):
                   print("Error fetching doctors: \(error)")
                   completion(false)}}}
}


class DoctorDataViewModel {
    // Observable properties
    var doctor: DoctorData?
    var error: String?
    var putProfile: UpdateDoctorProfileRequest?


    func fetchDoctorData(token: String, completion: @escaping () -> Void) {
        GetDoctorDataService.shared.fetchDoctorData(token: token) { result in
            switch result {
            case .success(let doctorData):
                // Update the data
                self.doctor = doctorData
                self.error = nil
            case .failure(let fetchError):
                // Handle the error
                self.error = fetchError.localizedDescription
                self.doctor = nil
            }
            // Call completion handler to update the UI
            completion()
        }
    }

    func updateDoctorProfile(token: String, completion: @escaping (String?) -> Void) {
        guard let putProfile = putProfile else {
            completion("No profile data to update")
            return
        }
        
        GetDoctorDataService.shared.updateDoctorProfile(token: token, updatedDoctor: putProfile, completion: completion)
    }

}

class PatientRegisterViewModel {
    
    // Public closure to notify the ViewController of the result
    var onRegisterSuccess: (() -> Void)?
    var onRegisterFailure: ((Error?) -> Void)?
    
    // Call this method to register a patient
    func registerPatient(with data: PostPatientData) {
        PostPatientRegisterDataService.shared.registerPatient(patientData: data) { [weak self] success, error in
            if success {
                self?.onRegisterSuccess?()
            } else {
                self?.onRegisterFailure?(error)
            }
        }
    }
}
class PatientLoginViewModel {
    
    // Function to handle login
    func login(patientLoginData:PatientLoginData, completion: @escaping (Result<PatientLoginResponse, Error>) -> Void) {
        PatientLoginDataService.sharedPatientLogin.login(patientLoginData: patientLoginData) { result in
            completion(result) // Pass the result back to the caller
        }
    }
}
class DrWorkingTimesViewModel {
    
    var workingTimes: DoctorWorkingTimes?
    
    func prepareWorkingTimesData(selectedDays: [String: (startTime: Date, endTime: Date)], doctorId: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        workingTimes = DoctorWorkingTimes(
            id: nil,
            doctorId: doctorId,
            sunDayFrom: selectedDays["Sun"].map { formatter.string(from: $0.startTime) },
            sunDayTo: selectedDays["Sun"].map { formatter.string(from: $0.endTime) },
            monDayFrom: selectedDays["Mon"].map { formatter.string(from: $0.startTime) },
            monDayTo: selectedDays["Mon"].map { formatter.string(from: $0.endTime) },
            tuesDayFrom: selectedDays["Tue"].map { formatter.string(from: $0.startTime) },
            tuesDayTo: selectedDays["Tue"].map { formatter.string(from: $0.endTime) },
            wednesDayFrom: selectedDays["Wed"].map { formatter.string(from: $0.startTime) },
            wednesDayTo: selectedDays["Wed"].map { formatter.string(from: $0.endTime) },
            thursDayFrom: selectedDays["Thu"].map { formatter.string(from: $0.startTime) },
            thursDayTo: selectedDays["Thu"].map { formatter.string(from: $0.endTime) },
            friDayFrom: selectedDays["Fri"].map { formatter.string(from: $0.startTime) },
            friDayTo: selectedDays["Fri"].map { formatter.string(from: $0.endTime) },
            saturDayFrom: selectedDays["Sat"].map { formatter.string(from: $0.startTime) },
            saturDayTo: selectedDays["Sat"].map { formatter.string(from: $0.endTime) }
        )
        
        // Debug JSON
        if let encoded = try? JSONEncoder().encode(workingTimes),
           let jsonString = String(data: encoded, encoding: .utf8) {
            print("Prepared JSON for submission: \(jsonString)")
        }
    }
    
    func postWorkingTimes(completion: @escaping (Result<String, Error>) -> Void) {
        guard let times = workingTimes else { return }
        
        // Get token from Keychain
        guard let token = KeychainHelper.shared.getToken(forKey: "DR_Token") else {
            print("❌ Token not found")
            return
        }
        
        DataService.shared.postDoctorWorkingTimes(times: times, token: token) { result in
            completion(result)
        }
    }
    
    func updateWorkingTimes(completion: @escaping (Result<String, Error>) -> Void) {
        guard let times = workingTimes else { return }
        
        // Get token from Keychain
        guard let token = KeychainHelper.shared.getToken(forKey: "DR_Token") else {
            print("❌ Token not found")
            return
        }
        
        DataService.shared.updateDoctorWorkingTimes(times: times, token: token) { result in
            completion(result)
        }
    }
    
    func fetchWorkingTimes(doctorId: String, completion: @escaping (Result<DoctorWorkingTimes, Error>) -> Void) {
        guard let token = KeychainHelper.shared.getToken(forKey: "DR_Token") else {
            print("❌ Token not found")
            return
        }
        
        DataService.shared.fetchDoctorWorkingTimes(doctorId: doctorId,token: token, completion: completion)
    }
}

class DoctorStoredWorkingTimesViewModel: ObservableObject {
    @Published var workingTimes: [ResultInterval] = []
    @Published var errorMessage: String? = nil
    
    func getDoctorWorkingTimes(doctorId: String, token: String) {
        GetAllStoredWorkingTimesDataService.shared.fetchDoctorWorkingTimes(doctorId: doctorId, token: token) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let times):
                    self?.workingTimes = times
                case .failure(let error):
                    self?.errorMessage = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}
class BookingViewModel {
    var availableTimes: [ResultInterval] = []
    var selectedDate: String?
    var selectedTime: ResultInterval?

    func fetchDoctorTimes(token: String, doctorId: String, completion: @escaping () -> Void) {
        DataServices.shared.fetchDoctorTimes(token: token, doctorId: doctorId) { [weak self] times, error in
            if let times = times {
                self?.availableTimes = times
                completion()
            } else {
                print("Error fetching doctor times: \(error?.localizedDescription ?? "")")
            }
        }
    }

    func bookAppointment(token: String, patientId: String, completion: @escaping (Bool) -> Void) {
        guard let selectedDate = selectedDate, let selectedTime = selectedTime else {
            completion(false)
            return
        }

        let bookDate = BookDate(patientId: patientId, doctorTimeIntervalId: selectedTime.id) // Ensure this is the correct property
        DataServices.shared.bookAppointment(token: token, bookDate: bookDate) { success, error in
            if let error = error {
                print("Error booking appointment: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(success)
            }
        }
    }
}
//handle logic between api and view
class PatientProfileViewModel {
    var profile: PatientProfile?
    
    var putProfile:UpdatePatientProfileRequest?
    func fetchProfile(id: String, token: String, completion: @escaping (String?) -> Void) {
        DataServices.shared.getPatientProfile(id: id, token: token) { result in
            switch result {
            case .success(let data):
                self.profile = data
                completion(nil)
            case .failure(let error):
                completion("Failed to fetch profile: \(error.localizedDescription)")
            }
        }
    }
}
import Alamofire

extension PatientProfileViewModel {
    func updateProfile(token: String, completion: @escaping (String?) -> Void) {
        guard let updatedProfile = putProfile else {
            completion("No profile data to update.")
            return
        }

        // Make the update request through DataServices
        DataServices.shared.updatePatientProfile(id: updatedProfile.id, updatedProfile: updatedProfile, token: token) { result in
            switch result {
            case .success:
                completion(nil) // Success
            case .failure(let error):
                completion("Failed to update profile: \(error.localizedDescription)")
            }
        }
    }
}
