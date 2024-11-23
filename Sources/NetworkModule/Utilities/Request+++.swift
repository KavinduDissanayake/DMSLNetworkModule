//
//  Request+++.swift
//  DMSLNetworkModule
//
//  Created by Kavindu Dissanayake on 2024-10-13.
//
import LoggerModule
import Alamofire

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

                // Use NetworkLogger to log request details based on configuration
                Logger.shared.log("🔹NETWORK REQUEST START=======================================")
                Logger.shared.log("cURL Command:\n\(curl)")
                Logger.shared.log("🔹END========================================================")

                // Log request details (URL, Method, Headers, Body) conditionally based on logger config
                NetworkLogger.shared.logRequest(
                    url: url,
                    method: method,
                    headers: config.loggerConfig.logRequestHeaders ? headers : nil,
                    body: config.loggerConfig.logRequestBody ? parameters : nil,
                    config: config.loggerConfig
                )
            }
        }

        // Log the response (JSON and errors)
        return self.responseJSON { response in
            Logger.shared.log("🔹NETWORK RESPONSE START=======================================")
            
            // Log response status
            if let httpResponse = response.response {
                let statusCode = httpResponse.statusCode
                let url = response.request?.url?.absoluteString ?? "Unknown URL"
                
                // Log response headers and status code conditionally
                NetworkLogger.shared.logResponse(
                    url: url,
                    statusCode: config.loggerConfig.logStatusCode ? statusCode : nil,
                    headers: config.loggerConfig.logResponseHeaders ? httpResponse.allHeaderFields as? [String: String] : nil,
                    response: nil,
                    config: config.loggerConfig
                )
            } else {
                Logger.shared.log("No HTTP response received.")
            }

            // Handle the result (success or failure)
            switch response.result {
            case .success(let json):
                // Convert JSON to pretty-printed string for logging
                let prettyString = Logger.shared.prettyPrintJSON(json)
                Logger.shared.log("🎉 Success! Here’s your JSON: \n\(prettyString) 💾")
                
            case .failure(let error):
                // Log the error description
                Logger.shared.log("💥 Oops! Error Debug Print: \(error.localizedDescription) ⚠️")
                
                // Try to log the response data if available (e.g., for status code 429)
                if let data = response.data,
                   let errorString = String(data: data, encoding: .utf8) {
                    Logger.shared.log("📜 Response Data: \n\(errorString)")
                } else {
                    Logger.shared.log("No response data available.")
                }
            }
            
            Logger.shared.log("🔹END========================================================")
        }
    }
}
