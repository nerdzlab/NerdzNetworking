//
//  NetworkingMultipartDataStreamFactory.swift
//  Networking
//
//  Created by Vasyl Khmil on 13.02.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

extension MultipartRequestData {
    
    var streamData: (stream: InputStream, boundary: String)? {

        let boundary = newBoundary()
        
        var streams: [InputStream] = []
        
        for file in files {
            if let stream = file.inputStream(with: boundary) {
                streams.append(stream)
            }
        }
        
        if case .params(let bodyParams) = body {
            var parametersData = Data()
            
            let orderedParameters: [(key: String, value: Any)] = bodyParams.map { ($0.key, $0.value) }
            
            for (index, parameter) in orderedParameters.enumerated() {
                var valueString = "\(parameter.value)"
                
                if index != orderedParameters.count - 1 {
                    valueString += "\r\n"
                }
                
                let values = [
                    "--\(boundary)\r\n",
                    "Content-Disposition: form-data; name=\"\(parameter.key)\"\r\n\r\n",
                    valueString
                ]
                
                parametersData.append(values: values)
            }
            
            streams.append(InputStream(data: parametersData))
        }
        
        if let postfixData = "\r\n--\(boundary)--\r\n".data(using: .utf8) {
            streams.append(InputStream(data: postfixData))
        }
        else {
            return nil
        }
        
        return (SerialInputStream(inputStreams: streams), boundary)
    }
    
    private func newBoundary() -> String {
        var uuid = UUID().uuidString
        uuid = uuid.replacingOccurrences(of: "-", with: "")
        uuid = uuid.map { $0.lowercased() }.joined()
     
        let boundary = String(repeating: "-", count: 20) + uuid + "\(Int(Date.timeIntervalSinceReferenceDate))"
     
        return boundary
    }
}

private extension MultipartFile {
    func inputStream(with boundary: String) -> InputStream? {
        
        let fileName = resource.fileName ?? fileName
        
        var prefixData = Data()
        
        let prefixInfo = [
            "--\(boundary)\r\n",
            "Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n",
            "Content-Type: \(mime.value)\r\n\r\n"]
        
        prefixData.append(values: prefixInfo)
        
        guard 
            let postfixData = "\r\n".data(using: .utf8),
            let resourceStream = resource.stream else 
        {
            return nil
        }
        
        return SerialInputStream(inputStreams: [
            InputStream(data: prefixData),
            resourceStream,
            InputStream(data: postfixData)
        ])
    } 
}

private extension Data {
    @discardableResult
    mutating func append<T>(values: [T]) -> Bool {
        var newData = Data()
        var status = true
 
        if T.self == String.self {
            for value in values {
                guard let convertedString = (value as! String).data(using: .utf8) else { status = false; break }
                newData.append(convertedString)
            }
        } else if T.self == Data.self {
            for value in values {
                newData.append(value as! Data)
            }
        } else {
            status = false
        }
 
        if status {
            self.append(newData)
        }
 
        return status
    }
}
