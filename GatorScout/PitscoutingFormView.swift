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

    // Match information
    // @State private var teamNumber = ""
    @StateObject private var viewModel = TeamsViewModel()
    @State private var searchText = ""
    @State private var selectedTeamNumber: String = ""
    @State private var selectedTeam: Int? = nil
    @State private var showResults = false
    @State private var comments = ""

    @State private var isSubmitting = false
    enum ActiveAlert: Identifiable {
        case error(String)
        case success(String)

        var id: String {
            switch self {
            case .error(let msg): return "error-\(msg)"
            case .success(let msg): return "success-\(msg)"
            }
        }
    }
    @State private var activeAlert: ActiveAlert? = nil

    private var filteredTeams: [Int] {
        let allTeams = viewModel.teams.map { $0.teamNumber }.sorted()
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else { return allTeams }
        
        return allTeams.filter { String($0).hasPrefix(trimmed) }
    }
        
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
            
            NavigationView {
                
                ZStack {
                    Color.greenTheme1.ignoresSafeArea()
                    
                    VStack {
                        Form {
                            Section(header: Text("Match Information").font(.title3).foregroundColor(.darkGreenFont)) {
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
                                        selectedTeamNumber = digitsOnly
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
                                                            selectedTeamNumber = String(team)
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
                                
                                /*TextField("Team Number", text: $teamNumber)
                                 .keyboardType(.numberPad)
                                 .padding()
                                 .background(Color.white.opacity(0.8))
                                 .cornerRadius(8)
                                 .foregroundColor(.darkGreenFont)*/
                            }
                            
                            Section(header: Text("Comments").font(.title3).foregroundColor(.darkGreenFont)) {
                                VStack(alignment: .leading) {
                                    Text("Comments")
                                        .font(.headline)
                                        .foregroundColor(.darkGreenFont)
                                    
                                    TextEditor(text: $comments)
                                        .padding()
                                        .background(Color.white.opacity(0.8))
                                        .cornerRadius(8)
                                        .foregroundColor(.darkGreenFont)
                                        .frame(height: 150)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.darkGreenFont, lineWidth: 1)
                                        )
                                }
                                .padding(.vertical)
                            }
                            
                            Section {
                                Button(action: submitData) {
                                    ZStack {
                                        Text(isSubmitting ? "Submitting..." : "Submit")
                                            .foregroundColor(.white)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(Color.greenTheme2)
                                            .cornerRadius(10)
                                            .opacity(isSubmitting ? 0.7 : 1)

                                        if isSubmitting {
                                            ProgressView()
                                        }
                                    }
                                }
                                .disabled(isSubmitting)
                            }
                        }
                        .scrollDismissesKeyboard(.interactively)
                        .scrollContentBackground(.hidden)
                        .background(Color.greenTheme1)
                    }
                    .padding()
                }
                //.navigationBarTitle("FRC Scouting", displayMode: .inline)
                .alert(item: $activeAlert) { alert in
                    switch alert {
                    case .error(let msg):
                        return Alert(
                            title: Text("Error"),
                            message: Text(msg),
                            dismissButton: .default(Text("OK"))
                        )
                    case .success(let msg):
                        return Alert(
                            title: Text("Success"),
                            message: Text(msg),
                            dismissButton: .default(Text("Log Another Team"), action: clearFields)
                        )
                    }
                }
            }
        }
    }

    func submitData() {
        selectedTeamNumber = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // guard !teamNumber.isEmpty else {
        guard !selectedTeamNumber.isEmpty else {
            activeAlert = .error("Team Number is required.")
            return
        }

        isSubmitting = true

        var formData: [String: Any] = [
            "formType": "pit",
            "Username": username,
            // "Team number": teamNumber,
            "Team number": selectedTeamNumber,
            "Comments": comments
        ]
        
        FormSubmissionManager.shared.submitData(formData) { success in
            isSubmitting = false
            if success {
                FormSubmissionManager.shared.resubmitSavedForms()
                activeAlert = .success("Submitted successfully!")
            } else {
                activeAlert = .success("Saved locally. Will retry when online.")
            }
        }
    }

    func clearFields() {
        // teamNumber = ""
        searchText = ""
        selectedTeamNumber = ""
        selectedTeam = nil
        showResults = false
        comments = ""
    }
    
    struct ExpandableToggle: View {
        let title: String
        let descriptionProvider: (String) -> String
        @Binding var isOn: Bool
        
        @State private var expanded = false

        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Button {
                        withAnimation {
                            expanded.toggle()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(title)
                                .font(.headline)
                                .foregroundColor(.darkGreenFont)

                            Image(systemName: expanded ? "chevron.up" : "chevron.down")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Toggle("", isOn: $isOn)
                        .labelsHidden()
                }

                if expanded {
                    Text(descriptionProvider(title))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.vertical, 4)
        }
    }
}
