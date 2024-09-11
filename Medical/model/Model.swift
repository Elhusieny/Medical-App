
import Foundation

// Define a struct that matches the JSON structure
//This model represents the doctor data that you want to register.
//Features: Conforms to Codable for easy encoding and decoding.
struct  PostDoctorData: Codable {
    var userName: String
    var specialization: String
    var email: String
    var address: String
    var phone: String
    var password: String
    var confirmPassword: String
}

