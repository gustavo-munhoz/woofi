//
//  Data+base36EncodedString.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 25/06/24.
//

import Foundation

private let base36Alphabet = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"

extension Data {
    func base36EncodedString() -> String {
        var result = ""
        var value = self.reduce(0) { $0 << 8 | UInt64($1) }
        
        while value > 0 {
            let remainder = value % 36
            value /= 36
            result = String(base36Alphabet[String.Index(utf16Offset: Int(remainder), in: base36Alphabet)]) + result
        }
        
        return result
    }
}
