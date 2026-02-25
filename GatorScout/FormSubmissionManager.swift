//
//  FormSubmissionManager.swift
//  GatorScout
//
//  Created by Ayda Gokturk on 2/26/25.
//


import Foundation

class FormSubmissionManager: ObservableObject {
    static let shared = FormSubmissionManager()
    @Published var savedForms: [[String: Any]] = []

    private init() {
        loadSavedForms()
    }
    
    func submitData(_ formData: [String: Any], completion: @escaping (Bool) -> Void) {
        sendDataToServer(formData) { success in
            if success {
                completion(true)
            } else {
                self.saveFormDataLocally(formData)
                completion(false)
            }
        }
    }

    private func sendDataToServer(_ formData: [String: Any], completion: @escaping (Bool) -> Void) {
        let endpointURL = URL(string: "https://script.google.com/macros/s/AKfycbzcT7yi0KGLhhFpX001iP8tKdWlOVaoXjpKIrW5Wd3ezajX3SB5CevzO6fq4_v-XREW/exec")!
        var request = URLRequest(url: endpointURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: formData, options: [])
        } catch {
            print("Error encoding data: \(error)")
            completion(false)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Network error:", error.localizedDescription)
                    completion(false)
                    return
                }

                guard let http = response as? HTTPURLResponse else {
                    print("No HTTP response")
                    completion(false)
                    return
                }

                // Helpful debug:
                if let data = data, let body = String(data: data, encoding: .utf8) {
                    print("Server status:", http.statusCode, "body:", body)
                } else {
                    print("Server status:", http.statusCode)
                }

                completion(http.statusCode == 200)
            }
        }.resume()
    }

    private func saveFormDataLocally(_ formData: [String: Any]) {
        loadSavedForms()
        savedForms.append(formData)
        UserDefaults.standard.set(savedForms, forKey: "savedForms")
        print("Saved locally. Queue size: \(savedForms.count)")
    }

    private func loadSavedForms() {
        if let savedForms = UserDefaults.standard.array(forKey: "savedForms") as? [[String: Any]] {
            self.savedForms = savedForms
        }
    }

    func resubmitSavedForms() {
        loadSavedForms()
        guard NetworkMonitor.shared.isConnected else { return }

        guard !savedForms.isEmpty else {
            print("No saved forms to resubmit.")
            return
        }

        print("Attempting to resubmit \(savedForms.count) saved forms...")
        resubmitNext()
    }

    private func resubmitNext() {
        guard NetworkMonitor.shared.isConnected else {
            print("Went offline again. Stopping resubmission.")
            return
        }
        
        loadSavedForms()
        guard !savedForms.isEmpty else {
            print("All saved forms resubmitted!")
            return
        }

        let formData = savedForms.first!

        sendDataToServer(formData) { success in
            if success {
                self.savedForms.removeFirst()
                UserDefaults.standard.set(self.savedForms, forKey: "savedForms")
                print("Resubmitted one form. Remaining: \(self.savedForms.count)")
                self.resubmitNext()
            } else {
                print("Resubmit failed. Keeping forms saved locally.")
            }
        }
    }

}
