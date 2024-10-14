import Foundation

extension Data {
    // Determine the file extension based on the data signature
    func fileExtension() -> String {
        var byte = [UInt8](repeating: 0, count: 1)
        self.copyBytes(to: &byte, count: 1)
        
        switch byte[0] {
        case 0xFF: return "jpg"
        case 0x89: return "png"
        case 0x47: return "gif"
        case 0x25: return "pdf"
        case 0xD0: return "doc"
        case 0x46: return "txt"
        case 0x00: return "mp4"
        default: return "bin"
        }
    }
    
    // Determine MIME type based on file extension
    func mimeType() -> String {
        let fileExtension = self.fileExtension()
        
        switch fileExtension.lowercased() {
        case "jpg", "jpeg": return "image/jpeg"
        case "png": return "image/png"
        case "gif": return "image/gif"
        case "pdf": return "application/pdf"
        case "mp4": return "video/mp4"
        case "doc": return "application/msword"
        case "txt": return "text/plain"
        default: return "application/octet-stream"
        }
    }
}

extension Data {
      func toHexString() -> String {
        return self.map { String(format: "%02x", $0) }.joined()
    }
}
