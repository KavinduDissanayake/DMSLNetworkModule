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

enum ErrorsContainer: Codable {
    case dictionary(UnifiedError)  // Now using UnifiedError
    case array([UnifiedError])     // Array of UnifiedError
    case none

    // Custom decoding to support both array and dictionary
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        // First try decoding as UnifiedError (dictionary)
        if let dictionary = try? container.decode(UnifiedError.self) {
            self = .dictionary(dictionary)
        }
        // Then try decoding as an array of UnifiedError
        else if let array = try? container.decode([UnifiedError].self) {
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

struct UnifiedError: Codable {
    let code: String?
    let correlationID: String?
    let developerMessage: String?
    let message: String?

    // Unified initializer
    public init(
        code: String? = nil,
        correlationID: String? = nil,
        developerMessage: String? = nil,
        message: String? = nil
    ) {
        self.code = code
        self.correlationID = correlationID
        self.developerMessage = developerMessage
        self.message = message
    }

    enum CodingKeys: String, CodingKey {
        case code
        case correlationID = "correlationId"
        case developerMessage, message
    }
}

struct Fields: Codable {
    public var number: String?
}
