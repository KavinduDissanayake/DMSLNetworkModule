//
//  NetworkManager.swift
//  DMSLNetworkModule
//
//  Created by Kavindu Dissanayake on 2024-10-09.
//

import Alamofire
import Foundation

// Singleton Network Manager for reusable network logic
public class NetworkManager {

    public static let shared = NetworkManager()  // Singleton instance

    private init() {}

    /// Generic method to handle API requests using Alamofire
    /// - Parameters:
    ///   - url: The URL of the API endpoint
    ///   - method: The HTTP method to use (GET, POST, etc.)
    ///   - parameters: Optional request parameters
    ///   - completion: A completion handler returning a result with either decoded data or an error
    public func request<T: Decodable>(
        url: String,
        method: HTTPMethod = .get,
        parameters: [String: Any]? = nil,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        guard let validURL = URL(string: url) else {
            completion(.failure(.invalidURL))
            return
        }

        AF.request(validURL, method: method, parameters: parameters)
            .validate() // Checks that status code is in 200-299 range
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    if let afError = error.asAFError, let statusCode = response.response?.statusCode {
                        switch statusCode {
                        case 401:
                            completion(.failure(.unauthorized))
                        default:
                            completion(.failure(.requestFailed))
                        }
                    } else if error.isResponseSerializationError {
                        completion(.failure(.decodingError))
                    } else {
                        completion(.failure(.unknown(error)))
                    }
                }
            }
    }
}
