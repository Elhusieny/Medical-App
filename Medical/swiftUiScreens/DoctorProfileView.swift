import SwiftUI

struct DoctorProfileView: View {
    @StateObject var viewModel = DoctorProfileViewModel()
    
    @State private var showImagePicker = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @State private var name = ""
    @State private var specialization = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var address = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                profileImageView
                
                VStack(spacing: 16) {
                    IconTextField(icon: "person", placeholder: "Full Name", text: $name)
                    IconTextField(icon: "cross.case", placeholder: "Specialization", text: $specialization)
                    IconTextField(icon: "envelope", placeholder: "Email", text: $email)
                    IconTextField(icon: "phone", placeholder: "Phone Number", text: $phone)
                    IconTextField(icon: "house", placeholder: "Address", text: $address)
                    IconTextField(icon: "lock", placeholder: "Password", text: $password, isSecure: true)
                    IconTextField(icon: "lock.rotation", placeholder: "Confirm Password", text: $confirmPassword, isSecure: true)
                }
                .padding()
                
                Button(action: {
                    saveChangesTapped()
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("Save Changes").bold()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .onAppear(perform: loadData)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $viewModel.selectedImage)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton()
            }
        }
    }
    
    private var profileImageView: some View {
        Group {
            if let urlString = viewModel.doctor?.imagePath, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image.resizable().frame(width: 100, height: 100).clipShape(Circle())
                } placeholder: {
                    ProgressView()
                }
                .overlay(Circle().stroke(Color.red, lineWidth: 2))
                .onTapGesture { showImagePicker = true }
            } else if let selectedImage = viewModel.selectedImage {
                Image(uiImage: selectedImage)
                    .resizable().frame(width: 100, height: 100)
                    .clipShape(Circle()).overlay(Circle().stroke(Color.red, lineWidth: 2))
                    .onTapGesture { showImagePicker = true }
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .overlay(Text("Select").foregroundColor(.black))
                    .onTapGesture { showImagePicker = true }
            }
        }
    }

    private func loadData() {
        guard let token = KeychainHelper.shared.getToken(forKey: "DR_Token") else {
            alertMessage = "User not logged in."
            showAlert = true
            return
        }

        viewModel.fetchProfile(token: token) { error in
            if let error = error {
                alertMessage = error
                showAlert = true
            } else if let doctor = viewModel.doctor {
                viewModel.putProfile = UpdateDoctorProfileRequest(
                    id: doctor.id,
                    userName: doctor.userName,
                    specialization: doctor.specialization,
                    email: doctor.email,
                    phone: doctor.phoneNumber,
                    address: doctor.address,
                    password: password,
                    confirmPassword: confirmPassword,
                    medicineDescriptions: nil,
                    doctorWorkingTime: nil,
                    doctorWorkingDaysOfWeek: nil,
                    image: nil
                )
                DispatchQueue.main.async {
                    name = doctor.userName
                    specialization = doctor.specialization
                    email = doctor.email
                    phone = doctor.phoneNumber
                    address = doctor.address
                }
            }
        }
    }

    private func saveChangesTapped() {
        guard let token = KeychainHelper.shared.getToken(forKey: "DR_Token") else {
            alertMessage = "Not logged in."
            showAlert = true
            return
        }

        guard !password.isEmpty, !confirmPassword.isEmpty else {
            alertMessage = "Please enter both password and confirm password."
            showAlert = true
            return
        }

        viewModel.putProfile?.userName = name
        viewModel.putProfile?.specialization = specialization
        viewModel.putProfile?.email = email
        viewModel.putProfile?.phone = phone
        viewModel.putProfile?.address = address
        viewModel.putProfile?.password = password
        viewModel.putProfile?.confirmPassword = confirmPassword

        if let imageData = viewModel.selectedImage?.jpegData(compressionQuality: 0.8) {
            viewModel.putProfile?.image = imageData
        }

        viewModel.updateProfileWithImage(token: token) { error in
            alertMessage = error ?? "Profile updated successfully!"
            showAlert = true
        }
    }
}
