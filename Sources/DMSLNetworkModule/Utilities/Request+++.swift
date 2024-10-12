//
//  Request+++.swift
//  DMSLNetworkModule
//
//  Created by Kavindu Dissanayake on 2024-10-13.
//

import Alamofire

// MARK: - DataRequest Debug Logger
extension Alamofire.DataRequest {

    public func debugLog(using config: NetworkConfiguration, parameters: [String: Any]? = nil) -> Self {
        // Check if logging is enabled
        guard config.enableLogging else { return self }
        
        // Log the cURL request along with status code and URL
        cURLDescription { curl in
            if let urlRequest = self.request {
                let url = urlRequest.url?.absoluteString ?? "Unknown URL"
                let method = urlRequest.httpMethod ?? "Unknown Method"
                let headers = urlRequest.allHTTPHeaderFields ?? [:]

                // Use NetworkLogger to log request details (URL, Method, Headers, Body)
                NetworkLogger.shared.logRequest(
                    url: url,
                    method: method,
                    headers: headers,
                    body: parameters
                )
            }
            
            // Log the cURL command
            NetworkLogger.shared.log("🔹NETWORK REQUEST START=======================================")
            NetworkLogger.shared.log("cURL Command:\n\(curl)")
            NetworkLogger.shared.log("🔹END========================================================")
        }

        // Log the response (JSON and errors)
        return self.responseJSON { response in
            NetworkLogger.shared.log("🔹NETWORK RESPONSE START=======================================")
            
            // Log response status
            if let httpResponse = response.response {
                let statusCode = httpResponse.statusCode
                let url = response.request?.url?.absoluteString ?? "Unknown URL"
                
                NetworkLogger.shared.log("Response URL: \(url)")
                NetworkLogger.shared.log("HTTP Status Code: \(statusCode)")
                NetworkLogger.shared.log("HTTP Response: \(httpResponse)")
            } else {
                NetworkLogger.shared.log("No HTTP response received.")
            }

            // Handle the result (success or failure)
            switch response.result {
            case .success(let json):
                // Convert JSON to pretty-printed string for logging
                let prettyString = NetworkLogger.shared.prettyPrintJSON(json)
                NetworkLogger.shared.log("🎉 Success! Here’s your JSON: \n\(prettyString) 💾")
                
            case .failure(let error):
                // Log the error description
                NetworkLogger.shared.log("💥 Oops! Error Debug Print: \(error.localizedDescription) ⚠️")
                
                // Try to log the response data if available (e.g., for status code 429)
                if let data = response.data,
                   let errorString = String(data: data, encoding: .utf8) {
                    NetworkLogger.shared.log("📜 Response Data: \n\(errorString)")
                } else {
                    NetworkLogger.shared.log("No response data available.")
                }
            }
            
            NetworkLogger.shared.log("🔹END========================================================")
        }
    }
}
