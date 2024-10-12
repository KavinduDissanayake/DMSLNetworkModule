//
//  NetworkManager.swift
//  DMSLNetworkModule
//
//  Created by Kavindu Dissanayake on 2024-10-09.
//
//
//import Alamofire
//import Foundation
//
//public class NetworkManager {
//    public static let shared = NetworkManager()  // Singleton instance
//
//    private init() {}
//
//    /// Generic method to handle API requests using Alamofire with async/await
//    /// - Parameters:
//    ///   - url: The URL of the API endpoint
//    ///   - method: The HTTP method to use (GET, POST, etc.)
//    ///   - parameters: Optional request parameters
//    /// - Throws: A `NetworkError` if the request fails or decoding fails.
//    /// - Returns: The decoded response of type `T`.
//    public func request<T: Decodable>(
//        url: String,
//        method: HTTPMethod = .get,
//        parameters: [String: Any]? = nil
//    ) async throws -> T {
//        
//        guard let validURL = URL(string: url) else {
//            throw NetworkError.invalidURL
//        }
//
//        return try await withCheckedThrowingContinuation { continuation in
//            AF.request(validURL, method: method, parameters: parameters)
//                .validate()
//                .responseDecodable(of: T.self) { response in
//                    switch response.result {
//                    case .success(let data):
//                        continuation.resume(returning: data)
//                    case .failure(let error):
//                        if let afError = error.asAFError, let statusCode = response.response?.statusCode {
//                            switch statusCode {
//                            case 401:
//                                continuation.resume(throwing: NetworkError.unauthorized)
//                            default:
//                                continuation.resume(throwing: NetworkError.requestFailed)
//                            }
//                        } else if error.isResponseSerializationError {
//                            continuation.resume(throwing: NetworkError.decodingError)
//                        } else {
//                            continuation.resume(throwing: NetworkError.unknown(error))
//                        }
//                    }
//                }
//        }
//    }
//}
