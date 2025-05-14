import Foundation
import Alamofire
struct DataServiceDrRegister {
    //DataService: Handles the network request to register the doctor.It is responsible for interacting with the API.
    //DataServices Is achieved Single Responsibility Principle (SRP)
    
    // MARK: - Singleton
    //Singleton Pattern
   // Used in DataService to provide a single shared instance across the app.
    static let shared = DataServiceDrRegister()
    
    // MARK: - URL
    
let doctorRegisterUrl = URLS.doctorRegisterUrl
    
    // MARK: - Services
    func registerDoctor(doctorData: PostDoctorData,imageData:Data?, completion: @escaping (Bool, Error?) -> ()) {
        //completion hander is the return from a server api ,error or success..
        let url = doctorRegisterUrl
        
        // Convert the doctorData to a dictionary to send in the request
        let parameters: [String: Any] = [
            "userName": doctorData.userName,
            "specialization": doctorData.specialization,
            "email": doctorData.email,
            "address": doctorData.address,
            "phone": doctorData.phone,
            "password": doctorData.password,
            "confirmPassword": doctorData.confirmPassword
        ]
        
        
        // Send the request using Alamofire's multipartFormData
        AF.upload(multipartFormData: { multipartFormData in
            // Append image data if available
            if let imageData = imageData {
                multipartFormData.append(imageData, withName: "image", fileName: "profile.jpg", mimeType: "image/jpeg")
            }
            // Append other form parameters
            for (key, value) in parameters {
                if let stringValue = value as? String {
                    multipartFormData.append(stringValue.data(using: .utf8)!, withName: key)
                }
            }
        }, to: url)
        .response { response in
            print("Doctor signup response status code:\(response.response?.statusCode ?? 0)")
            switch response.result {
            case .success:
                completion(true, nil)
            case .failure(let error):
                completion(false, error)
            }
        }
    }
                  
                  
}

struct DoctorLoginDataService {
    
    // Singleton instance for shared login service
    static let sharedDrLogin = DoctorLoginDataService()

    // URL for the login request
    let drLoginUrl = URLS.drLoginUrl // Replace with your actual API URL
    
    // Function to make the API call for login
    func login(doctorLoginData: DoctorLoginData, completion: @escaping (Result<DoctorLoginResponse, Error>) -> Void) {
        // Define headers
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        // Make the POST request using Alamofire
        AF.request(drLoginUrl, method: .post, parameters: doctorLoginData, encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .responseDecodable(of: DoctorLoginResponse.self) { response in
                switch response.result {
                case .success(let loginResponse):
                    // Return the successful response
                    DispatchQueue.main.async {
                        completion(.success(loginResponse))
                    }
                case .failure(let error):
                    // Return the error
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
    }
}
class GetAllDoctorsDataServices {
    
    // Singleton instance
    static let shared = GetAllDoctorsDataServices()
    
    private init() {} // Prevent initialization from other places
    
    // Function to fetch doctors from API
    func fetchDoctors(token: String, completion: @escaping (Result<[Doctors], Error>) -> Void) {
        let url = URLS.getAllDoctorsURL
        
        // Set up headers with the token
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)", // Sending the token in the Authorization header
            "Accept": "application/json"
        ]
        
        // Make the request with headers
        AF.request(url, method: .get, headers: headers)
            .validate()
            .responseDecodable(of: [Doctors].self) { response in
                switch response.result {
                case .success(let doctors):
                    print(response.result)
                    print(doctors)
                    completion(.success(doctors))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    
}
struct GetAllPatientsDataServices
{
    // Singleton instance
        static let shared = GetAllPatientsDataServices()
    private init() {} // Prevent initialization from other places

    func fetchPatientsData(token:String, completion: @escaping (Result<[Patients], Error>)-> Void){
        let patientsURL=URLS.getAllPatientsURL
        // Set up headers with the token
        let headers:HTTPHeaders=[
            "Authorization": "Bearer \(token)", // Sending the token in the Authorization header
            "Accept": "application/json"
        ]
        // Make the request with headers
        
        AF.request(patientsURL,method: .get,headers: headers)
            .validate()
            .responseDecodable(of: [Patients].self){
                response in
                switch response.result {
                case .success(let patients):
                    completion(.success(patients))
                case .failure(let error):
                    completion(.failure(error))
                }}}}
struct GetDoctorDataService {
    static let shared = GetDoctorDataService()
    private init() {}
    let userName = UserDefaults.standard.string(forKey: "DR_Name")
    func fetchDoctorData(token: String, completion: @escaping (Result<DoctorData, Error>) -> Void) {
        // Retrieve userName from UserDefaults
        guard let userName = userName else {
            // Handle the case where userName is not available
            print("No userName found in UserDefaults")
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No userName found"])))
            return
        }
        print("Doctor Name:\(userName)")

        
        // Form the URL
        let urlString = "\(URLS.getDoctorData)\(userName)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Accept": "application/json"
        ]
        
        // Make the network request using Alamofire
        AF.request(url, method: .get, headers: headers)
            .validate()
            .responseDecodable(of: DoctorData.self) { response in
                print("Status code fetchDoctorData:\(response.response?.statusCode ?? 0)")
                switch response.result {
                case .success(let doctorData):
                    completion(.success(doctorData))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    func updateDoctorProfile( token: String, updatedDoctor: UpdateDoctorProfileRequest, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = "http://158.220.90.131:44500/api/Doctors/\(updatedDoctor.userName)"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        AF.upload(multipartFormData: { formData in
            formData.append((updatedDoctor.specialization).data(using: .utf8) ?? Data(), withName: "specialization")
            formData.append((updatedDoctor.userName).data(using: .utf8) ?? Data(), withName: "userName")
            formData.append((updatedDoctor.email).data(using: .utf8) ?? Data(), withName: "email")
            formData.append((updatedDoctor.phone).data(using: .utf8) ?? Data(), withName: "phone")
            formData.append((updatedDoctor.address).data(using: .utf8) ?? Data(), withName: "address")
            formData.append((updatedDoctor.password).data(using: .utf8) ?? Data(), withName: "password")
            formData.append((updatedDoctor.confirmPassword).data(using: .utf8) ?? Data(), withName: "confirmPassword")
            formData.append((updatedDoctor.medicineDescriptions ?? "").data(using: .utf8) ?? Data(), withName: "medicineDescriptions")
            formData.append((updatedDoctor.doctorWorkingTime ?? "").data(using: .utf8) ?? Data(), withName: "doctorWorkingTime")
            formData.append((updatedDoctor.doctorWorkingDaysOfWeek ?? "").data(using: .utf8) ?? Data(), withName: "doctorWorkingDaysOfWeek")
            
            if let imageData = updatedDoctor.image {
                formData.append(imageData, withName: "image", fileName: "profile.jpg", mimeType: "image/jpeg")
            }
        }, to: url, method: .put, headers: headers)
        .validate()
        .response { response in
            switch response.result {
            case .success:
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
struct PostPatientRegisterDataService {
    static let shared = PostPatientRegisterDataService()
    
    func registerPatient(patientData: PostPatientData, imageData: Data?, completion: @escaping (Bool, Error?) -> ()) {
        let url = URLS.patientRegisterUrl
        
        var parameters: [String: Any] = [
            "userName": patientData.userName,
            "nationalID": patientData.nationalID,
            "email": patientData.email,
            "address": patientData.address,
            "phone": patientData.phone,
            "chronicDiseases": patientData.chronicDiseases ?? "",
            "previousOperations": patientData.previousOperations ?? "",
            "allergies": patientData.allergies ?? "",
            "currentMedications": patientData.currentMedications ?? "",
            "comments": patientData.comments ?? "",
            "password": patientData.password,
            "confirmPassword": patientData.confirmPassword
        ]
        
        // Send the request using Alamofire's multipartFormData
        AF.upload(multipartFormData: { multipartFormData in
            // Append image data if available
            if let imageData = imageData {
                multipartFormData.append(imageData, withName: "image", fileName: "profile.jpg", mimeType: "image/jpeg")
            }
            
            // Append other form parameters
            for (key, value) in parameters {
                if let stringValue = value as? String {
                    multipartFormData.append(stringValue.data(using: .utf8)!, withName: key)
                }
            }
        }, to: url)
        .response { response in
            switch response.result {
            case .success:
                completion(true, nil)
            case .failure(let error):
                completion(false, error)
            }
        }
    }

}


struct PatientLoginDataService {
    
    // Singleton instance for shared login service
    static let sharedPatientLogin = PatientLoginDataService()

    // URL for the login request
    let patientLoginUrl = URLS.patientLoginUrl // Replace with your actual API URL
    
    // Function to make the API call for login
    func login(patientLoginData:PatientLoginData, completion: @escaping (Result<PatientLoginResponse, Error>) -> Void) {
        // Define headers
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        // Make the POST request using Alamofire
        AF.request(patientLoginUrl, method: .post, parameters: patientLoginData, encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .responseDecodable(of: PatientLoginResponse.self) { response in
                print("patient login status code:\(response.response?.statusCode ?? 0)")
                switch response.result {
                case .success(let patientResponse):
                    // Return the successful response
                    DispatchQueue.main.async {
                        completion(.success(patientResponse))
                    }
                case .failure(let error):
                    // Return the error
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
    }
}


class PostDrWorkingHoursDataService {

    static let shared = PostDrWorkingHoursDataService() // Singleton instance
    
    // Function to post doctor working times using Alamofire
    func postDoctorWorkingTimes(workingTimes: PostDrWorkingHoursInDays, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URLS.PostDrWorkingHoursInDays
        
        // Convert the model to a dictionary for Alamofire
        let parameters: [String: Any] = [
            "sunDayFrom": workingTimes.sunDayFrom,
            "sunDayTo": workingTimes.sunDayTo,
            "monDayFrom": workingTimes.monDayFrom,
            "monDayTo": workingTimes.monDayTo,
            "tuesDayFrom": workingTimes.tuesDayFrom,
            "tuesDayTo": workingTimes.tuesDayTo,
            "wednesDayFrom": workingTimes.wednesDayFrom,
            "wednesDayTo": workingTimes.wednesDayTo,
            "thursDayFrom": workingTimes.thursDayFrom,
            "thursDayTo": workingTimes.thursDayTo,
            "friDayFrom": workingTimes.friDayFrom,
            "friDayTo": workingTimes.friDayTo,
            "saturDayFrom": workingTimes.saturDayFrom,
            "saturDayTo": workingTimes.saturDayTo,
            "doctorId": workingTimes.doctorId
        ]
        
        // Retrieve token from Keychain
        guard let token = KeychainHelper.shared.getToken(forKey: "DR_Token") else {
            completion(.failure(NSError(domain: "No token found", code: 401, userInfo: nil)))
            return
        }

        // Set headers including the token
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)", // Send the token as a bearer token
            "Content-Type": "application/json"
        ]
        
        // Send POST request using Alamofire
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .response { response in
                switch response.result {
                case .success(let data):
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        completion(.success(responseString))
                        print("post\(response)")
                    } else {
                        completion(.failure(NSError(domain: "Invalid response", code: 500, userInfo: nil)))
                    }
                case .failure(let error):
                    completion(.failure(error))
                    print("error from post\(error)")
                }
            }
    }
    // Fetch working days by Doctor ID
       func fetchDoctorWorkingDays(token: String, doctorId: String, completion: @escaping (Result<[DoctorWorkingDays], Error>) -> Void) {
           let url = "http://158.220.90.131:44500/api/DoctorWorkingDaysOfWeek/GetAllDaysOfTheWeekByDoctorId/\(doctorId)"
           
           let headers: HTTPHeaders = [
               "Authorization": "Bearer \(token)"
           ]
           
           AF.request(url, method: .get, headers: headers)
               .validate()
               .responseDecodable(of: [DoctorWorkingDays].self) { response in
                   switch response.result {
                   case .success(let workingDays):
                       completion(.success(workingDays))
                       print(workingDays)
                   case .failure(let error):
                       completion(.failure(error))
                       print(error)
                   }
               }
       }

    func updateDoctorWorkingDays(_ model: DoctorWorkingDays, token: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = "http://158.220.90.131:44500/api/DoctorWorkingDaysOfWeek"
        
        // Encode model to JSON
        guard let jsonData = try? JSONEncoder().encode(model) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Encoding Failed"])))
            return
        }
        
        var urlRequest = URLRequest(url: URL(string: url)!)
        urlRequest.method = .put
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // ✅ Add Authorization Header
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        urlRequest.httpBody = jsonData

        AF.request(urlRequest)
            .validate(statusCode: 200..<300) // Accept 2xx
            .response { response in
                switch response.result {
                case .success:
                    completion(.success(()))
                    print("✅ Success: \(response)")
                case .failure(let error):
                    completion(.failure(error))
                    print("❌ Error: \(error)")
                }
            }
    }

}

class GetAllStoredWorkingTimesDataService {
    // Singleton instance
    static let shared = GetAllStoredWorkingTimesDataService()
    
    private init() {} // Prevent external instantiation
    
    func fetchDoctorWorkingTimes(doctorId: String, token: String, completion: @escaping (Result<[ResultInterval], Error>) -> Void) {
        let url = "http://158.220.90.131:44500/api/DoctorWorkingTime/\(doctorId)/AllStoredWorkingTimes"
        
        // Set up the headers with the token
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)", // Sending the token in the Authorization header
            "Accept": "application/json"
        ]
        
        AF.request(url, method: .get, headers: headers).responseDecodable(of: SortedTimeInterval.self) { response in
            print(response) // Print the full response to inspect the structure
            switch response.result {
            case .success(let data):
                print("API Response: \(data)") // Print the full JSON response
                completion(.success(data.result))
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}
class DataServices {
    static let shared = DataServices()
    
    private init() {}
    
    // Function to fetch doctor times
    func fetchDoctorTimes(token: String, doctorId: String, completion: @escaping ([ResultInterval]?, Error?) -> Void) {
        // Set up the headers with the token
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)", // Sending the token in the Authorization header
            "Accept": "application/json"
        ]
        
        
        let url = "http://158.220.90.131:44500/api/DoctorWorkingTime/\(doctorId)/AllStoredWorkingTimes"
        
        AF.request(url, headers: headers).responseDecodable(of: SortedTimeInterval.self) { response in
            if let data = response.data, let jsonString = String(data: data, encoding: .utf8) {
                print("Raw response data: \(jsonString)")
            }
            
            switch response.result {
            case .success(let sortedTimeInterval):
                completion(sortedTimeInterval.result, nil)  // Now accessing the array inside `result`
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    // Function to book an appointment
    func bookAppointment(token: String, bookDate: BookDate, completion: @escaping (Bool, Error?) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json",    // make sure to set JSON content type
            "Accept": "application/json"
        ]

        let url = "http://158.220.90.131:44500/api/PatientBooking"

        AF.request(
            url,
            method: .post,
            parameters: bookDate,
            encoder: JSONParameterEncoder.default,   // ← use the Codable struct directly
            headers: headers
        )
        .validate()
        .response { response in
            // log raw response
            if let data = response.data, let body = String(data: data, encoding: .utf8) {
                print("⚙️ response body: \(body)")
            }
            completion(response.error == nil, response.error)
        }
    }

    
    func getPatientProfile(id: String, token: String, completion: @escaping (Result<GetPatientProfileData, Error>) -> Void) {
        let url = "http://158.220.90.131:44500/api/Patients/\(id)"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        AF.request(url, method: .get, headers: headers)
            .validate()
            .responseDecodable(of: GetPatientProfileData.self) { response in
                let statusCode=response.response?.statusCode ?? 0
                print("status\(statusCode)")
                switch response.result {
                case .success(let profile):
                    completion(.success(profile))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func updatePatientProfileWithImage(_ profile: UpdatePatientProfileRequest, token: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = "http://158.220.90.131:44500/api/Patients/\(profile.id)"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        AF.upload(multipartFormData: { formData in
            formData.append((profile.nationalID).data(using: .utf8) ?? Data(), withName: "nationalID")
            formData.append(String(profile.patientCode).data(using: .utf8) ?? Data(), withName: "patientCode")
            formData.append((profile.userName).data(using: .utf8) ?? Data(), withName: "userName")
            formData.append((profile.email).data(using: .utf8) ?? Data(), withName: "email")
            formData.append((profile.phone).data(using: .utf8) ?? Data(), withName: "phone")
            formData.append((profile.address).data(using: .utf8) ?? Data(), withName: "address")
            formData.append((profile.chronicDiseases ?? "").data(using: .utf8) ?? Data(), withName: "chronicDiseases")
            formData.append((profile.previousOperations ?? "").data(using: .utf8) ?? Data(), withName: "previousOperations")
            formData.append((profile.allergies ?? "").data(using: .utf8) ?? Data(), withName: "allergies")
            formData.append((profile.currentMedications ?? "").data(using: .utf8) ?? Data(), withName: "currentMedications")
            formData.append((profile.comments ?? "").data(using: .utf8) ?? Data(), withName: "comments")
            formData.append((profile.password).data(using: .utf8) ?? Data(), withName: "password")
            formData.append((profile.ConfirmPassword).data(using: .utf8) ?? Data(), withName: "ConfirmPassword")
            
            
            if let imageData = profile.image {
                formData.append(imageData, withName: "image", fileName: "profile.jpg", mimeType: "image/jpeg")
            }

        }, to: url, method: .put, headers: headers)
        .validate()
        .response { response in
            switch response.result {
            case .success:
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    func fetchPatient(byCode code: Int, token: String, completion: @escaping (Result<GetPatientByCode, Error>) -> Void) {
        let url = "http://158.220.90.131:44500/api/Patients/GePatientByCode/\(code)"
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        AF.request(url, method: .get, headers: headers)
            .validate()
            .responseDecodable(of: GetPatientByCode.self) { response in
                // Capture the status code from the response
                let statusCode = response.response?.statusCode
                print("Status Code: \(statusCode ?? 0)")  // Prints the status code, defaulting to 0 if nil
                
                switch response.result {
                case .success(let patient):
                    completion(.success(patient))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
class RoshetaService {
    static let shared = RoshetaService()

    func postRosheta(_ request: RoshetaRequest, token: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = "http://158.220.90.131:44500/api/MedicineDescription"

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]

        AF.request(url, method: .post, parameters: request, encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .response { response in
                switch response.result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}

class PrescriptionService {
    static let shared = PrescriptionService()
    
    static func fetchPrescriptionsByDoctorId(
        doctorId: String,
        token: String,
        completion: @escaping (Result<[RoshetaHistoryModel], Error>) -> Void // ✅ expects array now
    ) {
        let url = "http://158.220.90.131:44500/api/MedicineDescription/GetAllMedicineDescriptionByDoctorId/\(doctorId)"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        
        AF.request(url, method: .get, headers: headers)
            .validate()
            .responseDecodable(of: [RoshetaHistoryModel].self) { response in
                switch response.result {
                case .success(let prescriptions):
                    completion(.success(prescriptions)) // ✅ return the decoded array
                case .failure(let error):
                    print("Failed to decode:", error)
                    debugPrint(response)
                    completion(.failure(error))
                }
            }
    }
}


class PatientBookingService {
    static let shared = PatientBookingService()
    
    private init() {}
    
    func getAllPatientsBooking(doctorId: String, completion: @escaping (Result<[PatientBooking], Error>) -> Void) {
        // Get the token from UserDefaults
        guard let token = KeychainHelper.shared.getToken(forKey: "DR_Token") else {
            completion(.failure(NSError(domain: "No Token Found", code: 401)))
            return
        }
        
        
        // URL setup
        let urlString = "http://158.220.90.131:44500/api/PatientBooking/GetAllPatientsBookingToDoctorByDoctorId/\(doctorId)"
        print("Request URL: \(urlString)")
        print("Token: \(token)")
        
        // Headers setup
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Accept": "application/json"
        ]
        // API Request
        AF.request(urlString, method: .get, headers: headers)
            .validate()
            .responseDecodable(of: [PatientBooking].self) { response in
                if let statusCode = response.response?.statusCode {
                    print("📡 Status code:", statusCode)
                }
                
                switch response.result {
                case .success(let bookings):
                    print("📦 Response data: \(bookings)")
                    completion(.success(bookings))
                case .failure(let error):
                    print("🛑 Network error: \(error)")
                    if let data = response.data,
                       let responseBody = String(data: data, encoding: .utf8) {
                        print("🔍 Server response body: \(responseBody)")
                    }
                    completion(.failure(error))
                }
            }}}
