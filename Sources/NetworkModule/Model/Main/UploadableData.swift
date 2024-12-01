//
//  UploadableData.swift
//  DMSLNetworkModule
//
//  Created by Kavindu Dissanayake on 2024-10-12.
//
import Foundation

public struct UploadableData: Codable {
    // MARK: - Properties
    public var fileData: Data
    public var fileDataParamName: String
    public var fileName: String
    public var fileType: String
    public var mimeType: String
    public var fileTypeParamName: String

    // MARK: - Init with optional parameters
    public init(fileData: Data,
                fileDataParamName: String = "File",
                fileType: String = "FileType",
                fileName: String? = nil,
                mimeType: String? = nil,
                fileTypeParamName: String = "Type") {
        
        self.fileData = fileData
        self.fileDataParamName = fileDataParamName
        self.fileType = fileType
        self.fileName = fileName ?? "file.\(fileData.fileExtension())"
        self.mimeType = mimeType ?? fileData.mimeType()
        self.fileTypeParamName = fileTypeParamName
    }
}

public extension UploadableData {
    // MARK: - Computed Property
    var fileTypeData: Data {
        return fileType.data(using: .utf8) ?? Data()
    }
}
