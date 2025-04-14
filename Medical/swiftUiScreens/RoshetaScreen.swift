import SwiftUI

struct RoshetaScreen: View {
    @State private var diagnosisList: [String] = [""]
    @State private var medicineList: [String] = [""]
    @State private var analysisList: [String] = [""]
    @State private var xRaysList: [String] = [""]
    @State private var additionalNotes: String = ""
    @StateObject private var viewModel = PatientViewModel()
    @State private var patientCodeText: String = ""
    @StateObject private var roshetaViewModel = RoshetaViewModel()
    @State private var showAlert = false
    @State private var alertMessage = ""

    let darkRed = Color(red: 139/255, green: 0, blue: 0)

    var body: some View {
        NavigationStack{
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // MARK: - Patient Code Section Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Patient Lookup")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextField("Enter Patient Code", text: $patientCodeText)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                                .foregroundColor(darkRed)
                            HStack {
                                Spacer()
                                Button(action: {
                                    guard let code = Int(patientCodeText),
                                          let token = KeychainHelper.shared.getToken(forKey: "DR_Token") else {
                                        viewModel.errorMessage = "Invalid input or token"
                                        return
                                    }
                                    viewModel.getPatient(byCode: code, token: token)
                                }) {
                                    Text("Fetch Patient")
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 10)
                                        .background(Color.white.opacity(0.3))
                                        .cornerRadius(10)
                                }
                                Spacer()
                            }
                            .frame(maxWidth: .infinity) // 👈 This line ensures horizontal stretching
                            if let patient = viewModel.patient {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Name: \(patient.userName)")
                                    Text("Email: \(patient.email)")
                                }
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                            }
                            
                            
                            if let error = viewModel.errorMessage {
                                Text("Error: \(error)")
                                    .foregroundColor(.white)
                                    .padding(6)
                                    .background(Color.red.opacity(0.8))
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(darkRed)
                        .cornerRadius(12)
                        .shadow(color: darkRed.opacity(0.2), radius: 5, x: 0, y: 2)
                        
                        // MARK: - Medical Sections
                        sectionCard(title: "Diagnosis", list: $diagnosisList)
                        sectionCard(title: "Medicine", list: $medicineList)
                        sectionCard(title: "Analysis", list: $analysisList)
                        sectionCard(title: "X-Rays", list: $xRaysList)
                        
                        // MARK: - Notes Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Additional Notes")
                                .font(.headline)
                                .foregroundColor(.white)
                            TextEditor(text: $additionalNotes)
                                .frame(height: 100)
                                .padding(8)
                                .background(darkRed.opacity(0.7)) // increased opacity
                                .cornerRadius(10)
                                .foregroundColor(.black)
                            
                        }
                        .padding()
                        .background(darkRed)
                        .cornerRadius(12)
                        .shadow(color: darkRed.opacity(0.2), radius: 5, x: 0, y: 2)
                        
                        // MARK: - Submit Button
                        Button(action: {
                            postPrescription()
                        }) {
                            Text("Submit Prescription")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(darkRed)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .font(.headline)
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                }
                .padding(.top, 10) // To make sure it doesn't hide under the navigation bar
               
                .background(Color.white)
                .onReceive(roshetaViewModel.$successMessage.compactMap { $0 }) { message in
                    alertMessage = message
                    showAlert = true
                }
                .onReceive(roshetaViewModel.$errorMessage.compactMap { $0 }) { error in
                    alertMessage = error
                    showAlert = true
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Rosheta Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
        }
        .navigationTitle("Prescription")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton()
            }
        }
    }

    // MARK: - Reusable Card Section
    func sectionCard(title: String, list: Binding<[String]>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)

            ForEach(0..<list.wrappedValue.count, id: \.self) { index in
                TextField("Enter \(title.lowercased())", text: list[index])
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(8)
                    .foregroundColor(darkRed)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(darkRed, lineWidth: 1)
                    )
            }

            Button(action: {
                list.wrappedValue.append("")
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add \(title)")
                }
                .foregroundColor(.white)
                .font(.subheadline)
            }
        }
        .padding()
        .background(darkRed)
        .cornerRadius(12)
        .shadow(color: darkRed.opacity(0.2), radius: 5, x: 0, y: 2)
    }

    // MARK: - API POST
    func postPrescription() {
        guard !patientCodeText.trimmingCharacters(in: .whitespaces).isEmpty else {
              alertMessage = "Please enter the patient code before submitting the prescription."
              showAlert = true
              return
          }

        let diagnosis = diagnosisList.filter { !$0.isEmpty }.joined(separator: ", ")
        let medicine = medicineList.filter { !$0.isEmpty }.joined(separator: ", ")
        let analysis = analysisList.filter { !$0.isEmpty }.joined(separator: ", ")
        let xRays = xRaysList.filter { !$0.isEmpty }.joined(separator: ", ")
//        let patientId = UserDefaults.standard.string(forKey: "PATIENT_ID") ?? ""
//        let doctorId = UserDefaults.standard.string(forKey: "DR_ID") ?? ""
        roshetaViewModel.submitRosheta(
            diagnosis: diagnosis,
            medicine: medicine,
            analysis: analysis,
            xRays: xRays,
            notes: additionalNotes
        )

    }
}


struct RoshetaScreen_Previews: PreviewProvider {
    static var previews: some View {
        RoshetaScreen()
    }
}
