import Foundation
import Alamofire

    
// MARK: - NetworkHelperProtocol
/// A protocol defining the responsibilities of a network manager.
public protocol NetworkManagerProtocol {
    /// Makes an async API request and decodes the response into the specified type.
    func makeAPIRequestAsync<T: Decodable>(
        url: String,
        parameters: [String: Any]?,
        method: NetworkHttpMethod,
        headers: NetworkHeaders,
        encoding: NetworkEncodingType?
    ) async throws -> T

    /// Makes an async API request and returns both the decoded response and response headers.
    func makeAPIRequestAsync<T: Decodable>(
        url: String,
        parameters: [String: Any]?,
        method: NetworkHttpMethod,
        headers: NetworkHeaders,
        encoding: NetworkEncodingType?
    ) async throws -> (T, [AnyHashable: Any]?)

    /// Makes a completion-based API request.
    func makeAPIRequest<T: Decodable>(
        url: String,
        parameters: [String: Any]?,
        method: NetworkHttpMethod,
        headers: NetworkHeaders,
        encoding: NetworkEncodingType?,
        completion: @escaping (Result<T, NetworkError>, [AnyHashable: Any]?) -> Void
    )

    /// Makes an async upload request and decodes the response into the specified type.
    func makeUploadAPIRequestAsync<T: Decodable>(
        url: String,
        parameters: [String: Any]?,
        fileData: [UploadableData]?,
        method: NetworkHttpMethod,
        headers: NetworkHeaders,
        encoding: NetworkEncodingType?,
        progressHandler: ((Double) -> Void)?
    ) async throws -> T

    /// Makes an async upload request and returns both the decoded response and response headers.
    func makeUploadAPIRequestAsync<T: Decodable>(
        url: String,
        parameters: [String: Any]?,
        fileData: [UploadableData]?,
        method: NetworkHttpMethod,
        headers: NetworkHeaders,
        encoding: NetworkEncodingType?,
        progressHandler: ((Double) -> Void)?
    ) async throws -> (T, [AnyHashable: Any]?)

    /// Makes a completion-based upload request.
    func makeUploadAPIRequest<T: Decodable>(
        url: String,
        parameters: [String: Any]?,
        fileData: [UploadableData]?,
        method: NetworkHttpMethod,
        headers: NetworkHeaders,
        encoding: NetworkEncodingType?,
        progressHandler: ((Double) -> Void)?,
        completion: @escaping (Result<T, NetworkError>, [AnyHashable: Any]?) -> Void
    )
}
