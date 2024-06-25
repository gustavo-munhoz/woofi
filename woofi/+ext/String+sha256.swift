//
//  String+sha256.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 25/06/24.
//

import Foundation
import CryptoKit

extension String {
    func sha256() -> Data {
        let inputData = Data(self.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return Data(hashedData)
    }
}
