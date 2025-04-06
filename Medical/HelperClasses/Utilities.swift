
import Foundation
struct URLS{
    
    
   static let main="http://158.220.90.131:44500/api/"
    
    ///post {doctor:PostDoctorData}
    static let doctorRegisterUrl = main+"Doctors"
    
    ///post{doctorLoginData:DoctorLoginData}
    static let drLoginUrl=main+"Login/DoctorLogin"
    
    //GetAllDoctors{Return List<Doctors>}
    static let getAllDoctorsURL=main+"Doctors"
    
    //GetAllPatients{Return List<Patients>}
    static let getAllPatientsURL=main+"Patients"
    
    //GetDoctorData{Return DoctorDara}
    static let getDoctorData=main+"Doctors/"
    
    ///post {patient:PostPatientData}
    static let patientRegisterUrl = main+"Patients"
    
    ///post{patientLoginData:PatientLoginData}
    static let patientLoginUrl=main+"Login/PatientLogin"

    //post dr woking hour in each day of week
    static let PostDrWorkingHoursInDays=main+"DoctorWorkingDaysOfWeek"
    ///all sorted working times
    static let  sortedWorkingTimesUrl = main+"DoctorWorkingTime/"

}
