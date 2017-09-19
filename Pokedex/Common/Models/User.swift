//
//  User.swift
//  Pokedex
//
//  Created by Infinum Student Academy on 20/07/2017.
//  Copyright © 2017 Dinko Gregorić. All rights reserved.
//

import Foundation
import UIKit
import CodableAlamofire

struct UserRegistered: Codable {
    
    private struct RegisterAttributes: Codable {
        let email: String
        let username: String
        let authToken: String
        
        enum CodingKeys: String, CodingKey {
            case email = "email"
            case username = "username"
            case authToken = "auth-token"
        }
    }
    
    private struct RegisterUserData: Codable {
        let id: String
        //let type: String
        let attributes: RegisterAttributes
    }
    
    init(id: String, email: String, username: String, authT: String) {
        let attributes = RegisterAttributes(email: email, username: username, authToken: authT)
        self.data = RegisterUserData(id: id, attributes: attributes)
    }
    
    // MARK: - JSON properties -
    private let data: RegisterUserData
    
    // MARK: - Helpers -
    var id: String { return data.id }
    var email: String  { return data.attributes.email }
    var username: String  { return data.attributes.username }
    var authToken: String  { return data.attributes.authToken }
}

struct UserToRegister: Codable {
    
    private struct DataAttributes: Codable {
        let username: String!
        let email: String!
        let password: String!
        let conPassword: String!
        
        enum CodingKeys: String, CodingKey {
            case username = "username"
            case email = "email"
            case password = "password"
            case conPassword = "password_confirmation"
        }
    }
    
    private struct UserData: Codable {
        let type: String
        let attributes: DataAttributes
        
        enum HigherCodingKeys: String, CodingKey{
            case attributes = "attributes"
        }
    }
    init(username: String, email: String, password: String, confirmedPassword: String) {
        let attributes = DataAttributes(username: username, email: email, password: password, conPassword: confirmedPassword)
        self.data = UserData(type: "users", attributes: attributes)
        
    }
    // MARK: - JSON properties -
    private let data: UserData
    
    // MARK: - Helpers -
    var email: String  { return data.attributes.email }
    var username: String  { return data.attributes.username }
    
    func testEncoding() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let encodedData = try! encoder.encode(self)
        return String(data: encodedData, encoding: .utf8)
    }
    
    public func asDictionary() -> [String: Any]? {
        let encodedData = self.testEncoding()
        guard let text = encodedData else { return nil}
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
}

struct UserToLogIn: Codable {
    
    private struct DataAttributes: Codable {
        
        let email: String
        let password: String
        
        
        enum CodingKeys: String, CodingKey {
            
            case email
            case password
            
        }
    }
    
    private struct UserData: Codable {
        let type: String
        let attributes: DataAttributes
    }
    init(email: String, password: String) {
        let attributes = DataAttributes(email: email, password: password)
        self.data = UserData(type: "session", attributes: attributes)
        
    }
    // MARK: - JSON properties -
    private let data: UserData
    
    // MARK: - Helpers -
    var email: String  { return data.attributes.email }
    
    func testEncoding() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let encodedData = try! encoder.encode(self)
        return String(data: encodedData, encoding: .utf8)
    }
    
    public func asDictionary() -> [String: Any]? {
        let encodedData = self.testEncoding()
        guard let text = encodedData else { return nil}
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
}

struct Pokemon: Codable {
    let id: String
    let type: String
    
    struct PokeAttributes: Codable {
        let name: String
        let imageURL: String?
        let height: Float
        let weight: Float
        let description: String?
        let gender: String
        let createdAt : String
        let totalVote : Int
        
        enum CodingKeys: String, CodingKey {
            case imageURL = "image-url"
            case name
            case description
            case height
            case weight
            case gender
            case createdAt = "created-at"
            case totalVote = "total-vote-count"
        }
    }
    
    let attributes: PokeAttributes
}

struct Comment: Codable {
    
    struct CommentAttributes: Codable {
        let content: String
        
        enum CodingKeys: String, CodingKey {
            case content
        }
    }
    
     struct RelationshipAttributes: Codable {
        let author: AuthorAttributes
        
        enum CodingKeys: String, CodingKey {
            case author
        }
        
        struct AuthorAttributes: Codable {
            let data: DataAttributes
            
            enum CodingKeys: String, CodingKey {
                case data
            }
            struct DataAttributes: Codable {
                let id: String
                
                enum CodingKeys: String, CodingKey {
                    case id
                }
            }
            
        }
        var userID: String  { return  author.data.id}
    }
    
     struct CommentData: Codable {
        let attributes: CommentAttributes
        let relationships: RelationshipAttributes
        
        enum CodingKeys: String, CodingKey {
            case attributes
            case relationships
        }
        
        var content: String  { return attributes.content }
        var userID: String { return relationships.userID }
    
    }
    
    struct IncludedData: Codable {
        let id: String
        let attributes: IncludedAttributes
        
        struct IncludedAttributes: Codable {
            let username: String
            
            enum CodingKeys: String, CodingKey {
                case username
            }
        
        }
        var name: String  { return  attributes.username}
    }
    
    // MARK: - JSON properties -
    let data: [CommentData]?
    let included: [IncludedData]?
    
}

struct SendComment: Codable {
    let data: DataAttributes
    
    struct DataAttributes: Codable {
        let attributes: ContentAttributes
        
        enum CodingKeys: String, CodingKey {
            case attributes
        }
    }
    
    struct ContentAttributes: Codable {
        let content: String
        
        enum CodingKeys: String, CodingKey {
            case content
        }
    }
    
    init(content: String) {
        let attributes = ContentAttributes(content: content)
        self.data = DataAttributes(attributes: attributes)
        
    }
    
    func testEncoding() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let encodedData = try! encoder.encode(self)
        return String(data: encodedData, encoding: .utf8)
    }
    
    public func asDictionary() -> [String: Any]? {
        let encodedData = self.testEncoding()
        guard let text = encodedData else { return nil}
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}



