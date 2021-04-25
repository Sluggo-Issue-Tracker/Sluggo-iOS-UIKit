//
//  AppIdentity.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/20/21.
//

import Foundation

struct AppIdentity: Codable {
    var authenticatedUser: UserRecord?
    var team: TeamRecord?
    var token: String?
    
    init() {
        print(AppIdentity.persistencePath)
    }
    
    private static var persistencePath: URL {
        get {
            return URL(string: NSHomeDirectory() + Constants.FilePaths.persistencePath)!
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
            return false
        }
        
        guard let appIdentityContents = String(data: appIdentityData, encoding: .utf8) else {
            return false
        }
        
        do {
            try appIdentityContents.write(to: AppIdentity.persistencePath, atomically: false, encoding: .utf8)
            return true
        } catch {
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
