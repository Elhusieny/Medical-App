
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
// get Doctor Data
struct DoctorData: Codable {
    let id, userName, specialization, email: String
    let phoneNumber, address, password: String
    let medicineDescriptions, doctorWorkingTime, doctorWorkingDaysOfWeek: String?
}

struct DoctorLoginData:Codable
{
    let email,password: String
    let rememberMe: Bool
}
struct DoctorLoginResponse: Codable {
    let token: String
    let expiration: String
    let email: String
    let id: String
    let userName:String
}

struct UpdateDoctorProfileRequest: Codable {
    var id: String
    var userName: String
    var specialization: String
    var email: String
    var phone: String
    var address: String
    var password: String
    var confirmPassword: String
    var medicineDescriptions: String?  // Optional
    var doctorWorkingTime: String?     // Optional
    var doctorWorkingDaysOfWeek: String?  // Optional
}


//get all doctors
struct Doctors:Codable
{
        let id, userName, specialization, email: String
        let phoneNumber, address, password: String
        let medicineDescriptions, doctorWorkingTime, doctorWorkingDaysOfWeek: String?

}
// Get All Patients
struct Patients: Codable {
    let id, nationalID: String
    let patientCode: Int
    let userName, email, phone, address: String
    let chronicDiseases, previousOperations, allergies, currentMedications: String?
    let comments: String?
    let password: String
    let medicineDescriptions, patientBooking: String?
}
//Patient signup
struct PostPatientData{
        let userName, nationalID, email, address,phone: String
        let  chronicDiseases, previousOperations, allergies: String?
        let currentMedications, comments:String?
        let password, confirmPassword: String
}
//Patient Login
struct PatientLoginData: Codable {
    let email, password: String
    let rememberMe: Bool
}
struct PatientLoginResponse: Codable {
    let token: String
    let expiration: String
    let email:String
    let userName: String
    let id: String
}
struct PostDrWorkingHoursInDays: Codable {
    let sunDayFrom, sunDayTo, monDayFrom, monDayTo: String
    let tuesDayFrom, tuesDayTo, wednesDayFrom, wednesDayTo: String
    let thursDayFrom, thursDayTo, friDayFrom, friDayTo: String
    let saturDayFrom, saturDayTo, doctorId: String
}

struct SortedTimeInterval: Codable {
    let result: [ResultInterval]
    let id: Int
    let exception: String?
    let status: Int
    let isCanceled: Bool
    let isCompleted: Bool
    let isCompletedSuccessfully: Bool
    let creationOptions: Int
    let asyncState: String?
    let isFaulted: Bool
}

struct ResultInterval: Codable {
    let id: Int
    let doctorId: String
    let intervalStart: String
    let intervalEnd: String
}
struct BookDate: Codable {
    let patientId: String
    let doctorTimeIntervalId: Int
}


struct PatientProfile: Codable {
    var id: String
    var nationalID: String
    var patientCode: Int
    var userName: String
    var email: String
    var phone: String
    var address: String
    var chronicDiseases: String?
    var previousOperations: String?
    var allergies: String?
    var currentMedications: String?
    var comments: String?
    var password: String?  // Add password as an optional field
}

struct UpdatePatientProfileRequest: Codable {
    var id: String
    var nationalID: String
    var patientCode: Int
    var userName: String
    var email: String
    var phone: String
    var address: String
    var chronicDiseases: String?
    var previousOperations: String?
    var allergies: String?
    var currentMedications: String?
    var comments: String?
    var password: String
    var ConfirmPassword: String
}

