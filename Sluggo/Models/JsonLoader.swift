//
//  JsonLoader.swift
//  Sluggo
//
//  Created by Andrew Gavgavian on 4/19/21.
//

import Foundation

class JsonLoader {
    static func decode<T: Codable>(data: Data) -> T? {
        // Attempt decoding
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let pagRec = try? decoder.decode(T.self, from: data) else {
            print("Failed to decode JSON data into object representation for object initialization.")
            return nil
        }
        
        return pagRec
    }
    
    static func encode<T: Codable>(object data: T) -> Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        // Attempt encoding
        guard let jsonData = try? encoder.encode(data) else {
            print("Failed to encode object into JSON data.")
            return nil
            
        }
        
        // Attempt stringifying the data, this is failable, which is fine since property is optional.
        return jsonData
    }
    
    static func executeCodableRequest<T: Codable>(request: URLRequest, completionHandler: @escaping (Result<T, Error>) -> Void) -> Void {
        
        let session = URLSession.shared
        session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if error != nil {
                completionHandler(.failure(Exception.runtimeError(message: "Server Error!")))
                return
            }
            
            let resp = response as! HTTPURLResponse
            if (resp.statusCode <= 299 && resp.statusCode >= 200) {
                if let fetchedData = data {
                    guard let record: T = JsonLoader.decode(data: fetchedData) else {
                        completionHandler(.failure(RESTException.failedRequest(message: "Failure to decode retrieved model in JsonLoader Codable Request")))
                        return;
                    }
                    completionHandler(.success(record))
                    return;
                } else {
                    completionHandler(.failure(RESTException.failedRequest(message: "Failure to decode retrieved data in JsonLoader Codable request")))
                    return;
                }
            } else {
                if let fetchedData = data {
                    completionHandler(.failure(RESTException.failedRequest(message: "HTTP Error \(resp.statusCode): \(String(data: fetchedData, encoding: .utf8) ?? "A parsing error occurred")")))
                    return;
                }
                completionHandler(.failure(RESTException.failedRequest(message: "HTTP Error \(resp.statusCode): An unknown error occured.")))
                return;
            }
        }).resume()
    }
}
