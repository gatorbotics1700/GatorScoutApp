//
//  FRCTeamsAPI.swift
//  GatorScout
//
//  Created by Ayda Gokturk on 3/25/25.
//

import Foundation

struct Team: Identifiable, Codable {
    var id: Int { teamNumber }
    let teamNumber: Int
}

class TeamsViewModel: ObservableObject {
    @Published var teams: [Team] = []

    func fetchTeams() {
        guard let url = URL(string: "https://frc-api.firstinspires.org/v3.0/2026/teams?eventCode=CASNV") else { return } // Silicon Valley: CASNV, East Bay: CAETB, NorCal: CANCMP
        var request = URLRequest(url: url)
        let username = "gatorbotics1700" // API token needs to be updated once every 3 years, current from 2/27/26
        let password = "ba7908be-3845-40b8-b862-8959e2357085"
        let loginString = "\(username):\(password)"
        let loginData = loginString.data(using: .utf8)!
        let base64LoginString = loginData.base64EncodedString()
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode(FRCTeamsResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.teams = decoded.teams
                        print("Fetched teams: \(self.teams)")
                    }
                } catch {
                    print("Error decoding: \(error)")
                }
            }
        }.resume()
    }
}

struct FRCTeamsResponse: Codable {
    let teams: [Team]
}

