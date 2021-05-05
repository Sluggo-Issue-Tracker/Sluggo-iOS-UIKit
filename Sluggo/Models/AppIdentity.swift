//
//  AppIdentity.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/20/21.
//

import Foundation

class AppIdentity: Codable {
    
    private var _authenticatedUser: UserRecord?
    private var _team: TeamRecord?
    private var _token: String?
    private var _pageSize = 10
    private var _baseAddress: String = Constants.Config.URL_BASE
    private var persist: Bool = false
    
    // MARK: Computed Properties
    var authenticatedUser: UserRecord? {
        set(newUser) {
            _authenticatedUser = newUser
            enqueueSave()
        }
        get {
            return _authenticatedUser
        }
    }
    var team: TeamRecord? {
        set(newTeam) {
            _team = newTeam
            enqueueSave()
        }
        get {
            return _team
        }
    }
    var token: String? {
        set (newToken) {
            _token = newToken
            enqueueSave()
        }
        get {
            return _token
        }
    }
    var pageSize: Int {
        set(newPageSize) {
            _pageSize = newPageSize
            enqueueSave()
        }
        get {
            return _pageSize
        }
    }
    var baseAddress: String {
        set(newBaseAddress) {
            _baseAddress = newBaseAddress
            enqueueSave()
        }
        get {
            return _baseAddress
        }
    }
    
    private static var persistencePath: URL {
        get {
            let path = URL(fileURLWithPath: NSHomeDirectory().appending("/Library/appdata.json"))
            print(path)
            return path
        }
    }
    
    public func setPersistData(persist: Bool) {
        self.persist = persist
        if persist {
            enqueueSave()
        } else {
            let _ = AppIdentity.deletePersistenceFile()
        }
    }
    
    private func enqueueSave() {
        if self.persist {
            DispatchQueue.global().async {
                let _ = self.saveToDisk()
            }
        }
    }
    
    static func loadFromDisk() -> AppIdentity? {
        guard let persistenceFileContents = try? String(contentsOf: persistencePath) else {
            return nil
        }
        
        guard let persistenceFileData = persistenceFileContents.data(using: .utf8) else {
            // File exists but was corrupted, so clean it up
            let _ = deletePersistenceFile()
            return nil
        }
        
        let appIdentity: AppIdentity? = JsonLoader.decode(data: persistenceFileData)
        if(appIdentity == nil) {
            // File exists, but failed to deserialize, so clean it up
            let _ = deletePersistenceFile()
        }
        
        return appIdentity
    }
    
    func saveToDisk() -> Bool {
        guard let appIdentityData = JsonLoader.encode(object: self) else {
            print("Failed to encode app identity with JSON, could not persist")
            return false
        }
        
        guard let appIdentityContents = String(data: appIdentityData, encoding: .utf8) else {
            print("Failed to encode app identity encoded data as string, could not persist")
            return false
        }
        
        do {
            try appIdentityContents.write(to: AppIdentity.persistencePath, atomically: true, encoding: .utf8)
            return true
        } catch {
            print("Could not write persistence file to disk, could not persist")
            return false
        }
    }
    
    static func deletePersistenceFile() -> Bool {
        // Succeed if the persistence file doesn't exist. This allows us to clean up a bad file.
        if !(FileManager.default.fileExists(atPath: self.persistencePath.path)) {
            print("Attempted to delete persistence file when it doesn't exist, returning")
            return true
        }
        
        do {
            try FileManager.default.removeItem(at: self.persistencePath)
            return true
        } catch {
            print("FAILED TO CLEAN UP PERSISTENCE FILE")
            return false
        }
    }
}
