import KeePassSupport
import CommonCrypto
import AEXML

let file = Bundle.main.url(forResource: "Test", withExtension: "kdbx")
let data = Data(contentsOf: file!)

let cryptoHandler = KDBXCryptoHandler(withBytes: [UInt8](data), password: "password")
let payload = cryptoHandler?.payload

let xml = AEXMLDocument(xml: payload!)
let root = xml.root["Meta"]["Generator"]

class KDBXDatabase {
  
  private var dateFormatter: DateFormatter
  
  var generator: String
  var name: String
  var description: String
  
  var recycleBinEnabled: Bool = false
  
  var dateOfNameChange: Date = Date()
  var dateOfUsernameChange: Date = Date()
  var dateOfMasterKeyChange: Date = Date()
  var dateOfRecycleBinChange: Date = Date()
  
  var groups = [Group]()
  
  init(withXML xml: AEXMLDocument) {
    let now = Date()
    dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YYYY-MM-DD'T'HH:mm:ssZ"
    
    let meta = xml.root["Meta"]
    
    generator = meta["Generator"].value ?? "KeePass for iOS"
    name = meta["DatabaseName"].value ?? ""
    description = meta["DatabaseDescription"].value ?? ""
    
    if let binEnabledBool = meta["RecycleBinEnabled"].value {
      recycleBinEnabled = Bool(binEnabledBool) ?? recycleBinEnabled
    }
    
    if let nameChangeString = meta["DatabaseNameChanged"].value {
      dateOfNameChange = dateFormatter.date(from: nameChangeString) ?? dateOfNameChange
    }
    if let usernameChangeString = meta["DefaultUserNameChanged"].value {
      dateOfUsernameChange = dateFormatter.date(from: usernameChangeString) ?? dateOfUsernameChange
    }
    if let masterKeyChangeString = meta["MasterKeyChanged"].value {
      dateOfMasterKeyChange = dateFormatter.date(from: masterKeyChangeString) ?? dateOfMasterKeyChange
    }
    if let recycleBinChangeString = meta["RecycleBinChanged"].value {
      dateOfRecycleBinChange = dateFormatter.date(from: recycleBinChangeString) ?? dateOfRecycleBinChange
    }
  }
}

class KDBXGroup {
  let uuid: String
  let name: String
  let website: String
  let iconID: UInt8

  let notes: String

  init(withXML xml: AEXMLElement) {
    // Loads only basic information
    uuid = xml["UUID"].value ?? UUID().uuidString
    name = xml["Name"].value ?? ""
    website = xml["Website"].value ?? ""
    iconID = xml["IconID"].value ?? ""
  }

  func initDetails() {

  }
}
let database = KDBXDatabase(withXML: xml)
