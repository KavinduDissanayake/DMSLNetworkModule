//
//  CommonError.swift
//  DMSLNetworkModule
//
//  Created by Kavindu Dissanayake on 2024-10-12.
//

struct CommonError: Codable {
    let errors: ErrorsContainer?

    enum CodingKeys: String, CodingKey {
        case errors
    }

    // Manual initializer
    public init(errors: ErrorsContainer?) {
        self.errors = errors
    }

    // Custom decoder for CommonError
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Decode the errors field using ErrorsContainer enum
        self.errors = try? container.decode(ErrorsContainer.self, forKey: .errors)
    }
}

public enum ErrorsContainer: Codable {
    case dictionary(ErrorsV2)
    case array([ErrorV3])
    case none

    // Custom decoding to support both array and dictionary
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        // First try decoding as ErrorsV2 (dictionary)
        if let dictionary = try? container.decode(ErrorsV2.self) {
            self = .dictionary(dictionary)
        }
        // Then try decoding as an array of ErrorV3
        else if let array = try? container.decode([ErrorV3].self) {
            self = .array(array)
        } else {
            // If both decoding attempts fail, set it to .none
            self = .none
        }
    }

    // Custom encoding to handle both array and dictionary
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .dictionary(let dictionary):
            try container.encode(dictionary)
        case .array(let array):
            try container.encode(array)
        case .none:
            try container.encodeNil()
        }
    }
}

public struct ErrorV3: Codable {
    let code: String?
    let correlationID, developerMessage, message: String?
    
    enum CodingKeys: String, CodingKey {
        case code
        case correlationID = "correlationId"
        case developerMessage, message
    }
}

public struct Fields: Codable {
    public var number: String?
}

public struct ErrorsV2: Codable {
    
    public init(code: Int? = nil, message: String? = nil) {
        self.code = code
        self.message = message
    }
    
    public var code: Int?
    public var message: String?
}

