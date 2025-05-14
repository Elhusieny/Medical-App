import SwiftUI
import SDWebImageSwiftUI

struct PatientHomeView: View {
    @StateObject private var viewModel = GetAllDoctorsViewModel()
    @State private var selectedDoctor: Doctors?
    @State private var showDoctorDetails = false
    @State private var showProfile = false
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var showAllDoctors = false

    
   // let categories = ["All", "Cardiology", "Dermatology", "Neurology", "Pediatrics", "Orthopedics","hearts"]
    let columns = [GridItem(.flexible(), spacing: 16)]
    let categories: [CategoryItem] = [
        CategoryItem(name: "All", imageName: "square.grid.2x2", isSystemImage: true),
        CategoryItem(name: "Cardiology", imageName: "heart.fill", isSystemImage: true),
        CategoryItem(name: "Cardiologist", imageName: "Cardiologist", isSystemImage: false),
        CategoryItem(name: "Dentist", imageName: "Dentist", isSystemImage: false), // use asset
        CategoryItem(name: "COVID-19", imageName: "cross.case.fill", isSystemImage: true),
        CategoryItem(name: "Dermatology", imageName: "face.smiling.fill", isSystemImage: true),
        CategoryItem(name: "Neurology", imageName: "brain.head.profile", isSystemImage: true),
        CategoryItem(name: "Pediatrics", imageName: "stethoscope", isSystemImage: true),
        CategoryItem(name: "Orthopedics", imageName: "figure.walk", isSystemImage: true)
    ]



    var filteredDoctors: [Doctors] {
        if searchText.isEmpty {
            if selectedCategory == "All" {
                return viewModel.doctors
            } else {
                return viewModel.doctors.filter { $0.specialization?.contains(selectedCategory) ?? false }
            }
        } else {
            return viewModel.doctors.filter { doctor in
                let nameMatch = doctor.userName?.lowercased().contains(searchText.lowercased()) ?? false
                let specializationMatch = doctor.specialization?.lowercased().contains(searchText.lowercased()) ?? false
                return nameMatch || specializationMatch
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            
            
            VStack(spacing: 30) {
                // Search Bar
                SearchBar(searchText: $searchText)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                
                // Categories Scroll View
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(categories) { category in
                            CategoryItemView(category: category, isSelected: category.name == selectedCategory) {
                                selectedCategory = category.name
                            }
                        }
                    }
                    .padding(.horizontal)
                }


                .padding(.bottom, 16)
                
                // Doctors Section
                VStack(alignment: .leading, spacing: 12) {
                    // Top Doctors Header with "See All" Button
                    HStack {
                        Text("Top Doctors")
                            .font(.title2.bold())

                        Spacer()

                        Button(action: {
                            showAllDoctors = true
                        }) {
                            Text("See All")
                                .font(.subheadline)
                                .foregroundColor(Color(red: 139/255, green: 0, blue: 0))
                        }
                    }
                    .padding(.horizontal)

                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(filteredDoctors, id: \.id) { doctor in
                                DoctorCardView(doctor: doctor)
                                    .onTapGesture {
                                        selectedDoctor = doctor
                                        showDoctorDetails = true
                                    }
                            }
                        }
                        .padding(.vertical)

                        .padding(.horizontal)
                    }
                    .padding(.vertical)

                    
//                    // All Doctors Grid
//                    Text("All Doctors")
//                        .font(.title2.bold())
//                        .padding(.horizontal)
                    
//                    ScrollView {
//                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
//                            ForEach(filteredDoctors, id: \.id) { doctor in
//                                DoctorCardView(doctor: doctor, isHorizontal: false)
//                                    .onTapGesture {
//                                        selectedDoctor = doctor
//                                        showDoctorDetails = true
//                                    }
//                            }
//                        }
//                        .padding()
//                    }
                }
                
                Spacer()
            }
            .navigationTitle("Home")
            // ... your existing content ...
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        // existing bottom toolbar...
                        
                        // ➤ Add this trailing menu item
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Menu {
                                Button {
                                    logout()
                                } label: {
                                    Label("Logout", systemImage: "power")
                                }

                                Button {
                                    showProfile = true
                                } label: {
                                    Label("Profile", systemImage: "person.crop.circle")
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                                    .font(.title2)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            
            .overlay(toolbarView, alignment: .bottom)
            .onAppear { fetchDoctors() }
            .navigationDestination(isPresented: $showDoctorDetails) {
                if let doctor = selectedDoctor {
                    DoctorDetailsView(
                        doctorName: doctor.userName ?? "",
                        specialization: doctor.specialization ?? "",
                        doctorId: doctor.id ?? "",
                        doctorImage: doctor.imagePath ?? ""
                    )
                }
            }
            .navigationDestination(isPresented: $showProfile) {
                PatientProfileView()
            }
            .navigationDestination(isPresented: $showAllDoctors) {
                AllDoctorsView(doctors: filteredDoctors) { doctor in
                    selectedDoctor = doctor
                    showDoctorDetails = true
                }
            }

        }
    }
    
    // MARK: - Components
    
    struct SearchBar: View {
        @Binding var searchText: String
        
        var body: some View {
            HStack {
                TextField("Search doctors...", text: $searchText)
                    .padding(8)
                    .padding(.horizontal, 24)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .overlay(
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 8)
                            
                            if !searchText.isEmpty {
                                Button(action: { searchText = "" }) {
                                    Image(systemName: "multiply.circle.fill")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 8)
                                }
                            }
                        }
                    )
            }
        }
    }
    
    struct CategoryPill: View {
        let category: String
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Text(category)
                    .font(.subheadline)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(isSelected ? Color(red: 139/255, green: 0, blue: 0) : Color(.systemGray5))
                    .foregroundColor(isSelected ? .white : .primary)
                    .cornerRadius(20)
            }
        }
    }
    private var toolbarView: some View {
        HStack {
            Spacer()
            
            toolbarButton(systemName: "power") {
                logout()
            }
            
            Spacer()
            
            toolbarButton(systemName: "calendar") {
                openAppointments()
            }
            
            Spacer()
            
            toolbarButton(systemName: "person.circle") {
                showProfile = true
            }
            
            Spacer()
            
            toolbarButton(systemName: "bell") {
                openNotifications()
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .background(Color(red: 139/255, green: 0, blue: 0))
    }
    
    private func toolbarButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
        }
    }
    
    private func fetchDoctors() {
        let token = KeychainHelper.shared.getToken(forKey: "PT_Token")
        if let token = token {
            viewModel.fetchDoctors(token: token) { success in
                if !success {
                    print("Failed to fetch doctors.")
                }
            }
        } else {
            print("No token available.")
        }
    }
    
    private func logout() {
        // 1) Clear saved credentials
        UserDefaults.standard.removeObject(forKey: "PT_Email")
        UserDefaults.standard.removeObject(forKey: "PT_Password")
        KeychainHelper.shared.deleteToken(forKey: "PT_Token")

        // 2) Grab your app’s key window and swap the root
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first
        else { return }

        // 3) Instantiate your UIKit login VC by its storyboard ID
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "loginvc")

        // 4) Replace the root instantly with no animation
        UIView.performWithoutAnimation {
            window.rootViewController = loginVC
            window.makeKeyAndVisible()
        }
    }

    private func openAppointments() {
        print("Appointments tapped")
        // Navigate to appointments view
    }
    
    private func openNotifications() {
        print("Notifications tapped")
        // Navigate to notifications view
    }
}


struct DoctorCardView: View {
    let doctor: Doctors
    var isHorizontal: Bool = true

    var body: some View {
        Group {
            if isHorizontal {
                horizontalCard
            } else {
                verticalFullWidthCard
            }
        }
    }

    private var verticalFullWidthCard: some View {
        HStack(spacing: 16) {
            
            if let imageUrl = doctor.imagePath, let url = URL(string: imageUrl) {
                WebImage(url: url)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.gray)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(doctor.userName ?? "Unknown Doctor")
                    .font(.headline)
                Text(doctor.specialization ?? "General")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private var horizontalCard: some View {
        VStack(spacing: 8) {
            ZStack {
                if let imageUrl = doctor.imagePath, let url = URL(string: imageUrl) {
                    WebImage(url: url)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.gray)
                }

                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 120, height: 120)
            }
            .shadow(radius: 3)

            VStack(spacing: 4) {
                Text(doctor.userName ?? "Unknown Doctor")
                    .font(.headline)
                    .lineLimit(1)

                Text(doctor.specialization ?? "General")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(width: 120)
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct PatientHomeView_Previews: PreviewProvider {
    static var previews: some View {
        PatientHomeView()
    }
}
struct AllDoctorsView: View {
    let doctors: [Doctors]
    var onSelect: (Doctors) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(doctors, id: \.id) { doctor in
                    DoctorCardView(doctor: doctor, isHorizontal: false)
                        .onTapGesture {
                            onSelect(doctor)
                        }
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("All Doctors")
        .navigationBarTitleDisplayMode(.inline)
    }
}
struct CategoryItem: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String // SF Symbol or asset name
    let isSystemImage: Bool

}
 

struct CategoryItemView: View {
    let category: CategoryItem
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            if category.isSystemImage {
                
                Image(systemName: category.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .foregroundColor(isSelected ? .white : .red)
                    .padding(12)
                    .background(isSelected ? Color(red: 139/255, green: 0, blue: 0) : Color(.systemGray5))
                    .clipShape(Circle())
            }
            else {
                Image(category.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .background(isSelected ? Color(red: 139/255, green: 0, blue: 0) : Color(.systemGray5))
                    .padding(12)
                    .background(isSelected ? Color(red: 139/255, green: 0, blue: 0) : Color(.systemGray5))
                    .clipShape(Circle())
            }
            Text(category.name)
                .font(.caption)
                .foregroundColor(isSelected ? .red : .primary)
                .multilineTextAlignment(.center)
        }
        .onTapGesture {
            onTap()
        }
        .frame(width: 80)
       
    }
}
