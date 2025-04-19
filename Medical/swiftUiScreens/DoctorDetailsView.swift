import SwiftUI

struct DoctorDetailsView: View {
    let doctorName: String
    let specialization: String
    let doctorId: String
    let doctorImage: String  // Add an image URL or name of the image resource

    @StateObject private var viewModel = BookingViewModel()
    @State private var showBookingAlert = false
    @State private var bookingSuccess = false

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Doctor info section with image card and corner radius
                Spacer()
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(doctorImage) // Assuming doctor image is added to assets or comes from URL
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(radius: 4)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(doctorName)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text(specialization)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading) // Makes content stretch full width
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(red: 139/255, green: 0, blue: 0))
                            .shadow(radius: 4)
                    )
                }
                .padding()
                Spacer()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select a Date")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 12)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.availableDates, id: \.self) { date in
                                DateCell(
                                    dateString: date,
                                    isSelected: date == viewModel.selectedDate,
                                    action: { viewModel.selectedDate = date }
                                )
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
                )
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Select a Time")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 12)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(
                            rows: Array(repeating: GridItem(.fixed(50), spacing: 8), count: 4), // Use .fixed to enforce row height
                            spacing: 12
                        ) {
                            ForEach(viewModel.filteredSlots, id: \.id) { slot in
                                TimeCell(
                                    slot: slot,
                                    isSelected: slot.id == viewModel.selectedTime?.id,
                                    action: { viewModel.selectedTime = slot }
                                )
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(height: (50 * 4) + (8 * 3)) // 4 rows, 3 gaps of 8pt
                        
                    }
                    
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
                )
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    guard let token = KeychainHelper.shared.getToken(forKey: "PT_Token"),
                          let patientId = UserDefaults.standard.string(forKey: "PT_ID") else {
                        print("Token or patient ID missing")
                        return
                    }
                    
                    viewModel.bookAppointment(token: token, patientId: patientId) { success in
                        bookingSuccess = success
                        showBookingAlert = true
                    }
                }) {
                    HStack {
                        Text("Book Appointment")
                            .fontWeight(.semibold)
                            .font(.headline)
                            .padding(.trailing,10)
                        
                        
                        Image(systemName: "calendar.badge.plus") // This adds the system image
                            .font(.headline)
                            .padding(.leading, 8) // Optional padding to adjust the space between text and image
                    }
                    .padding()
                    .background(viewModel.selectedTime != nil ? Color(red: 139/255, green: 0, blue: 0) : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                }
                .disabled(viewModel.selectedTime == nil)
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            
            .onAppear {
                if let token = KeychainHelper.shared.getToken(forKey: "DR_Token") {
                    viewModel.fetchDoctorTimes(token: token, doctorId: doctorId) {
                        print("Fetched Times: \(viewModel.availableTimes.map(\.intervalStart))")
                        print("Available Dates: \(viewModel.availableDates)")
                    }
                }
            }

            .alert(isPresented: $showBookingAlert) {
                Alert(
                    title: Text(bookingSuccess ? "Success" : "Error"),
                    message: Text(bookingSuccess ? "Appointment booked successfully!" : "Failed to book appointment."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .navigationTitle("Doctor Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton()
            }
        }
        
    }
}

// MARK: - DateCell

struct DateCell: View {
    let dateString: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Text(dateString)
            .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: isSelected
                                ? [Color(red: 139/255, green: 0, blue: 0), Color.red]
                                : [Color(.systemGray5), Color(.systemGray4)]
                            ),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: isSelected ? Color.black.opacity(0.2) : Color.clear, radius: 3, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.white.opacity(0.7) : Color.clear, lineWidth: 1)
            )
            .onTapGesture(perform: action)
    }
}


// MARK: - TimeCell

struct TimeCell: View {
    let slot: ResultInterval
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Text(slot.formattedTimeRange)
            .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .frame(minHeight: 40) // ✅ Enforce minimum height so rows have space
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: isSelected
                                ? [Color(red: 139/255, green: 0, blue: 0), Color.red]
                                : [Color(.systemGray5), Color(.systemGray4)]
                            ),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: isSelected ? Color.black.opacity(0.15) : Color.clear, radius: 3, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.white.opacity(0.8) : Color.clear, lineWidth: 1)
            )
            .onTapGesture(perform: action)
    }
}


// MARK: - ResultInterval Time Formatting Extension

extension ResultInterval {
    var formattedTimeRange: String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSSS"

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "h:mm a"

        guard let start = inputFormatter.date(from: intervalStart),
              let end = inputFormatter.date(from: intervalEnd) else {
            return ""
        }

        return "\(outputFormatter.string(from: start)) - \(outputFormatter.string(from: end))"
    }
}


// MARK: - Preview

struct DoctorDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        DoctorDetailsView(
            doctorName: "Dr. Jane Smith",
            specialization: "Dermatology",
            doctorId: "123",
            doctorImage: "doc2" // Replace with an actual image name or URL
        )
        .preferredColorScheme(.dark)
    }
}
