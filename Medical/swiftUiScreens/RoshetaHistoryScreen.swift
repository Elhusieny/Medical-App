import SwiftUI

struct RoshetaHistoryScreen: View {
    @StateObject private var viewModel = PrescriptionViewModel()
    @State private var doctorId = UserDefaults.standard.string(forKey: "DR_ID") ?? ""
    let darkRed = Color(red: 139/255, green: 0, blue: 0)

    var body: some View {
        NavigationStack {
            VStack {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                List(viewModel.prescriptions) { prescription in
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Patient Code: \(prescription.patientCode)")
                        Text("Doctor: \(prescription.doctor ?? "-")")
                        Text("Patient Name: \(prescription.patient ?? "-")")
                        Text("Patient ID: \(prescription.patientId)")
                        Text("Diagnosis: \(prescription.diagnosis ?? "-")")
                        Text("Medicine: \(prescription.medicine ?? "-")")
                        Text("Analysis: \(prescription.analysis ?? "-")")
                        Text("X-Rays: \(prescription.xRays ?? "-")")
                        Text("Notes: \(prescription.additionalNotes ?? "-")")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(darkRed)
                    .cornerRadius(12)
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
            }
            .onAppear {
                viewModel.loadPrescriptions()
            }
        }.navigationTitle("Rosheta History")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    BackButton()
                }
        }
    }
}

struct RoshetaHistoryScreen_Previews: PreviewProvider {
    static var previews: some View {
        RoshetaHistoryScreen()
    }
}
