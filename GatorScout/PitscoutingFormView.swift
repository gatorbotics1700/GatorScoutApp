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
    
    @State private var intakeType = "Over"
    @State private var intakeLocation = "Ground"
    @State private var hopperCapacity: Double = 0.0
    @State private var shooterType = "Turret"
    @State private var shootLocation = "Move"
    @State private var shotAccuracy: Double = 0.0
    @State private var climb = ""
    @State private var bump = false
    @State private var trench = false
    @State private var auto = ""
    @State private var teleop = ""
    @State private var endgame = ""
    @State private var other = ""

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
                            
                            Section(header: Text("Pitscouting").font(.title3).foregroundColor(.darkGreenFont)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Over or under bumper intake")
                                        .font(.headline)
                                        .foregroundColor(.darkGreenFont)

                                    Picker("", selection: $intakeType) {
                                        Text("Over bumper").tag("Over")
                                        Text("Under bumper").tag("Under")
                                    }
                                    .pickerStyle(.segmented)
                                }
                                .padding(.vertical, 8)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Intake location")
                                        .font(.headline)
                                        .foregroundColor(.darkGreenFont)

                                    Picker("", selection: $intakeLocation) {
                                        Text("Ground intake").tag("Ground")
                                        Text("Outpost").tag("Outpost")
                                        Text("Depot").tag("Depot")
                                    }
                                    .pickerStyle(.segmented)
                                }
                                .padding(.vertical, 8)
                                
                                
                                VStack(alignment: .leading) {
                                    Text("Hopper capacity: \(Int(hopperCapacity)) fuel")
                                        .font(.headline)
                                        .foregroundColor(.darkGreenFont)
                                        .padding(.bottom, 4)
                                    
                                    Slider(value: $hopperCapacity, in: 0...50, step: 5)
                                        .accentColor(.greenTheme2)
                                        .padding(.bottom, 4)
                                    
                                    Text(descriptionHopperCapacity(Int(hopperCapacity)))
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Turret or fixed shooter")
                                        .font(.headline)
                                        .foregroundColor(.darkGreenFont)

                                    Picker("", selection: $shooterType) {
                                        Text("Turret").tag("Turret")
                                        Text("Fixed shooter").tag("Fixed")
                                    }
                                    .pickerStyle(.segmented)
                                }
                                .padding(.vertical, 8)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Shoot on the move or shoot in place")
                                        .font(.headline)
                                        .foregroundColor(.darkGreenFont)

                                    Picker("", selection: $shootLocation) {
                                        Text("Shoot on the move").tag("Move")
                                        Text("Shoot in place").tag("Place")
                                    }
                                    .pickerStyle(.segmented)
                                }
                                .padding(.vertical, 8)
                                
                                
                                VStack(alignment: .leading) {
                                    Text("Shot accuracy: \(Int(shotAccuracy))%")
                                        .font(.headline)
                                        .foregroundColor(.darkGreenFont)
                                        .padding(.bottom, 4)
                                    
                                    Slider(value: $shotAccuracy, in: 0...100, step: 10)
                                        .accentColor(.greenTheme2)
                                        .padding(.bottom, 4)
                                    
                                    Text(descriptionShotAccuracy(Int(shotAccuracy)))
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                
                                VStack(alignment: .leading) {
                                    Text("Climb")
                                        .font(.headline)
                                        .foregroundColor(.darkGreenFont)
                                    
                                    Text("Climb location, L1, L2, L3, auto climb")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                    TextEditor(text: $climb)
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
                                
                                
                                Toggle("Over bump", isOn: $bump)
                                    .foregroundColor(.darkGreenFont)
                                    .font(.headline)
                                
                                Toggle("Under trench", isOn: $trench)
                                    .foregroundColor(.darkGreenFont)
                                    .font(.headline)
                                
                                
                                VStack(alignment: .leading) {
                                    Text("Auto")
                                        .font(.headline)
                                        .foregroundColor(.darkGreenFont)
                                    
                                    TextEditor(text: $auto)
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
                                
                                
                                VStack(alignment: .leading) {
                                    Text("Teleop")
                                        .font(.headline)
                                        .foregroundColor(.darkGreenFont)
                                    
                                    TextEditor(text: $teleop)
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
                                
                                
                                VStack(alignment: .leading) {
                                    Text("Endgame")
                                        .font(.headline)
                                        .foregroundColor(.darkGreenFont)
                                    
                                    TextEditor(text: $endgame)
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
                                
                                
                                VStack(alignment: .leading) {
                                    Text("Other")
                                        .font(.headline)
                                        .foregroundColor(.darkGreenFont)
                                    
                                    Text("Object detection, automated driving, etc")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                    TextEditor(text: $other)
                                        //.padding()
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
            "Intake type": intakeType,
            "Intake location": intakeLocation,
            "Hopper capacity": Int(hopperCapacity),
            "Shooter type": shooterType,
            "Shoot location": shootLocation,
            "Shot accuracy": Int(shotAccuracy),
            "Climb": climb,
            "Bump": bump,
            "Trench": trench,
            "Auto": auto,
            "Teleop": teleop,
            "Endgame": endgame,
            "Other": other
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
        intakeType = "Over"
        intakeLocation = "Ground"
        hopperCapacity = 0.0
        shooterType = "Turret"
        shootLocation = "Move"
        shotAccuracy = 0.0
        climb = ""
        bump = false
        trench = false
        auto = ""
        teleop = ""
        endgame = ""
        other = ""
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
    
    func descriptionHopperCapacity (_ score: Int) -> String {
        switch score {
        case 0: return "0 = No hopper"
        case 5: return "5 = Hopper holds ~5 fuel"
        case 10: return "10 = Hopper holds ~10 fuel"
        case 15: return "15 = Hopper holds ~15 fuel"
        case 20: return "20 = Hopper holds ~20 fuel"
        case 25: return "25 = Hopper holds ~25 fuel"
        case 30: return "30 = Hopper holds ~30 fuel"
        case 35: return "35 = Hopper holds ~35 fuel"
        case 40: return "40 = Hopper holds ~40 fuel"
        case 45: return "45 = Hopper holds ~45 fuel"
        case 50: return "50 = Hopper holds ~50 fuel"
        default: return "Score out of range"
        }
    }
    
    func descriptionShotAccuracy(_ score: Int) -> String {
        switch score {
        case 0: return "0 = No shooting"
        case 10: return "10 = Made ~10% of shots"
        case 20: return "20 = Made ~20% of shots"
        case 30: return "30 = Made ~30% of shots"
        case 40: return "40 = Made ~40% of shots"
        case 50: return "50 = Made ~50% of shots"
        case 60: return "60 = Made ~60% of shots"
        case 70: return "70 = Made ~70% of shots"
        case 80: return "80 = Made ~80% of shots"
        case 90: return "90 = Made ~90% of shots"
        case 100: return "100 = Made all shots"
        default: return "Score out of range"
        }
    }
    
}
