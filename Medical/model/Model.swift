
import Foundation
import UIKit

// Define a struct that matches the JSON structure
//This model represents the doctor data that you want to register.
//Features: Conforms to Codable for easy encoding and decoding.
struct  PostDoctorData {
    var userName: String
    var specialization: String
    var email: String
    var address: String
    var phone: String
    var password: String
    var confirmPassword: String
    var image:UIImage?
}
// get Doctor Data
struct DoctorData: Codable {
    let id, userName, specialization, email: String
    let phoneNumber, address, password: String
    let medicineDescriptions, doctorWorkingTime, doctorWorkingDaysOfWeek: String?
    var imagePath: String?  // ✅ Use this to store image URL or filename from backend

    
}

struct DoctorLoginData:Codable
{
    let phoneNumber,password: String
    let rememberMe: Bool
}
struct DoctorLoginResponse: Codable {
    let token: String
    let expiration: String
    let phoneNumber: String
    let id: String
    let userName:String
}

struct UpdateDoctorProfileRequest {
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
    var image:Data?
}


//get all doctors
struct Doctors: Identifiable, Decodable
{
        let id, userName, specialization, email: String?
        let phoneNumber, address, password: String?
        let imagePath: String? // ✅ Use this to store Doctors images URL
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
       var image: UIImage? // 👈 Change this from URL? to UIImage?

}
//Patient Login
struct PatientLoginData: Codable {
    let phone, password: String
    let rememberMe: Bool
}
struct PatientLoginResponse: Codable {
    let token: String
    let expiration: String
    let phone:String
    let userName: String
    let id: String
}
struct PostDrWorkingHoursInDays: Codable {
       var id: Int?=1
       var sunDayFrom: String?
       var sunDayTo: String?
       var monDayFrom: String?
       var monDayTo: String?
       var tuesDayFrom: String?
       var tuesDayTo: String?
       var wednesDayFrom: String?
       var wednesDayTo: String?
       var thursDayFrom: String?
       var thursDayTo: String?
       var friDayFrom: String?
       var friDayTo: String?
       var saturDayFrom: String?
       var saturDayTo: String?
       var doctorId: String
}
struct DoctorWorkingDays: Codable {
    var id: Int?
    var sunDayFrom: String?
    var sunDayTo: String?
    var monDayFrom: String?
    var monDayTo: String?
    var tuesDayFrom: String?
    var tuesDayTo: String?
    var wednesDayFrom: String?
    var wednesDayTo: String?
    var thursDayFrom: String?
    var thursDayTo: String?
    var friDayFrom: String?
    var friDayTo: String?
    var saturDayFrom: String?
    var saturDayTo: String?
    var doctorId: String
}



struct DoctorWorkingTimes: Codable {
    var id: Int?=1 // Optional for update purposes
    var doctorId: String
    var sunDayFrom: String?
    var sunDayTo: String?
    var monDayFrom: String?
    var monDayTo: String?
    var tuesDayFrom: String?
    var tuesDayTo: String?
    var wednesDayFrom: String?
    var wednesDayTo: String?
    var thursDayFrom: String?
    var thursDayTo: String?
    var friDayFrom: String?
    var friDayTo: String?
    var saturDayFrom: String?
    var saturDayTo: String?
}


struct DoctorWorkingTime: Codable {
    let day: String
    let startTime: String
    let endTime: String
}

struct DoctorWorkingScheduleRequest: Codable {
    let doctorId: String
    let scheduleId: Int? // nil for POST, set for PUT
    let workingTimes: [DoctorWorkingTime]
}

struct DoctorWorkingScheduleResponse: Codable {
    let message: String
    let scheduleId: Int? // optional, may be returned on POST
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
    let doctorId: String
    let doctorTimeIntervalId: Int
    let intervalStart: String
    let patientId: String
}

struct GetPatientProfileData: Codable {
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
    var imagePath: String?  // ✅ Use this to store image URL or filename from backend
}

struct UpdatePatientProfileRequest {
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

    var image: Data? // Store image data directly here
}

//-Mark: get patient data by patient code
struct GetPatientByCode: Codable {
    let id: String
    let nationalID: String
    let patientCode: Int
    let userName: String
    let email: String
    let phone: String
    let address: String?
    let chronicDiseases: String?
    let previousOperations: String?
    let allergies: String?
    let currentMedications: String?
    let comments: String?
    let imagePath: String
    let medicineDescriptions: String?
    let patientBooking: String?
    let patientsInfoForm: String?
    let children: String?
}


//-mark: doctor post rosheta to patient
struct RoshetaRequest: Codable {
    let diagnosis: String
    let medicine: String
    let analysis: String
    let x_Rays: String
    let additionalNotes: String
    let doctorId: String
    let patientId: String
}


//-mark: get all rosheta doctor entered to patient
    struct RoshetaHistoryModel:Identifiable, Decodable {
        let id: String
        let diagnosis: String?
        let medicine: String?
        let analysis: String?
        let xRays: String?
        let additionalNotes: String?
        let patientCode: Int
        let doctorId: String
        let patientId: String
        let doctor: String?
        let patient: String?
        let createdOn: String?
        let createdBy: String
        let updatedOn: String
        let updatedBy: String

        enum CodingKeys: String, CodingKey {
            case id, diagnosis, medicine, analysis
            case xRays = "x_Rays" // this fixes the mismatch
            case additionalNotes, patientCode, doctorId, patientId, doctor, patient, createdOn, createdBy, updatedOn, updatedBy
        }
    }


struct PatientBooking: Identifiable, Codable {
    var id: String
    var patientId: String
    var doctorId: String
    var doctorTimeIntervalId: Int
    var intervalStart: String
    var isDelete: Int
    var patient: String?   // It's null in response, so optional
    var createdOn: String
    var createdBy: String
    var updatedOn: String
    var updatedBy: String
}
