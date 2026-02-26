import SwiftUI
import Foundation

struct ScoutingFormView: View {
    let username: String
    @Binding var isLoggedIn: Bool

    // Match information
    // @State private var teamNumber = ""
    @StateObject private var viewModel = TeamsViewModel()
    @State private var searchText = ""
    @State private var selectedTeamNumber: String = ""
    @State private var selectedTeam: Int? = nil
    @State private var showResults = false
    @State private var matchNumber = ""
    @State private var allianceColor = "Red"

    // Auto
    @State private var autoScorePreload = false
    @State private var autoOutpost = false
    @State private var autoDepot = false
    @State private var autoNeutral = false
    @State private var autoPassing = false
    @State private var autoHerding = false
    @State private var autoCycling = false
    @State private var autoCycles = 0
    @State private var autoClimb = false
    @State private var autoClimbLocation = ""
    @State private var autoOther = ""
    @State private var autoWon = true

    // Teleop
    @State private var inactive1Collecting = false
    @State private var inactive1Passing = false
    @State private var inactive1Herding = false
    @State private var inactive1Defense = false
    @State private var inactive1Other = ""
    
    @State private var active1Shooting = false
    @State private var active1Passing = false
    @State private var active1Herding = false
    @State private var active1Cycling = false
    @State private var active1Cycles = 0
    @State private var active1Other = ""
    
    @State private var inactive2Collecting = false
    @State private var inactive2Passing = false
    @State private var inactive2Herding = false
    @State private var inactive2Defense = false
    @State private var inactive2Other = ""
    
    @State private var active2Shooting = false
    @State private var active2Passing = false
    @State private var active2Herding = false
    @State private var active2Cycling = false
    @State private var active2Cycles = 0
    @State private var active2Other = ""

    // Endgame
    @State private var endgameShooting = false
    @State private var endgamePassing = false
    @State private var endgameHerding = false
    @State private var endgameDefense = false
    @State private var endgameCycling = false
    @State private var endgameCycles = 0
    @State private var climb = "None"
    @State private var climbLocation = ""
    @State private var endgameOther = ""

    // Defense
    @State private var defenseCollectOppFuel = false
    @State private var defenseBlocking = false
    @State private var defenseHitting = false
    @State private var defensePinning = false
    @State private var defenseOther = ""
    
    // Comments
    @State private var drivingScore: Double = 0.0
    @State private var intakeAbility: Double = 0.0
    @State private var hopperCapacity = "None"
    @State private var shotAccuracy: Double = 0.0
    @State private var shootingLocationFlexibility: Double = 0.0
    @State private var bumpVsTrench: Double = 3.0
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
                                
                                TextField("Match Number", text: $matchNumber)
                                    .keyboardType(.numberPad)
                                    .padding()
                                    .background(Color.white.opacity(0.8))
                                    .cornerRadius(8)
                                    .foregroundColor(.darkGreenFont)
                                
                                HStack(spacing: 0) {
                                    segment(title: "Red", color: .red, value: "Red")
                                    Divider()
                                    segment(title: "Blue", color: .blue, value: "Blue")
                                }
                                .frame(height: 36)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.35))
                                )
                            }
                            
                            Section(header: Text("Auto").font(.title3).foregroundColor(.darkGreenFont)) {
                                Toggle("Scored any preload", isOn: $autoScorePreload)
                                    .foregroundColor(.darkGreenFont)
                                    .font(.headline)
                                Toggle("Scored any outpost fuel", isOn: $autoOutpost)
                                    .foregroundColor(.darkGreenFont)
                                    .font(.headline)
                                Toggle("Scored any depot fuel", isOn: $autoDepot)
                                    .foregroundColor(.darkGreenFont)
                                    .font(.headline)
                                Toggle("Picked up neutral zone fuel", isOn: $autoNeutral)
                                    .foregroundColor(.darkGreenFont)
                                    .font(.headline)
                                ExpandableToggle(
                                    title: "Passing",
                                    descriptionProvider: robotDescription,
                                    isOn: $autoPassing
                                )
                                ExpandableToggle(
                                    title: "Herding",
                                    descriptionProvider: robotDescription,
                                    isOn: $autoHerding
                                )
                                ExpandableToggle(
                                    title: "Cycling",
                                    descriptionProvider: robotDescription,
                                    isOn: $autoCycling
                                )
                                if (autoCycling) {
                                    VStack(alignment: .leading, spacing: 16) {
                                        HStack {
                                            Text("Auto cycles:")
                                                .font(.headline)
                                                .foregroundColor(.darkGreenFont)
                                                .padding(.trailing, 8)
                                            Spacer()
                                            Picker("Auto Cycles", selection: $autoCycles) {
                                                ForEach(0..<11) { number in
                                                    Text("\(number)").tag(number)
                                                }
                                            }
                                            .pickerStyle(WheelPickerStyle())
                                            .frame(width: 100, height: 120)
                                            .clipped()
                                            .background(Color.white.opacity(0.8))
                                            .cornerRadius(8)
                                            .foregroundColor(.darkGreenFont)
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                                Toggle("Climbed L1", isOn: $autoClimb)
                                    .foregroundColor(.darkGreenFont)
                                    .font(.headline)
                                VStack(alignment: .leading) {
                                    Text("Climb location")
                                        .font(.headline)
                                        .foregroundColor(.darkGreenFont)
                                    
                                    Text("Depot side, outpost side, center, outside rung, inside rung, etc")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                    TextEditor(text: $autoClimbLocation)
                                        .padding()
                                        .background(Color.white.opacity(0.8))
                                        .cornerRadius(8)
                                        .foregroundColor(.darkGreenFont)
                                        .frame(height: 50)
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
                                        .padding(.bottom, 4)
                                    
                                    TextEditor(text: $autoOther)
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
                            }
                            
                            Section(header: Text("Teleop").font(.title3).foregroundColor(.darkGreenFont)) {
                                Toggle("Auto won?", isOn: $autoWon)
                                    .foregroundColor(.darkGreenFont)
                                    .font(.headline)
                            }
                            
                            if(autoWon) {
                                Section(header: Text("Period 1 - Inactive").font(.body).foregroundColor(.darkGreenFont)) {
                                    ExpandableToggle(
                                        title: "Collecting",
                                        descriptionProvider: robotDescription,
                                        isOn: $inactive1Collecting
                                    )
                                    ExpandableToggle(
                                        title: "Passing",
                                        descriptionProvider: robotDescription,
                                        isOn: $inactive1Passing
                                    )
                                    ExpandableToggle(
                                        title: "Herding",
                                        descriptionProvider: robotDescription,
                                        isOn: $inactive1Herding
                                    )
                                    ExpandableToggle(
                                        title: "Defense",
                                        descriptionProvider: robotDescription,
                                        isOn: $inactive1Defense
                                    )
                                    VStack(alignment: .leading) {
                                        Text("Other")
                                            .font(.headline)
                                            .foregroundColor(.darkGreenFont)
                                            .padding(.bottom, 4)
                                        
                                        TextEditor(text: $inactive1Other)
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
                                }
                                Section(header: Text("Period 2 - Active").font(.body).foregroundColor(.darkGreenFont)) {
                                    ExpandableToggle(
                                        title: "Shooting fuel in alliance zone",
                                        descriptionProvider: robotDescription,
                                        isOn: $active1Shooting
                                    )
                                    ExpandableToggle(
                                        title: "Passing",
                                        descriptionProvider: robotDescription,
                                        isOn: $active1Passing
                                    )
                                    ExpandableToggle(
                                        title: "Herding",
                                        descriptionProvider: robotDescription,
                                        isOn: $active1Herding
                                    )
                                    ExpandableToggle(
                                        title: "Cycling",
                                        descriptionProvider: robotDescription,
                                        isOn: $active1Cycling
                                    )
                                    if (active1Cycling) {
                                        VStack(alignment: .leading, spacing: 16) {
                                            HStack {
                                                Text("Number of cycles:")
                                                    .font(.headline)
                                                    .foregroundColor(.darkGreenFont)
                                                    .padding(.trailing, 8)
                                                Spacer()
                                                Picker("Number of cycles:", selection: $active1Cycles) {
                                                    ForEach(0..<31) { number in
                                                        Text("\(number)").tag(number)
                                                    }
                                                }
                                                .pickerStyle(WheelPickerStyle())
                                                .frame(width: 100, height: 120)
                                                .clipped()
                                                .background(Color.white.opacity(0.8))
                                                .cornerRadius(8)
                                                .foregroundColor(.darkGreenFont)
                                            }
                                            .padding(.vertical, 4)
                                        }
                                    }
                                    VStack(alignment: .leading) {
                                        Text("Other")
                                            .font(.headline)
                                            .foregroundColor(.darkGreenFont)
                                            .padding(.bottom, 4)
                                        
                                        TextEditor(text: $active1Other)
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
                                }
                                Section(header: Text("Period 3 - Inactive").font(.body).foregroundColor(.darkGreenFont)) {
                                    ExpandableToggle(
                                        title: "Collecting",
                                        descriptionProvider: robotDescription,
                                        isOn: $inactive2Collecting
                                    )
                                    ExpandableToggle(
                                        title: "Passing",
                                        descriptionProvider: robotDescription,
                                        isOn: $inactive2Passing
                                    )
                                    ExpandableToggle(
                                        title: "Herding",
                                        descriptionProvider: robotDescription,
                                        isOn: $inactive2Herding
                                    )
                                    ExpandableToggle(
                                        title: "Defense",
                                        descriptionProvider: robotDescription,
                                        isOn: $inactive2Defense
                                    )
                                    VStack(alignment: .leading) {
                                        Text("Other")
                                            .font(.headline)
                                            .foregroundColor(.darkGreenFont)
                                            .padding(.bottom, 4)
                                        
                                        TextEditor(text: $inactive2Other)
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
                                }
                                Section(header: Text("Period 4 - Active").font(.body).foregroundColor(.darkGreenFont)) {
                                    ExpandableToggle(
                                        title: "Shooting fuel in alliance zone",
                                        descriptionProvider: robotDescription,
                                        isOn: $active2Shooting
                                    )
                                    ExpandableToggle(
                                        title: "Passing",
                                        descriptionProvider: robotDescription,
                                        isOn: $active2Passing
                                    )
                                    ExpandableToggle(
                                        title: "Herding",
                                        descriptionProvider: robotDescription,
                                        isOn: $active2Herding
                                    )
                                    ExpandableToggle(
                                        title: "Cycling",
                                        descriptionProvider: robotDescription,
                                        isOn: $active2Cycling
                                    )
                                    if (active2Cycling) {
                                        VStack(alignment: .leading, spacing: 16) {
                                            HStack {
                                                Text("Number of cycles:")
                                                    .font(.headline)
                                                    .foregroundColor(.darkGreenFont)
                                                    .padding(.trailing, 8)
                                                Spacer()
                                                Picker("Number of cycles:", selection: $active2Cycles) {
                                                    ForEach(0..<31) { number in
                                                        Text("\(number)").tag(number)
                                                    }
                                                }
                                                .pickerStyle(WheelPickerStyle())
                                                .frame(width: 100, height: 120)
                                                .clipped()
                                                .background(Color.white.opacity(0.8))
                                                .cornerRadius(8)
                                                .foregroundColor(.darkGreenFont)
                                            }
                                            .padding(.vertical, 4)
                                        }
                                    }
                                    VStack(alignment: .leading) {
                                        Text("Other")
                                            .font(.headline)
                                            .foregroundColor(.darkGreenFont)
                                            .padding(.bottom, 4)
                                        
                                        TextEditor(text: $active2Other)
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
                                }
                            } else {
                                Section(header: Text("Period 1 - Active").font(.body).foregroundColor(.darkGreenFont)) {
                                    ExpandableToggle(
                                        title: "Shooting fuel in alliance zone",
                                        descriptionProvider: robotDescription,
                                        isOn: $active1Shooting
                                    )
                                    ExpandableToggle(
                                        title: "Passing",
                                        descriptionProvider: robotDescription,
                                        isOn: $active1Passing
                                    )
                                    ExpandableToggle(
                                        title: "Herding",
                                        descriptionProvider: robotDescription,
                                        isOn: $active1Herding
                                    )
                                    ExpandableToggle(
                                        title: "Cycling",
                                        descriptionProvider: robotDescription,
                                        isOn: $active1Cycling
                                    )
                                    if (active1Cycling) {
                                        VStack(alignment: .leading, spacing: 16) {
                                            HStack {
                                                Text("Number of cycles:")
                                                    .font(.headline)
                                                    .foregroundColor(.darkGreenFont)
                                                    .padding(.trailing, 8)
                                                Spacer()
                                                Picker("Number of cycles:", selection: $active1Cycles) {
                                                    ForEach(0..<31) { number in
                                                        Text("\(number)").tag(number)
                                                    }
                                                }
                                                .pickerStyle(WheelPickerStyle())
                                                .frame(width: 100, height: 120)
                                                .clipped()
                                                .background(Color.white.opacity(0.8))
                                                .cornerRadius(8)
                                                .foregroundColor(.darkGreenFont)
                                            }
                                            .padding(.vertical, 4)
                                        }
                                    }
                                    VStack(alignment: .leading) {
                                        Text("Other")
                                            .font(.headline)
                                            .foregroundColor(.darkGreenFont)
                                            .padding(.bottom, 4)
                                        
                                        TextEditor(text: $active1Other)
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
                                }
                                Section(header: Text("Period 2 - Inactive").font(.body).foregroundColor(.darkGreenFont)) {
                                    ExpandableToggle(
                                        title: "Collecting",
                                        descriptionProvider: robotDescription,
                                        isOn: $inactive1Collecting
                                    )
                                    ExpandableToggle(
                                        title: "Passing",
                                        descriptionProvider: robotDescription,
                                        isOn: $inactive1Passing
                                    )
                                    ExpandableToggle(
                                        title: "Defense",
                                        descriptionProvider: robotDescription,
                                        isOn: $inactive1Defense
                                    )
                                    VStack(alignment: .leading) {
                                        Text("Other")
                                            .font(.headline)
                                            .foregroundColor(.darkGreenFont)
                                            .padding(.bottom, 4)
                                        
                                        TextEditor(text: $inactive1Other)
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
                                }
                                Section(header: Text("Period 3 - Active").font(.body).foregroundColor(.darkGreenFont)) {
                                    ExpandableToggle(
                                        title: "Shooting fuel in alliance zone",
                                        descriptionProvider: robotDescription,
                                        isOn: $active2Shooting
                                    )
                                    ExpandableToggle(
                                        title: "Passing",
                                        descriptionProvider: robotDescription,
                                        isOn: $active2Passing
                                    )
                                    ExpandableToggle(
                                        title: "Cycling",
                                        descriptionProvider: robotDescription,
                                        isOn: $active2Cycling
                                    )
                                    if (active2Cycling) {
                                        VStack(alignment: .leading, spacing: 16) {
                                            HStack {
                                                Text("Number of cycles:")
                                                    .font(.headline)
                                                    .foregroundColor(.darkGreenFont)
                                                    .padding(.trailing, 8)
                                                Spacer()
                                                Picker("Number of cycles:", selection: $active2Cycles) {
                                                    ForEach(0..<31) { number in
                                                        Text("\(number)").tag(number)
                                                    }
                                                }
                                                .pickerStyle(WheelPickerStyle())
                                                .frame(width: 100, height: 120)
                                                .clipped()
                                                .background(Color.white.opacity(0.8))
                                                .cornerRadius(8)
                                                .foregroundColor(.darkGreenFont)
                                            }
                                            .padding(.vertical, 4)
                                        }
                                    }
                                    VStack(alignment: .leading) {
                                        Text("Other")
                                            .font(.headline)
                                            .foregroundColor(.darkGreenFont)
                                            .padding(.bottom, 4)
                                        
                                        TextEditor(text: $active2Other)
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
                                }
                                Section(header: Text("Period 4 - Inactive").font(.body).foregroundColor(.darkGreenFont)) {
                                    ExpandableToggle(
                                        title: "Collecting",
                                        descriptionProvider: robotDescription,
                                        isOn: $inactive2Collecting
                                    )
                                    ExpandableToggle(
                                        title: "Passing",
                                        descriptionProvider: robotDescription,
                                        isOn: $inactive2Passing
                                    )
                                    ExpandableToggle(
                                        title: "Defense",
                                        descriptionProvider: robotDescription,
                                        isOn: $inactive2Defense
                                    )
                                    VStack(alignment: .leading) {
                                        Text("Other")
                                            .font(.headline)
                                            .foregroundColor(.darkGreenFont)
                                            .padding(.bottom, 4)
                                        
                                        TextEditor(text: $inactive2Other)
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
                                }
                            }
                            
                            Section(header: Text("Endgame").font(.title3).foregroundColor(.darkGreenFont)) {
                                ExpandableToggle(
                                    title: "Shooting fuel in alliance zone",
                                    descriptionProvider: robotDescription,
                                    isOn: $endgameShooting
                                )
                                ExpandableToggle(
                                    title: "Passing",
                                    descriptionProvider: robotDescription,
                                    isOn: $endgamePassing
                                )
                                ExpandableToggle(
                                    title: "Herding",
                                    descriptionProvider: robotDescription,
                                    isOn: $endgameHerding
                                )
                                ExpandableToggle(
                                    title: "Defense",
                                    descriptionProvider: robotDescription,
                                    isOn: $endgameDefense
                                )
                                ExpandableToggle(
                                    title: "Cycling",
                                    descriptionProvider: robotDescription,
                                    isOn: $endgameCycling
                                )
                                if (endgameCycling) {
                                    VStack(alignment: .leading, spacing: 16) {
                                        HStack {
                                            Text("Number of cycles:")
                                                .font(.headline)
                                                .foregroundColor(.darkGreenFont)
                                                .padding(.trailing, 8)
                                            Spacer()
                                            Picker("Number of cycles:", selection: $endgameCycles) {
                                                ForEach(0..<31) { number in
                                                    Text("\(number)").tag(number)
                                                }
                                            }
                                            .pickerStyle(WheelPickerStyle())
                                            .frame(width: 100, height: 120)
                                            .clipped()
                                            .background(Color.white.opacity(0.8))
                                            .cornerRadius(8)
                                            .foregroundColor(.darkGreenFont)
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Climbing")
                                        .font(.headline)
                                        .foregroundColor(.darkGreenFont)

                                    Picker("", selection: $climb) {
                                        Text("None").tag("None")
                                        Text("L1").tag("L1")
                                        Text("L2").tag("L2")
                                        Text("L3").tag("L3")
                                    }
                                    .pickerStyle(.segmented)
                                }
                                .padding(.vertical, 8)
                                VStack(alignment: .leading) {
                                    Text("Climb location")
                                        .font(.headline)
                                        .foregroundColor(.darkGreenFont)
                                    
                                    Text("Depot side, outpost side, center, outside rung, inside rung, etc")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                    TextEditor(text: $climbLocation)
                                        .padding()
                                        .background(Color.white.opacity(0.8))
                                        .cornerRadius(8)
                                        .foregroundColor(.darkGreenFont)
                                        .frame(height: 50)
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
                                        .padding(.bottom, 4)
                                    
                                    TextEditor(text: $endgameOther)
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
                                
                            }
                            
                            if (inactive1Defense || inactive2Defense || endgameDefense) {
                                Section(header: Text("Defense").foregroundColor(.darkGreenFont)) {
                                    Toggle("Collecting fuel from opponent alliance zone", isOn: $defenseCollectOppFuel)
                                        .foregroundColor(.darkGreenFont)
                                        .font(.headline)
                                    Toggle("Blocking opponent robots trench or bump", isOn: $defenseBlocking)
                                        .foregroundColor(.darkGreenFont)
                                        .font(.headline)
                                    Toggle("Hitting opponent robots to slow them down", isOn: $defenseHitting)
                                        .foregroundColor(.darkGreenFont)
                                        .font(.headline)
                                    Toggle("Pinning opponent robots", isOn: $defensePinning)
                                        .foregroundColor(.darkGreenFont)
                                        .font(.headline)
                                    VStack(alignment: .leading) {
                                        Text("Other")
                                            .font(.headline)
                                            .foregroundColor(.darkGreenFont)
                                            .padding(.bottom, 4)
                                        
                                        TextEditor(text: $defenseOther)
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
                                }
                            }
                            
                            Section(header: Text("Performance").font(.title3).foregroundColor(.darkGreenFont)) {
                                VStack(alignment: .leading) {
                                    Text("Driving score: \(Int(drivingScore))")
                                        .font(.headline)
                                        .foregroundColor(.darkGreenFont)
                                        .padding(.bottom, 4)
                                    
                                    Slider(value: $drivingScore, in: 0...10, step: 1)
                                        .accentColor(.greenTheme2)
                                        .padding(.bottom, 4)
                                    
                                    Text(descriptionDrivingScore(Int(drivingScore)))
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("Intake ability: \(Int(intakeAbility))")
                                        .font(.headline)
                                        .foregroundColor(.darkGreenFont)
                                        .padding(.bottom, 4)
                                    
                                    Slider(value: $intakeAbility, in: 0...5, step: 1)
                                        .accentColor(.greenTheme2)
                                        .padding(.bottom, 4)
                                    
                                    Text(descriptionIntakeAbility(Int(intakeAbility)))
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                // CHANGE THIS
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Hopper capacity: \(hopperCapacity)")
                                        .font(.headline)
                                        .foregroundColor(.darkGreenFont)

                                    Picker("", selection: $hopperCapacity) {
                                        Text("None").tag("None")
                                        Text("Small").tag("Small")
                                        Text("Medium").tag("Medium")
                                        Text("Large").tag("Large")
                                    }
                                    .pickerStyle(.segmented)
                                    
                                    Text(descriptionHopperCapacity(hopperCapacity))
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
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
                                    Text("Shooting location flexibility: \(Int(shootingLocationFlexibility))")
                                        .font(.headline)
                                        .foregroundColor(.darkGreenFont)
                                        .padding(.bottom, 4)
                                    
                                    Slider(value: $shootingLocationFlexibility, in: 0...5, step: 1)
                                        .accentColor(.greenTheme2)
                                        .padding(.bottom, 4)
                                    
                                    Text(descriptionShootingLocationFelixbility(Int(shootingLocationFlexibility)))
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("Bump vs trench preference: \(Int(bumpVsTrench))")
                                        .font(.headline)
                                        .foregroundColor(.darkGreenFont)
                                        .padding(.bottom, 4)
                                    
                                    Slider(value: $bumpVsTrench, in: 1...5, step: 1)
                                        .accentColor(.greenTheme2)
                                        .padding(.bottom, 4)
                                    
                                    Text(descriptionBumpVsTrench(Int(bumpVsTrench)))
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("Comments")
                                        .font(.headline)
                                        .foregroundColor(.darkGreenFont)
                                    
                                    Text("Driving, decision-making, defense, fouls, etc")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
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
                            dismissButton: .default(Text("Log Another Match"), action: clearFields)
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

        guard !matchNumber.isEmpty else {
            activeAlert = .error("Match Number is required.")
            return
        }

        isSubmitting = true

        var formData: [String: Any] = [
            "formType": "stand",
            "Username": username,
            // "Team number": teamNumber,
            "Team number": selectedTeamNumber,
            "Match number": matchNumber,
            "Alliance color": allianceColor,

            // Auto
            "Auto score preload": autoScorePreload,
            "Auto outpost": autoOutpost,
            "Auto depot": autoDepot,
            "Auto neutral": autoNeutral,
            "Auto passing": autoPassing,
            "Auto herding": autoHerding,
            "Auto cycling": autoCycling,
            "Auto cycles": autoCycles,
            "Auto climb": autoClimb,
            "Auto climb location": autoClimbLocation,
            "Auto other": autoOther,
            "Auto won": autoWon,

            // Teleop
            "IA1 collecting": inactive1Collecting,
            "IA1 passing": inactive1Passing,
            "IA1 herding": inactive1Herding,
            "IA1 defense": inactive1Defense,
            "IA1 other": inactive1Other,
            
            "A1 shooting": active1Shooting,
            "A1 passing": active1Passing,
            "A1 herding": active1Herding,
            "A1 cycling": active1Cycling,
            "A1 cycles": active1Cycles,
            "A1 other": active1Other,
            
            "IA2 collecting": inactive2Collecting,
            "IA2 passing": inactive2Passing,
            "IA2 herding": inactive2Herding,
            "IA2 defense": inactive2Defense,
            "IA2 other": inactive2Other,
            
            "A2 shooting": active2Shooting,
            "A2 passing": active2Passing,
            "A2 herding": active2Herding,
            "A2 cycling": active2Cycling,
            "A2 cycles": active2Cycles,
            "A2 other": active2Other,

            // Endgame
            "Endgame shooting": endgameShooting,
            "Endgame passing": endgamePassing,
            "Endgame herding": endgameHerding,
            "Endgame defense": endgameDefense,
            "Endgame cycling": endgameCycling,
            "Endgame cycles": endgameCycles,
            "Climb": climb,
            "Climbing location": climbLocation,
            "Endgame other": endgameOther,

            // Defense
            "Defense": inactive1Defense || inactive2Defense || endgameDefense,
            "Defense collect opp fuel": defenseCollectOppFuel,
            "Defense blocking": defenseBlocking,
            "Defenese hitting": defenseHitting,
            "Defense pinning": defensePinning,
            "Defense other": defenseOther,
            
            // Comments
            "Driving score": Int(drivingScore),
            "Intake ability": Int(intakeAbility),
            "Hopper capacity": hopperCapacity,
            "Shot accuracy": Int(shotAccuracy),
            "Shooting location flexibility": Int(shootingLocationFlexibility),
            "Bump vs trench": Int(bumpVsTrench),
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
        matchNumber = ""
        allianceColor = "Red"
        isSubmitting = false

        // Auto
        autoScorePreload = false
        autoOutpost = false
        autoDepot = false
        autoNeutral = false
        autoPassing = false
        autoHerding = false
        autoCycling = false
        autoCycles = 0
        autoClimb = false
        autoClimbLocation = ""
        autoOther = ""
        autoWon = true

        // Teleop
        inactive1Collecting = false
        inactive1Passing = false
        inactive1Herding = false
        inactive1Defense = false
        inactive1Other = ""
        
        active1Shooting = false
        active1Passing = false
        active1Herding = false
        active1Cycling = false
        active1Cycles = 0
        active1Other = ""
        
        inactive2Collecting = false
        inactive2Passing = false
        inactive2Herding = false
        inactive2Defense = false
        inactive2Other = ""
        
        active2Shooting = false
        active2Passing = false
        active2Herding = false
        active2Cycling = false
        active2Cycles = 0
        active2Other = ""

        // Endgame
        endgameShooting = false
        endgamePassing = false
        endgameHerding = false
        endgameDefense = false
        endgameCycling = false
        endgameCycles = 0
        climb = "None"
        climbLocation = ""
        endgameOther = ""

        // Defense
        defenseCollectOppFuel = false
        defenseBlocking = false
        defenseHitting = false
        defensePinning = false
        defenseOther = ""
        
        // Comments
        drivingScore = 0.0
        intakeAbility = 0.0
        hopperCapacity = "None"
        shotAccuracy = 0.0
        shootingLocationFlexibility = 0.0
        bumpVsTrench = 3.0
        comments = ""
    }
    
    func descriptionDrivingScore(_ score: Int) -> String {
        switch score {
        case 0: return "0 = No driving"
        case 1: return "1 = Poor driving performance"
        case 2: return "2 = Below average driving"
        case 3: return "3 = Somewhat effective driving"
        case 4: return "4 = Slightly below average performance"
        case 5: return "5 = Average driving ability"
        case 6: return "6 = Above average driving"
        case 7: return "7 = Good driving performance"
        case 8: return "8 = Very good driving skills"
        case 9: return "9 = Excellent driving performance"
        case 10: return "10 = Outstanding driving ability"
        default: return "Score out of range"
        }
    }
    
    func descriptionIntakeAbility(_ score: Int) -> String {
        switch score {
        case 0: return "0 = No intaking"
        case 1: return "1 = Intakes almost none of fuel touched"
        case 2: return "2 = Intakes half of fuel touched"
        case 3: return "3 = Intakes most of fuel touched"
        case 4: return "4 = Intakes almost all of fuel touched"
        case 5: return "5 = Intakes all fuel touched"
        default: return "Score out of range"
        }
    }
    
    func descriptionHopperCapacity (_ score: String) -> String {
        switch score {
        case "None": return "No hopper"
        case "Small": return "Hopper holds around 1 to 15 fuel"
        case "Medium": return "20 = Hopper holds around 15 to 30 fuel"
        case "Large": return "30 = Hopper holds more than 30 fuel"
        default: return "N/A"
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
    
    func descriptionShootingLocationFelixbility (_ score: Int) -> String {
        switch score {
        case 0: return "0 = No shooting"
        case 1: return "1 = Only shoots from one place"
        case 2: return "2 = Only shoots from one distance from hub"
        case 3: return "3 = Shoots stationary from around half of alliance zone"
        case 4: return "4 = Shoots stationary from anywhere in alliance zone"
        case 5: return "5 = Shoot on the move"
        default: return "Score out of range"
        }
    }
    
    func descriptionBumpVsTrench (_ score: Int) -> String {
        switch score {
        case 1: return "1 = Only goes over bump"
        case 2: return "2 = Prefers bump but uses both"
        case 3: return "3 = No preference"
        case 4: return "4 = Prefers trench but uses both"
        case 5: return "5 = Only goes under trench"
        default: return "Score out of range"
        }
    }
    
    func segment(title: String, color: Color, value: String) -> some View {
        Button {
            allianceColor = value
        } label: {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(allianceColor == value ? color : Color.clear)
                .foregroundColor(Color(.systemGray5))
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
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
    
    func robotDescription (_ score: String) -> String {
        switch score {
        case "Collecting": return "Filling up hopper with fuel from neutral or opponent alliance zone."
        case "Passing": return "Intaking fuel and shooting it into their alliance zone."
        case "Herding": return "Pushing fuel to alliance zone without intaking."
        case "Defense": return "Collecting fuel from opponent alliance zone, blocking opponents' trench or bump, hitting opponent robots to slow them down, pinning opponent robots, etc."
        case "Shooting fuel in alliance zone": return "Intaking fuel from alliance zone and shooting it into hub."
        case "Cycling": return "Intaking fuel from neutral zone, driving to alliance zone, shooting into hub, drive back to neutral zone."
        default: return "No description"
        }
    }
}
