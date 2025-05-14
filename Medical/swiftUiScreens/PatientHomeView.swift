//
//  HomeView.swift
//  Medical
//
//  Created by Ahmed Elhussieny on 11/05/2025.
//


import SwiftUI

struct PatientHomeView: View {
    @StateObject private var viewModel = GetAllDoctorsViewModel()

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.doctors) { doctor in
                            NavigationLink(destination: DoctorDetailsView(
                                doctorName: doctor.userName ?? "",
                                specialization: doctor.specialization ?? "",
                                doctorId: doctor.id ?? "",
                                doctorImage: doctor.imagePath ?? ""
                            )) {
                                DoctorCardView(doctor: doctor)
                            }
                        }
                    }
                    .padding()
                }

                ToolbarView()
            }
            .navigationTitle("Home")
            .navigationBarBackButtonHidden(true)
            .onAppear {
                viewModel.fetchDoctors()
            }
        }
    }
}
