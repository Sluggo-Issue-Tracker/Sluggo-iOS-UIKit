//
//  AppIdentity.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/20/21.
//

import Foundation

class AppIdentity: Codable {
    var authenticatedUser: UserRecord?
    var team: TeamRecord?
    var token: String?
    var instanceURLString: String? {
        get {
            return self.configData[Constants.Config.kURL]
        }
        
        set(newURLString) {
            self.configData[Constants.Config.kURL] = newURLString
        }
    }
    
    var configData: [String: String] = [
        Constants.Config.kURL: Constants.Config.URL_BASE // enable change if need be
    ]
    
    init() {
        print(AppIdentity.persistencePath)
    }
    
    private static var persistencePath: URL {
        get {
            return URL(fileURLWithPath: NSHomeDirectory().appending("/Library/appdata.json"))
        }
    }
    
    static func loadFromDisk() -> AppIdentity? {
        guard let persistenceFileContents = try? String(contentsOf: persistencePath) else {
            return nil
        }
        
        guard let persistenceFileData = persistenceFileContents.data(using: .utf8) else {
            return nil
        }
        
        let appIdentity: AppIdentity? = JsonLoader.decode(persistenceFileData)
        return appIdentity
    }
    
    func saveToDisk() -> Bool {
        guard let appIdentityData = JsonLoader.encode(self) else {
            print("Failed to encode app identity with JSON, could not persist")
            return false
        }
        
        guard let appIdentityContents = String(data: appIdentityData, encoding: .utf8) else {
            print("Failed to encode app identity encoded data as string, could not persist")
            return false
        }
        
        do {
            try appIdentityContents.write(to: AppIdentity.persistencePath, atomically: false, encoding: .utf8)
            return true
        } catch {
            print("Could not write persistence file to disk, could not persist")
            return false
        }
    }
    
    static func deletePersistenceFile() -> Bool {
        do {
            try FileManager.default.removeItem(at: self.persistencePath)
            return true
        } catch {
            return false
        }
    }
    
    
}
