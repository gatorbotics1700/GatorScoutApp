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
    @State private var switchFieldOrientation = false

    // Auto
    @State private var autoMove = false
    @State private var autoScore = false
    @State private var autoPreload = false
    @State private var autoOutpost = false
    @State private var autoDepot = false
    @State private var autoNeutral = false
    @State private var autoCycles = 0
    @State private var autoPassing = false
    @State private var autoHerding = false
    @State private var autoFillHopper = false
    @State private var autoClimb = false

    // Offense
    @State private var offense = false
    @State private var collecting = false
    @State private var passing = false
    @State private var herding = false
    @State private var shooting = false
    let rows = 7
    let cols = 5
    @State private var shootingLocation = Array(repeating: false, count: 35)
    @State private var defensePressure = false
    @State private var defenseResponse = ""

    // Defense
    @State private var defense = false
    @State private var defenseCollectOppFuel = false
    @State private var defenseBlocking = false
    @State private var defenseHitting = false
    @State private var defensePinning = false
    @State private var defenseEfficiency = ""
    @State private var defenseFouls = ""
    
    // Performance
    @State private var drivingScore: Double = 0.0
    @State private var intakeAbility: Double = 0.0
    @State private var hopperCapacity = "None"
    @State private var shotAccuracy: Double = 0.0
    @State private var shootingLocationFlexibility: Double = 0.0
    @State private var bumpVsTrench: Double = 3.0
    @State private var endgameClimb = "None"
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
                                
                                Toggle("Field orientation", isOn: $switchFieldOrientation)
                                    .foregroundColor(.darkGreenFont)
                                    .font(.headline)
                                Image("FieldMap")
                                    .resizable()
                                    .scaledToFit()
                                    .rotationEffect(switchFieldOrientation ? .degrees(0) : .degrees(180))
                            }
                            
                            Section(header: Text("Auto").font(.title3).foregroundColor(.darkGreenFont)) {
                                Toggle("Did they move in auto?", isOn: $autoMove)
                                    .foregroundColor(.darkGreenFont)
                                    .font(.headline)
                                if (autoMove) {
                                    Toggle("Did they score in auto?", isOn: $autoScore)
                                        .foregroundColor(.darkGreenFont)
                                        .font(.headline)
                                    
                                    if (autoScore) {
                                        Toggle("Scored preload", isOn: $autoPreload)
                                            .foregroundColor(.darkGreenFont)
                                            .font(.headline)
                                        
                                        Toggle("Scored any depot fuel", isOn: $autoDepot)
                                            .foregroundColor(.darkGreenFont)
                                            .font(.headline)
                                        
                                        Toggle("Scored any outpost fuel", isOn: $autoOutpost)
                                            .foregroundColor(.darkGreenFont)
                                            .font(.headline)
                                        
                                        Toggle("Scored any neutral fuel", isOn: $autoNeutral)
                                            .foregroundColor(.darkGreenFont)
                                            .font(.headline)
                                        
                                        if (autoNeutral) {
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
                                    }
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
                                    Toggle("Filled hopper", isOn: $autoFillHopper)
                                        .foregroundColor(.darkGreenFont)
                                        .font(.headline)
                                    Toggle("Auto climb", isOn: $autoClimb)
                                        .foregroundColor(.darkGreenFont)
                                        .font(.headline)
                                }
                            }
                            
                            Section(header: Text("Offense").font(.title3).foregroundColor(.darkGreenFont)) {
                                Toggle("Did they play offense?", isOn: $offense)
                                    .foregroundColor(.darkGreenFont)
                                    .font(.headline)
                                
                                if(offense) {
                                    ExpandableToggle(
                                        title: "Collecting",
                                        descriptionProvider: robotDescription,
                                        isOn: $collecting
                                    )
                                    ExpandableToggle(
                                        title: "Passing",
                                        descriptionProvider: robotDescription,
                                        isOn: $passing
                                    )
                                    ExpandableToggle(
                                        title: "Herding",
                                        descriptionProvider: robotDescription,
                                        isOn: $herding
                                    )
                                    
                                    ExpandableToggle(
                                        title: "Shooting fuel in alliance zone",
                                        descriptionProvider: robotDescription,
                                        isOn: $shooting
                                    )
                                    
                                    Text("From where did they shoot?")
                                        .font(.headline)
                                        .foregroundColor(.darkGreenFont)
                                    
                                    GeometryReader { geo in
                                        
                                        ZStack {
                                            if allianceColor == "Blue" {
                                                Image("BlueAlliance")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .rotationEffect(.degrees(switchFieldOrientation ? 0 : 180))
                                                    .frame(width: geo.size.width, height: geo.size.height)
                                            } else {
                                                Image("RedAlliance")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .rotationEffect(.degrees(switchFieldOrientation ? 0 : 180))
                                                    .frame(width: geo.size.width, height: geo.size.height)
                                            }

                                            VStack(spacing: 0) {
                                                ForEach(0..<rows, id: \.self) { i in
                                                    HStack(spacing: 0) {
                                                        ForEach(0..<cols, id: \.self) { j in
                                                            let shouldFlip = switchFieldOrientation != (allianceColor == "Blue")
                                                            let mappedRow = shouldFlip ? (rows - 1 - i) : i
                                                            let mappedCol = shouldFlip ? (cols - 1 - j) : j
                                                            let index = mappedRow * cols + mappedCol

                                                            Rectangle()
                                                                .fill(shootingLocation[index] ? Color.green.opacity(0.4) : Color.clear)
                                                                .border(Color.white.opacity(0.5))
                                                                .contentShape(Rectangle())
                                                                .onTapGesture {
                                                                    shootingLocation[index].toggle()
                                                                }
                                                        }
                                                    }
                                                }
                                            }
                                            .frame(width: geo.size.width, height: geo.size.height)
                                        }
                                        .frame(width: geo.size.width, height: geo.size.height)
                                    }
                                    .frame(height: 470)
                                    
                                    Toggle("Were they under defense pressure?", isOn: $defensePressure)
                                        .foregroundColor(.darkGreenFont)
                                        .font(.headline)
                                    if (defensePressure) {
                                        VStack(alignment: .leading) {
                                            Text("How did they respond to defense?")
                                                .font(.headline)
                                                .foregroundColor(.darkGreenFont)
                                                .padding(.bottom, 4)
                                            
                                            TextEditor(text: $defenseResponse)
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
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Endgame climb: \(endgameClimb)")
                                            .font(.headline)
                                            .foregroundColor(.darkGreenFont)

                                        Picker("", selection: $endgameClimb) {
                                            Text("None").tag("None")
                                            Text("L1").tag("L1")
                                            Text("L2").tag("L2")
                                            Text("L3").tag("L3")
                                        }
                                        .pickerStyle(.segmented)
                                    }
                                }
                            }
                            
                            Section(header: Text("Defense").font(.title3).foregroundColor(.darkGreenFont)) {
                                Toggle("Did they play defense?", isOn: $defense)
                                    .foregroundColor(.darkGreenFont)
                                    .font(.headline)
                                
                                if (defense) {
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
                                        Text("Who did they defend? How effective was it?")
                                            .font(.headline)
                                            .foregroundColor(.darkGreenFont)
                                            .padding(.bottom, 4)
                                        
                                        TextEditor(text: $defenseEfficiency)
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
                                    VStack(alignment: .leading) {
                                        Text("Did they get fouls? What for?")
                                            .font(.headline)
                                            .foregroundColor(.darkGreenFont)
                                            .padding(.bottom, 4)
                                        
                                        TextEditor(text: $defenseFouls)
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
                                    Text("Comments (Required)")
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
        
        guard !comments.isEmpty else {
            activeAlert = .error("Comments are required.")
            return
        }

        isSubmitting = true
        
        /*
         // Performance
         @State private var drivingScore: Double = 0.0
         @State private var intakeAbility: Double = 0.0
         @State private var hopperCapacity = "None"
         @State private var shotAccuracy: Double = 0.0
         @State private var shootingLocationFlexibility: Double = 0.0
         @State private var bumpVsTrench: Double = 3.0
         @State private var endgameClimb = "None"
         @State private var comments = ""
         */

        var formData: [String: Any] = [
            "formType": "stand",
            "Username": username,
            // "Team number": teamNumber,
            "Team number": selectedTeamNumber,
            "Match number": matchNumber,
            "Alliance color": allianceColor,
            
            // Performance
            "Driving score": Int(drivingScore),
            "Intake ability": Int(intakeAbility),
            "Hopper capacity": hopperCapacity,
            "Shot accuracy": Int(shotAccuracy),
            "Shooting location flexibility": Int(shootingLocationFlexibility),
            "Bump vs trench": Int(bumpVsTrench),
            "Comments": comments,

            // Auto
            "Auto move": autoMove,
            "Auto score": autoScore,
            "Auto preload": autoPreload,
            "Auto depot": autoDepot,
            "Auto outpost": autoOutpost,
            "Auto neutral": autoNeutral,
            "Auto cycles": autoCycles,
            "Auto passing": autoPassing,
            "Auto herding": autoHerding,
            "Auto fill hopper": autoFillHopper,
            "Auto climb": autoClimb,

            // Offense
            "Offense": offense,
            "Collecting": collecting,
            "Passing": passing,
            "Herding": herding,
            "Shooting": shooting,
            "Shooting location": shootingLocation.enumerated()
                .filter { $0.element }
                .map { String($0.offset) }
                .joined(separator: ", "),
            "Defense pressure": defensePressure,
            "Defense response": defenseResponse,
            "Endgame climb": endgameClimb,

            // Defense
            "Defense": defense,
            "Defense collect opp fuel": defenseCollectOppFuel,
            "Defense blocking": defenseBlocking,
            "Defenese hitting": defenseHitting,
            "Defense pinning": defensePinning,
            "Defense efficiency": defenseEfficiency,
            "Defense fouls": defenseFouls
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

        // Auto
        autoMove = false
        autoScore = false
        autoPreload = false
        autoOutpost = false
        autoDepot = false
        autoNeutral = false
        autoCycles = 0
        autoPassing = false
        autoHerding = false
        autoFillHopper = false
        autoClimb = false

        // Offense
        offense = false
        collecting = false
        passing = false
        herding = false
        shooting = false
        shootingLocation = Array(repeating: false, count: rows*cols)
        defensePressure = false
        defenseResponse = ""

        // Defense
        defense = false
        defenseCollectOppFuel = false
        defenseBlocking = false
        defenseHitting = false
        defensePinning = false
        defenseEfficiency = ""
        defenseFouls = ""
        
        // Performance
        drivingScore = 0.0
        intakeAbility = 0.0
        hopperCapacity = "None"
        shotAccuracy = 0.0
        shootingLocationFlexibility = 0.0
        bumpVsTrench = 3.0
        endgameClimb = "None"
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
