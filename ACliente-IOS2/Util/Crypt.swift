//
//  Crypt.swift
//  ACliente-IOS2
//
//  Created by adrian aguilar on 15/10/18.
//  Copyright © 2018 altura s.a. All rights reserved.
//

import Foundation
import CryptoSwift

extension String {
    
    func aesEncrypt(key: String, iv: String) throws -> String {
        do{
            let data = self.data(using: .utf8)!
            let encrypted = try AES(key: key.bytes, blockMode: CBC(iv: iv.bytes), padding: .pkcs7).encrypt([UInt8](data))
            let encryptedData = Data(encrypted)
            return encryptedData.base64EncodedString()
        }catch{
            return ""
        }
    }
    
    func aesDecrypt(key: String, iv: String) throws -> String {
        do{
            let data = Data(base64Encoded: self)!
            let decrypted = try AES(key: key.bytes, blockMode: CBC(iv: iv.bytes), padding: .pkcs7).decrypt([UInt8](data))
            let decryptedData = Data(decrypted)
            return String(bytes: decryptedData.bytes, encoding: .utf8) ?? "Error"
        }catch{
            return ""
        }
    }
    
    func urlEncode() -> CFString {
        return CFURLCreateStringByAddingPercentEscapes(
            nil,
            self as CFString,
            nil,
            "!*'();:@&=+$,/?%#[]" as CFString,
            CFStringBuiltInEncodings.UTF8.rawValue
        )
    }
    
    
}

