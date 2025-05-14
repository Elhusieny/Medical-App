import SwiftUI

struct GetDoctorReservations: View {
    @StateObject private var viewModel = PatientBookingViewModel()

    var doctorId: String  // Passed from outside
    let darkRed = Color(red: 139/255, green: 0, blue: 0) // Same dark red color

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.patientBookings.isEmpty && viewModel.errorMessage == nil {
                    Text("No reservations found.")
                        .foregroundColor(.gray)
                        .padding()
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                List(viewModel.patientBookings) { booking in
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Booking ID: \(booking.id)")
                            .font(.headline)
                        Text("Interval Start: \(booking.intervalStart)")
                            .font(.subheadline)
                        Text("Bookings Count: \(viewModel.patientBookings.count)")
                            .foregroundColor(.gray)
                    }
                    .foregroundColor(.white)
                    .padding(10)                          // uniform 10pt padding
                    .frame(maxWidth: .infinity, alignment: .leading) // stretch full width
                    .background(darkRed)
                    .cornerRadius(12)
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
            }
            .onAppear {
                viewModel.fetchPatientBookings(for: doctorId)
            }
        }
        .navigationTitle("Doctor Reservations")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton()
            }
        }
    }
}

struct GetDoctorReservations_Previews: PreviewProvider {
    static var previews: some View {
        GetDoctorReservations(doctorId: UserDefaults.standard.string(forKey: "DR_ID") ?? "")
    }
}
    
