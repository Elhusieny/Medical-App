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
    
    var workingTimes: PostDrWorkingHoursInDays?
    
    // Prepare working times data for posting
    func prepareWorkingTimesData(selectedDays: [String: (startTime: Date, endTime: Date)], doctorId: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mma"
        
        workingTimes = PostDrWorkingHoursInDays(
            sunDayFrom: selectedDays["Sunday"] != nil ? dateFormatter.string(from: selectedDays["Sunday"]!.startTime) : "string",
            sunDayTo: selectedDays["Sunday"] != nil ? dateFormatter.string(from: selectedDays["Sunday"]!.endTime) : "string",
            monDayFrom: selectedDays["Monday"] != nil ? dateFormatter.string(from: selectedDays["Monday"]!.startTime) : "string",
            monDayTo: selectedDays["Monday"] != nil ? dateFormatter.string(from: selectedDays["Monday"]!.endTime) : "string",
            tuesDayFrom: selectedDays["Tuesday"] != nil ? dateFormatter.string(from: selectedDays["Tuesday"]!.startTime) : "string",
            tuesDayTo: selectedDays["Tuesday"] != nil ? dateFormatter.string(from: selectedDays["Tuesday"]!.endTime) : "string",
            wednesDayFrom: selectedDays["Wednesday"] != nil ? dateFormatter.string(from: selectedDays["Wednesday"]!.startTime) : "string",
            wednesDayTo: selectedDays["Wednesday"] != nil ? dateFormatter.string(from: selectedDays["Wednesday"]!.endTime) : "string",
            thursDayFrom: selectedDays["Thursday"] != nil ? dateFormatter.string(from: selectedDays["Thursday"]!.startTime) : "string",
            thursDayTo: selectedDays["Thursday"] != nil ? dateFormatter.string(from: selectedDays["Thursday"]!.endTime) : "string",
            friDayFrom: selectedDays["Friday"] != nil ? dateFormatter.string(from: selectedDays["Friday"]!.startTime) : "string",
            friDayTo: selectedDays["Friday"] != nil ? dateFormatter.string(from: selectedDays["Friday"]!.endTime) : "string",
            saturDayFrom: selectedDays["Saturday"] != nil ? dateFormatter.string(from: selectedDays["Saturday"]!.startTime) : "string",
            saturDayTo: selectedDays["Saturday"] != nil ? dateFormatter.string(from: selectedDays["Saturday"]!.endTime) : "string",
            doctorId: doctorId
        )
    }
    
    // Post working times via DataService
    func postWorkingTimes(completion: @escaping (Result<String, Error>) -> Void) {
        if let workingTimes = workingTimes {
            PostDrWorkingHoursDataService.shared.postDoctorWorkingTimes(workingTimes: workingTimes, completion: completion)
        }
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

