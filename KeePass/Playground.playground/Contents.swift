import KeePassSupport
import CommonCrypto

let number: UInt32 = 290
let array = number.toBytes()
print(array)

//let key = [UInt8](repeating: 0x01, count: 32)
//let iv = [UInt8](repeating: 0x00, count: 16)
//let key = "00000000000000000000000000000000"
//let iv = "0000000000000000"
//let string_to_encrypt = "Hello World!"
//
//let encryptContext = AES(operation: .Encrypt,
//                         padding: true,
//                         key: key,
//                         iv: iv)
//
//let decryptCcontext = AES(operation: .Decrypt,
//                          padding: true,
//                          key: key,
//                          iv: iv)
//
//let encrypted = encryptContext?.performOperation([UInt8](string_to_encrypt.utf8))
//let decrypted = decryptCcontext?.performOperation(encrypted!)
//
//let decryptedString = String(bytes: decrypted!, encoding: .utf8)
