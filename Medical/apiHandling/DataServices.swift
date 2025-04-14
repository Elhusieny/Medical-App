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
    func registerDoctor(doctorData: PostDoctorData, completion: @escaping (Bool, Error?) -> ()) {
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
        
        // Send the request using AF.request
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    // Try to parse the response data into a JSON object
                    if try JSONSerialization.jsonObject(with: data, options: []) is [String: Any] {
                        if response.response?.statusCode == 200 {
                            completion(true, nil)
                        } else {
                            let errorMessage = "Server returned status code: \(response.response?.statusCode ?? 0)"
                            let customError = NSError(domain: "", code: response.response?.statusCode ?? 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                            completion(false, customError)
                        }

                    } else {
                        // Invalid response format
                        completion(false, nil)
                    }
                } catch let jsonError {
                    // Error parsing JSON
                    completion(false, jsonError)
                }
            case .failure(let error):
                // Network or server error
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
    
    func fetchDoctorData(token: String, completion: @escaping (Result<DoctorData, Error>) -> Void) {
        // Retrieve userName from UserDefaults
        let userName = UserDefaults.standard.string(forKey: "DR_Name")
        guard let userName = userName else {
            // Handle the case where userName is not available
            print("No userName found in UserDefaults")
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No userName found"])))
            return
        }
        
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
                switch response.result {
                case .success(let doctorData):
                    completion(.success(doctorData))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    func updateDoctorProfile(token: String, updatedDoctor: UpdateDoctorProfileRequest, completion: @escaping (String?) -> Void) {
        let url = "http://158.220.90.131:44500/api/Doctors/ramy"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        
        AF.request(url, method: .put, parameters: updatedDoctor, encoder: JSONParameterEncoder.default, headers: headers).response { response in
            switch response.result {
            case .success:
                completion(nil)
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
}
struct PostPatientRegisterDataService {
    // MARK: - Singleton
    static let shared = PostPatientRegisterDataService()

    // MARK: - Register Patient
    func registerPatient(patientData: PostPatientData, completion: @escaping (Bool, Error?) -> ()) {
        // Define the URL for patient registration
        let url = URLS.patientRegisterUrl
        
        // Convert the patientData to a dictionary to send in the request
        let parameters: [String: Any] = [
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
        
        // Send the request using AF.request
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    // Try to parse the response data into a JSON object
                    if try JSONSerialization.jsonObject(with: data, options: []) is [String: Any] {
                        if response.response?.statusCode == 200 {
                            // Successfully registered patient
                            completion(true, nil)
                        } else {
                            // Server error occurred, but response was received
                            completion(false, nil)
                        }
                    } else {
                        // Invalid response format
                        completion(false, nil)
                    }
                } catch let jsonError {
                    // Error parsing JSON
                    completion(false, jsonError)
                }
            case .failure(let error):
                // Network or server error
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
                    } else {
                        completion(.failure(NSError(domain: "Invalid response", code: 500, userInfo: nil)))
                    }
                case .failure(let error):
                    completion(.failure(error))
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
        // Set up the headers with the token
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)", // Sending the token in the Authorization header
            "Accept": "application/json"
        ]
        
        
        let url = "http://158.220.90.131:44500/api/PatientBooking"
        let parameters: [String: Any] = [
            "patientId": bookDate.patientId,
            "doctorTimeIntervalId": bookDate.doctorTimeIntervalId
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { response in
            switch response.result {
            case .success:
                completion(true, nil)
            case .failure(let error):
                completion(false, error)
            }
        }
    }
    
    func getPatientProfile(id: String, token: String, completion: @escaping (Result<PatientProfile, Error>) -> Void) {
        let url = "http://158.220.90.131:44500/api/Patients/\(id)"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        AF.request(url, method: .get, headers: headers)
            .validate()
            .responseDecodable(of: PatientProfile.self) { response in
                switch response.result {
                case .success(let profile):
                    completion(.success(profile))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    func updatePatientProfile(id: String, updatedProfile: UpdatePatientProfileRequest, token: String, completion: @escaping (Result<Bool, Error>) -> Void) {
            let url = "http://158.220.90.131:44500/api/Patients/\(id)"
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json"
            ]
            
            AF.request(url, method: .put, parameters: updatedProfile, encoder: JSONParameterEncoder.default, headers: headers)
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
