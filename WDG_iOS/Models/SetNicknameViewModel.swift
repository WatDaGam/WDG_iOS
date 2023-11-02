//
//  SetNicknameViewModel.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 10/31/23.
//

import Foundation

class SetNicknameViewModel: ObservableObject {
    func checkNickname(nickname: String) -> Bool {
        // 닉네임 길이 검사
        if nickname.count < 2 {
            return false
        }
        // 영어 알파벳, 한국어 문자, 숫자만 허용하는 정규 표현식
        let pattern = "^[a-zA-Z0-9가-힣]+$"
        // 정규 표현식 검사
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: nickname.utf16.count)
        // 정규 표현식에 일치하는지 검사
        if let match = regex?.firstMatch(in: nickname, options: [], range: range), match.range == range {
            return true
            // 백엔드로 중복 검사 체크
        } else {
            return false
        }
    }
    func setNickname(nickname: String) -> Bool {
        // 백엔드로 닉네임 설정한다고 요청
        return true
    }
}
