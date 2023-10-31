//
//  SetNicknameViewModel.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 10/31/23.
//

import Foundation

class SetNicknameViewModel: ObservableObject {
    func validateNickname(nickname: String) async {
        guard let url = URL(string: "https://yourserver.com/validate-nickname") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let requestBody = ["nickname": nickname]
        
        do {
            let requestData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = requestData
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(NicknameValidationResponse.self, from: data)
            
            DispatchQueue.main.async {
                self.isValid = response.isValid
            }
        } catch {
            print("Error validating nickname: \(error)")
        }
    }
}
