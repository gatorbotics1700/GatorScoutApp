//
//  PitscoutingFormView.swift
//  GatorScout
//
//  Created by Emma Li on 2/13/26.
//

import SwiftUI
import Foundation

struct PitscoutingFormView: View {
    let username: String
    @Binding var isLoggedIn: Bool
    
    //Team information
    // @State private var teamNumber = ""
    @StateObject private var viewModel = TeamsViewModel()
    @State private var searchText = ""
    @State private var selectedTeamNumber: String = ""
    @State private var selectedTeam: Int? = nil
    @State private var showResults = false
    @State private var isSubmitting = false
    
    @State private var comments = ""
    
    @State private var showErrorAlert = false
    @State private var showSuccessAlert = false
    @State private var alertMessage = ""
    
    @State private var savedForms: [[String: Any]] = []
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    isLoggedIn = false
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.darkGreenFont)
                    .font(.headline)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
            .background(Color.greenTheme1)
            
            var filteredTeams: [Int] {
                let allTeams = viewModel.teams.map { $0.teamNumber }.sorted()
                let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                
                guard !trimmed.isEmpty else { return allTeams }
                
                return allTeams.filter { String($0).hasPrefix(trimmed) }
            }
            
            NavigationView {
                
                ZStack {
                    Color.greenTheme1.edgesIgnoringSafeArea(.all)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            UIApplication.shared.endEditing()
                        }
                    
                    VStack {
                        Form {
                            Section(header: Text("Pit Scouting").font(.title3).foregroundColor(.darkGreenFont)) {
                                VStack(alignment: .leading, spacing: 8) {
                                    
                                    TextField("Type team number", text: $searchText, onEditingChanged: { _ in
                                        showResults = true
                                    })
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(.plain)
                                    .padding(10)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                    .onChange(of: searchText) { oldValue, newValue in
                                        let digitsOnly = newValue.filter { $0.isNumber }
                                        if digitsOnly != newValue { searchText = digitsOnly }
                                        showResults = true
                                    }
                                    
                                    if viewModel.teams.isEmpty {
                                        ProgressView("Loading teams...")
                                    }
                                    
                                    if showResults && !viewModel.teams.isEmpty {
                                        if filteredTeams.isEmpty {
                                            Text("No teams match")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        } else {
                                            ScrollView {
                                                LazyVStack(alignment: .leading, spacing: 0) {
                                                    ForEach(filteredTeams, id: \.self) { team in
                                                        Button {
                                                            selectedTeam = team
                                                            searchText = String(team)
                                                            showResults = false
                                                            UIApplication.shared.endEditing()
                                                        } label: {
                                                            HStack {
                                                                Text("\(team)")
                                                                Spacer()
                                                                if selectedTeam == team {
                                                                    Image(systemName: "checkmark")
                                                                        .foregroundColor(.secondary)
                                                                }
                                                            }
                                                            .padding(.vertical, 10)
                                                            .padding(.horizontal, 12)
                                                        }
                                                        .buttonStyle(.plain)
                                                        
                                                        Divider()
                                                    }
                                                }
                                            }
                                            .frame(maxHeight: 220)
                                            .background(Color(.systemBackground))
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.gray.opacity(0.3))
                                            )
                                        }
                                    }
                                }
                                .onAppear {
                                    viewModel.fetchTeams()
                                }
                                VStack(alignment: .leading) {
                                    Text("Comments")
                                        .font(.headline)
                                        .foregroundColor(.darkGreenFont)
                                        .padding(.bottom, 4)
                                    
                                    TextEditor(text: $comments)
                                        .padding()
                                        .background(Color.white.opacity(0.8))
                                        .cornerRadius(8)
                                        .foregroundColor(.darkGreenFont)
                                        .frame(height: 100)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.darkGreenFont, lineWidth: 1)
                                        )
                                }
                                .padding(.vertical)
                            }
                            
                            Section {
                                Button(action: submitData) {
                                    if isSubmitting {
                                        ProgressView()
                                    } else {
                                        Text("Submit")
                                            .foregroundColor(.white)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(Color.greenTheme2)
                                            .cornerRadius(10)
                                    }
                                }
                            }
                        }
                        .scrollContentBackground(.hidden)
                        .background(Color.greenTheme1)
                    }
                    .padding()
                }
                //.navigationBarTitle("FRC Scouting", displayMode: .inline)
                .alert(isPresented: $showErrorAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                .alert(isPresented: $showSuccessAlert) {
                    Alert(
                        title: Text("Success"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("Log Another Match"), action: clearFields)
                    )
                }
            }
        }
    }
    func submitData() {
        // guard !teamNumber.isEmpty else {
        guard !selectedTeamNumber.isEmpty else {
            alertMessage = "Team Number is required."
            showErrorAlert = true
            return
        }

        isSubmitting = true

        var formData: [String: Any] = [
            "Username": username,
            // "Team number": teamNumber,
            "Team number": selectedTeamNumber,
            "Comments": comments
        ]

        if !comments.isEmpty {
            formData["Comments"] = comments
        }

        // Call FormSubmissionManager to handle online/offline submission
        FormSubmissionManager.shared.submitData(formData)

        isSubmitting = false
        alertMessage = "Data queued for submission."
        showSuccessAlert = true
    }

    func clearFields() {
        // teamNumber = ""
        selectedTeamNumber = ""
        comments = ""
    }
}
