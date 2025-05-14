import SwiftUI

struct PatientProfileView: View {
    @StateObject var viewModel = PatientProfileViewModel()
    
    @State private var showImagePicker = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var address = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var nationalID = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                profileImageView
                
                VStack(spacing: 16) {
                    IconTextField(icon: "person", placeholder: "Full Name", text: $name)
                    IconTextField(icon: "person.text.rectangle", placeholder: "National ID", text: $nationalID)
                    IconTextField(icon: "envelope", placeholder: "Email", text: $email)
                    IconTextField(icon: "phone", placeholder: "Phone Number", text: $phone)
                    IconTextField(icon: "house", placeholder: "Address", text: $address)
                    IconTextField(icon: "lock", placeholder: "Password", text: $password, isSecure: true)
                    IconTextField(icon: "lock.rotation", placeholder: "Confirm Password", text: $confirmPassword, isSecure: true)
                }
                .padding()
                
                Button(action: {
                    saveChangesTapped()
                    // Save changes
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("Save Changes")
                            .bold()
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
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    BackButton()
                }
        }
    }
    
    private var profileImageView: some View {
        Group {
            if let imagePath = viewModel.profile?.imagePath,
               let url = URL(string: imagePath) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.red, lineWidth: 2))
                } placeholder: {
                    ProgressView()
                }
                .onTapGesture {
                    showImagePicker = true
                }
            } else if let selectedImage = viewModel.selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.red, lineWidth: 2))
                    .onTapGesture {
                        showImagePicker = true
                    }
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .overlay(Text("Select").foregroundColor(.black))
                    .onTapGesture {
                        showImagePicker = true
                    }
            }
        }
    }
    
    
    private func loadData() {
        guard let id = UserDefaults.standard.string(forKey: "PT_ID"),
              let token = KeychainHelper.shared.getToken(forKey: "PT_Token") else {
            alertMessage = "User not logged in."
            showAlert = true
            return
        }
        
        viewModel.fetchProfile(id: id, token: token) { error in
            if let error = error {
                alertMessage = error
                showAlert = true
            } else if let profile = viewModel.profile {
                // Fill ViewModel model
                viewModel.putProfile = UpdatePatientProfileRequest(
                    id: profile.id,
                    nationalID: profile.nationalID,
                    patientCode: profile.patientCode,
                    userName: profile.userName,
                    email: profile.email,
                    phone: profile.phone,
                    address: profile.address,
                    chronicDiseases: profile.chronicDiseases ?? "",
                    previousOperations: profile.previousOperations ?? "",
                    allergies: profile.allergies ?? "",
                    currentMedications: profile.currentMedications ?? "",
                    comments: profile.comments ?? "",
                    password: password,
                    ConfirmPassword: confirmPassword,
                    image: nil
                )
                
                // ✅ Update @State fields to show in the UI
                DispatchQueue.main.async {
                    name = profile.userName
                    email = profile.email
                    phone = profile.phone
                    address = profile.address
                    nationalID = profile.nationalID
                }
            }
        }
    }
    
    
    private func saveChangesTapped() {
        guard let token = KeychainHelper.shared.getToken(forKey: "PT_Token") else {
            alertMessage = "Not logged in."
            showAlert = true
            return
        }
        
        guard !password.isEmpty, !confirmPassword.isEmpty else {
            alertMessage = "Please enter both password and confirm password."
            showAlert = true
            return
        }
        
        // Update profile data
        viewModel.putProfile?.userName = name
        viewModel.putProfile?.email = email
        viewModel.putProfile?.phone = phone
        viewModel.putProfile?.address = address
        viewModel.putProfile?.nationalID = nationalID
        viewModel.putProfile?.password = password
        viewModel.putProfile?.ConfirmPassword = confirmPassword
        
        // ✅ Assign image as Data directly to the model
        if let selectedImage = viewModel.selectedImage,
           let imageData = selectedImage.jpegData(compressionQuality: 0.8) {
            viewModel.putProfile?.image = imageData
        }
        
        // ✅ Call update (which already handles sending image + profile)
        viewModel.updateProfileWithImage(token: token) { error in
            alertMessage = error ?? "Profile updated successfully!"
            showAlert = true
        }
    }
}
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
    }
}

struct IconTextField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
        )
    }
}
#Preview {
    PatientProfileView()
}
