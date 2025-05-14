import Foundation
import Combine
import UIKit


class DoctorViewModel {
    
    // Public closure to notify the ViewController of the result
    var onRegisterSuccess: (() -> Void)?
    var onRegisterFailure: ((Error?) -> Void)?
    
    // Call this method to register a doctor
    func registerDoctor(with data: PostDoctorData, imageData: Data?) {
        DataServiceDrRegister.shared.registerDoctor(doctorData: data,imageData: imageData) { [weak self] success, error in
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
class GetAllDoctorsViewModel:ObservableObject {

    @Published var doctors: [Doctors] = []

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


class DoctorDataViewModel: ObservableObject {
    @Published var doctor: DoctorData?
    @Published var error: String?
    @Published var putProfile: UpdateDoctorProfileRequest?
    @Published var selectedImage: UIImage?

    func fetchDoctorData(token: String, completion: @escaping (String?) -> Void) {
        GetDoctorDataService.shared.fetchDoctorData(token: token) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let doctorData):
                    self.doctor = doctorData
                    self.error = nil
                    completion(nil) // no error
                case .failure(let fetchError):
                    self.error = fetchError.localizedDescription
                    self.doctor = nil
                    completion(fetchError.localizedDescription) // send error
                }
            }
        }
    }


    func updateDoctorProfile(token: String, completion: @escaping (String?) -> Void) {
        guard var profileToUpdate = putProfile else {
            completion("No profile data to update.")
            return
        }

        // Convert selected UIImage to Data
        if let image = selectedImage {
            profileToUpdate.image = image.jpegData(compressionQuality: 0.8)
        }

        GetDoctorDataService.shared.updateDoctorProfile(token: token, updatedDoctor: profileToUpdate) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    completion(nil)
                case .failure(let error):
                    completion("Failed to update profile: \(error.localizedDescription)")
                }
            }
        }
    }
}


class PatientRegisterViewModel {
    
    // Public closure to notify the ViewController of the result
    var onRegisterSuccess: (() -> Void)?
    var onRegisterFailure: ((Error?) -> Void)?
    
    // Call this method to register a patient
    func registerPatient(with data: PostPatientData, imageData: Data?) {
        PostPatientRegisterDataService.shared.registerPatient(patientData: data, imageData: imageData) { [weak self] success, error in
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
    private var workingDays: [DoctorWorkingDays] = []

    var postWorkingTimesModel: PostDrWorkingHoursInDays?
    var updateWorkingTimesModel: DoctorWorkingDays?
    
    @Published var isEditing = false
    @Published var isUpdating = false
    @Published var errorMessage: String?
    @Published var updateSuccess = false
    
    // MARK: - Prepare Data
    func prepareWorkingTimesData(selectedDays: [String: (startTime: Date, endTime: Date)], doctorId: String, existingModelId: Int? = nil) {
        
        let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "HH:mm:ss"  // Updated to 24-hour format
           
        
        postWorkingTimesModel = PostDrWorkingHoursInDays(
            sunDayFrom: selectedDays["Sunday"] != nil ? dateFormatter.string(from: selectedDays["Sunday"]!.startTime) : nil,
            sunDayTo: selectedDays["Sunday"] != nil ? dateFormatter.string(from: selectedDays["Sunday"]!.endTime) : nil,
            monDayFrom: selectedDays["Monday"] != nil ? dateFormatter.string(from: selectedDays["Monday"]!.startTime) : nil,
            monDayTo: selectedDays["Monday"] != nil ? dateFormatter.string(from: selectedDays["Monday"]!.endTime) : nil,
            tuesDayFrom: selectedDays["Tuesday"] != nil ? dateFormatter.string(from: selectedDays["Tuesday"]!.startTime) : nil,
            tuesDayTo: selectedDays["Tuesday"] != nil ? dateFormatter.string(from: selectedDays["Tuesday"]!.endTime) : nil,
            wednesDayFrom: selectedDays["Wednesday"] != nil ? dateFormatter.string(from: selectedDays["Wednesday"]!.startTime) : nil,
            wednesDayTo: selectedDays["Wednesday"] != nil ? dateFormatter.string(from: selectedDays["Wednesday"]!.endTime) : nil,
            thursDayFrom: selectedDays["Thursday"] != nil ? dateFormatter.string(from: selectedDays["Thursday"]!.startTime) : nil,
            thursDayTo: selectedDays["Thursday"] != nil ? dateFormatter.string(from: selectedDays["Thursday"]!.endTime) : nil,
            friDayFrom: selectedDays["Friday"] != nil ? dateFormatter.string(from: selectedDays["Friday"]!.startTime) : nil,
            friDayTo: selectedDays["Friday"] != nil ? dateFormatter.string(from: selectedDays["Friday"]!.endTime) : nil,
            saturDayFrom: selectedDays["Saturday"] != nil ? dateFormatter.string(from: selectedDays["Saturday"]!.startTime) : nil,
            saturDayTo: selectedDays["Saturday"] != nil ? dateFormatter.string(from: selectedDays["Saturday"]!.endTime) : nil,
            doctorId: doctorId
        )
        
        // if existing id is provided -> editing
        if let existingId = existingModelId {
            isEditing = true
            updateWorkingTimesModel = DoctorWorkingDays(
                id: existingId,
                sunDayFrom: postWorkingTimesModel?.sunDayFrom,
                sunDayTo: postWorkingTimesModel?.sunDayTo,
                monDayFrom: postWorkingTimesModel?.monDayFrom,
                monDayTo: postWorkingTimesModel?.monDayTo,
                tuesDayFrom: postWorkingTimesModel?.tuesDayFrom,
                tuesDayTo: postWorkingTimesModel?.tuesDayTo,
                wednesDayFrom: postWorkingTimesModel?.wednesDayFrom,
                wednesDayTo: postWorkingTimesModel?.wednesDayTo,
                thursDayFrom: postWorkingTimesModel?.thursDayFrom,
                thursDayTo: postWorkingTimesModel?.thursDayTo,
                friDayFrom: postWorkingTimesModel?.friDayFrom,
                friDayTo: postWorkingTimesModel?.friDayTo,
                saturDayFrom: postWorkingTimesModel?.saturDayFrom,
                saturDayTo: postWorkingTimesModel?.saturDayTo,
                doctorId: doctorId
            )
        } else {
            isEditing = false
        }
    }
    // MARK: - Submit Function (Post or Update)
    func submitWorkingTimes(completion: @escaping (Result<String, Error>) -> Void) {
        if isEditing {
            updateWorkingTimes(completion: completion)
        } else {
            postWorkingTimes(completion: completion)
        }
    }
    
//    private func postWorkingTimes(completion: @escaping (Result<String, Error>) -> Void) {
//        guard let postModel = postWorkingTimesModel else {
//            completion(.failure(NSError(domain: "No data to post", code: 0)))
//            return
//        }
//        PostDrWorkingHoursDataService.shared.postDoctorWorkingTimes(workingTimes: postModel, completion: completion)
//    }
    // Fetch Working Days from API
       func fetchWorkingDays(token: String, doctorId: String, completion: @escaping (Result<[DoctorWorkingDays], Error>) -> Void) {
           PostDrWorkingHoursDataService.shared.fetchDoctorWorkingDays(token: token, doctorId: doctorId) { result in
               switch result {
               case .success(let fetchedWorkingDays):
                   self.workingDays = fetchedWorkingDays
                   completion(.success(fetchedWorkingDays))
               case .failure(let error):
                   completion(.failure(error))
               }
           }
       }
    // Get the working days
        func getWorkingDays() -> [DoctorWorkingDays] {
            return workingDays
        }
//    private func updateWorkingTimes(completion: @escaping (Result<String, Error>) -> Void) {
//        guard let updateModel = updateWorkingTimesModel else {
//            completion(.failure(NSError(domain: "No data to update", code: 0)))
//            return
//        }
//        PostDrWorkingHoursDataService.shared.updateDoctorWorkingDays(updateModel) { [weak self] result in
//            DispatchQueue.main.async {
//                self?.isUpdating = false
//                switch result {
//                case .success:
//                    self?.updateSuccess = true
//                    completion(.success("Working times updated successfully"))
//                case .failure(let error):
//                    self?.errorMessage = error.localizedDescription
//                    completion(.failure(error))
//                }
//            }
//        }
//    }
    // For creating new working times (POST)
    func postWorkingTimes(completion: @escaping (Result<String, Error>) -> Void) {
        guard let postModel = postWorkingTimesModel else {
            completion(.failure(NSError(domain: "No data to post", code: 0)))
            return
        }
        PostDrWorkingHoursDataService.shared.postDoctorWorkingTimes(workingTimes: postModel, completion: completion)
    }

    // For updating existing working times (PUT)
    func updateWorkingTimes(completion: @escaping (Result<String, Error>) -> Void) {
        guard let updateModel = updateWorkingTimesModel else {
            completion(.failure(NSError(domain: "No data to update", code: 0)))
            return
        }
        guard let token = KeychainHelper.shared.getToken(forKey: "DR_Token") else {
            return
        }
        PostDrWorkingHoursDataService.shared.updateDoctorWorkingDays(updateModel, token: token) { [weak self] result in
            DispatchQueue.main.async {
                self?.isUpdating = false
                switch result {
                case .success:
                    self?.updateSuccess = true
                    completion(.success("Working times updated successfully"))
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                }
            }
        }
    }
}
class BookingViewModel: ObservableObject {
    @Published var availableTimes: [ResultInterval] = []
    @Published var selectedDate: String?
    @Published var selectedTime: ResultInterval?
    
    func fetchDoctorTimes(token: String, doctorId: String, completion: @escaping () -> Void) {
        DataServices.shared.fetchDoctorTimes(token: token, doctorId: doctorId) { [weak self] times, error in
            DispatchQueue.main.async {
                if let times = times {
                    self?.availableTimes = times
                } else {
                    print("Error fetching doctor times: \(error?.localizedDescription ?? "")")
                }
                completion()
            }
        }
    }
    
    var availableDates: [String] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let isoFormatter = DateFormatter()
        isoFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSSS"
        
        let dateStrings = availableTimes.compactMap { slot -> String? in
            guard let date = isoFormatter.date(from: slot.intervalStart) else { return nil }
            return dateFormatter.string(from: date)
        }
        
        return Array(Set(dateStrings)).sorted()
    }
    
    
    var filteredSlots: [ResultInterval] {
        guard let selectedDate = selectedDate else { return [] }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let isoFormatter = DateFormatter()
        isoFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSSS"
        
        return availableTimes.filter { slot in
            if let date = isoFormatter.date(from: slot.intervalStart) {
                return dateFormatter.string(from: date) == selectedDate
            }
            return false
        }
    }
    
    
    func bookAppointment(token: String, patientId: String, doctorId: String, completion: @escaping (Bool) -> Void) {
        guard let selectedTime = selectedTime else {
            completion(false)
            return
        }
        
        let raw = selectedTime.intervalStart            // "2025-05-13 12:10:39.0000000"
        let iso = raw
          .replacingOccurrences(of: " ", with: "T")      // "2025-05-13T12:10:39.0000000"
          + "Z"                                         // "2025-05-13T12:10:39.0000000Z"

        let bookDate = BookDate(
          doctorId: doctorId,
          doctorTimeIntervalId: selectedTime.id,
          intervalStart: iso,
          patientId: patientId
        )
        
        DataServices.shared.bookAppointment(token: token, bookDate: bookDate) { success, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error booking appointment: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("✅ Appointment booked successfully")
                    completion(success)
                }
            }
        }
    }
}


//handle logic between api and view
class PatientProfileViewModel: ObservableObject {
    @Published var profile: GetPatientProfileData?
    @Published var putProfile: UpdatePatientProfileRequest?
    @Published var selectedImage: UIImage?

    // Fetch patient profile data
    func fetchProfile(id: String, token: String, completion: @escaping (String?) -> Void) {
        DataServices.shared.getPatientProfile(id: id, token: token) { result in
            DispatchQueue.main.async {
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

    func updateProfileWithImage(token: String, completion: @escaping (String?) -> Void) {
        guard var profileToUpdate = putProfile else {
            completion("No profile data to update.")
            return
        }

        // Convert UIImage to Data before assigning
        if let image = selectedImage {
            profileToUpdate.image = image.jpegData(compressionQuality: 0.8)
        }

        DataServices.shared.updatePatientProfileWithImage(profileToUpdate, token: token) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    completion(nil)
                case .failure(let error):
                    completion("Failed to update profile: \(error.localizedDescription)")
                }
            }
        }
    }
}

//get patient by code
class PatientViewModel: ObservableObject {
    @Published var patient: GetPatientByCode?
    @Published var errorMessage: String?
    
    func getPatient(byCode code: Int, token: String) {
        DataServices.shared.fetchPatient(byCode: code, token: token) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let patient):
                    self.patient = patient
                            // ✅ Save patient ID to UserDefaults
                        UserDefaults.standard.set(patient.id, forKey: "PATIENT_ID")
                    print("get patient id by patient code\(patient.id)")
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
class RoshetaViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var successMessage: String?

    func submitRosheta(diagnosis: String, medicine: String, analysis: String, xRays: String, notes: String) {
        guard let token = KeychainHelper.shared.getToken(forKey: "DR_Token"),
              let doctorId = UserDefaults.standard.string(forKey: "DR_ID"),
              let patientId = UserDefaults.standard.string(forKey: "PATIENT_ID") else {
            errorMessage = "Missing required credentials."
            return
        }

        let rosheta = RoshetaRequest(
            diagnosis: diagnosis,
            medicine: medicine,
            analysis: analysis,
            x_Rays: xRays,
            additionalNotes: notes,
            doctorId: doctorId,
            patientId: patientId
        )

        RoshetaService.shared.postRosheta(rosheta, token: token) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.successMessage = "Rosheta sent successfully!"
                    print (self.successMessage ?? "empty")
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
class PrescriptionViewModel: ObservableObject {
   
    @Published var prescriptions: [RoshetaHistoryModel] = []
    @Published var errorMessage: String?

    func loadPrescriptions() {
        guard let doctorId = UserDefaults.standard.string(forKey: "DR_ID"),
              let token = KeychainHelper.shared.getToken(forKey: "DR_Token") else {
            errorMessage = "Missing doctor ID or token"
            return
        }

        PrescriptionService.fetchPrescriptionsByDoctorId(doctorId: doctorId, token: token) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let list):
                    self?.prescriptions = list
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}



class PatientBookingViewModel: ObservableObject {
    @Published var patientBookings: [PatientBooking] = []
    @Published var errorMessage: String?

    func fetchPatientBookings(for doctorId: String) {
        print("📥 Fetching bookings for doctorId: \(doctorId)")
        PatientBookingService.shared.getAllPatientsBooking(doctorId: doctorId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let bookings):
                    print("✅ Bookings received: \(bookings.count)")
                    self?.patientBookings = bookings
                case .failure(let error):
                    print("❌ Error received: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

}
