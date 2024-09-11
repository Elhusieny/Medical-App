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
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if response.response?.statusCode == 200 {
                            // Successfully registered doctor
                            completion(true, nil)
                        } else {
                            // Some server error occurred, but response was received
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

