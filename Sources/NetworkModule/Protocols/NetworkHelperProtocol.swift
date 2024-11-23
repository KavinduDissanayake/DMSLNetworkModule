import Foundation
import Alamofire

// MARK: - NetworkHelperProtocol
public protocol NetworkHelperProtocol {
    func makeAPIRequest<T: Decodable>(
        url: String,
        parameters: [String: Any]?,
        method: NetworkHttpMethod,
        headers: [String: String],
        completion: @escaping (Result<T, NetworkError>) -> Void
    )
    
    func makeUploadAPIRequest<T: Decodable>(
        url: String,
        parameters: [String: Any]?,
        fileData: [UploadableData]?,
        method: NetworkHttpMethod,
        headers: [String: String],
        completion: @escaping (Result<T, NetworkError>) -> Void
    )
    
    func makeAPIRequestAsync<T: Decodable>(
        url: String,
        parameters: [String: Any]?,
        method: NetworkHttpMethod,
        headers: [String: String]
    ) async throws -> T
    
    func makeUploadAPIRequestAsync<T: Decodable>(
        url: String,
        parameters: [String: Any]?,
        fileData: [UploadableData]?,
        method: NetworkHttpMethod,
        headers: [String: String]
    ) async throws -> T
}




