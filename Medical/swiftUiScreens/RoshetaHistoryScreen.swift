import SwiftUI

struct RoshetaHistoryScreen: View {
    @StateObject private var viewModel = PrescriptionViewModel()
    @State private var doctorId = UserDefaults.standard.string(forKey: "DR_ID") ?? ""
    @State private var expandedItems: Set<String> = [] // Using String since id is a String

    let darkRed = Color(red: 139/255, green: 0, blue: 0)

    var body: some View {
        NavigationStack {
            VStack {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }

                List(viewModel.prescriptions) { prescription in
                    let isExpanded = expandedItems.contains(prescription.id)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Patient: \(prescription.patient ?? "-")")
                            .font(.headline)
                        Text("Date: \(formattedDate(prescription.createdOn))")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))

                        if isExpanded {
                            Divider()
                            Text("Patient Code: \(prescription.patientCode)")
                            Text("Doctor: \(prescription.doctor ?? "-")")
                            Text("Patient ID: \(prescription.patientId)")
                            Text("Diagnosis: \(prescription.diagnosis ?? "-")")
                            Text("Medicine: \(prescription.medicine ?? "-")")
                            Text("Analysis: \(prescription.analysis ?? "-")")
                            Text("X-Rays: \(prescription.xRays ?? "-")")
                            Text("Notes: \(prescription.additionalNotes ?? "-")")
                        }
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(darkRed)
                    .cornerRadius(12)
                    .onTapGesture {
                        withAnimation {
                            toggleExpansion(for: prescription)
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
            }
            .onAppear {
                viewModel.loadPrescriptions()
            }
        }
        .navigationTitle("Rosheta History")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton()
            }
        }
    }

    private func toggleExpansion(for prescription: RoshetaHistoryModel) {
        if expandedItems.contains(prescription.id) {
            expandedItems.remove(prescription.id)
        } else {
            expandedItems.insert(prescription.id)
        }
    }

    private func formattedDate(_ dateString: String?) -> String {
        guard let dateString = dateString else { return "-" }

        let inputFormatter = ISO8601DateFormatter()
        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateStyle = .medium
            outputFormatter.timeStyle = .short
            return outputFormatter.string(from: date)
        }

        return dateString // fallback if parsing fails
    }
}

struct RoshetaHistoryScreen_Previews: PreviewProvider {
    static var previews: some View {
        RoshetaHistoryScreen()
    }
}
