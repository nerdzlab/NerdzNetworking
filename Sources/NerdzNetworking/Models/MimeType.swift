//
//  MimeType.swift
//  Networking
//
//  Created by new user on 24.01.2020.
//  Copyright © 2020 Vasyl Khmil. All rights reserved.
//

import Foundation

public struct MimeType {
    public let type: String
    public let subtype: String
    public let parameters: [String: String]
    
    public var value: String {
        "\(type)/\(subtype)" + parameters.reduce("", { "; \($0)=\($1)" })
    }
    
    public init(type: String, subtype: String, parameters: [String: String] = [:]) {
        self.type = type
        self.subtype = subtype
        self.parameters = parameters
    }
    
    public static func application(_ subtype: ApplicationMimeSubtype, parameters: [String: String] = [:]) -> MimeType {
        MimeType(type: "application", subtype: subtype.rawValue, parameters: parameters)
    }
    
    public static func audio(_ subtype: AudioMimeSubtype, parameters: [String: String] = [:]) -> MimeType {
        MimeType(type: "audio", subtype: subtype.rawValue, parameters: parameters)
    }
    
    public static func image(_ subtype: ImageMimeSubtype, parameters: [String: String] = [:]) -> MimeType {
        MimeType(type: "image", subtype: subtype.rawValue, parameters: parameters)
    }
    
    public static func message(_ subtype: MessageMimeSubtype, parameters: [String: String] = [:]) -> MimeType {
        MimeType(type: "message", subtype: subtype.rawValue, parameters: parameters)
    }
    
    public static func model(_ subtype: ModelMimeSubtype, parameters: [String: String] = [:]) -> MimeType {
        MimeType(type: "model", subtype: subtype.rawValue, parameters: parameters)
    }
    
    public static func multipart(_ subtype: MultipartMimeSubtype, parameters: [String: String] = [:]) -> MimeType {
        MimeType(type: "multipart", subtype: subtype.rawValue, parameters: parameters)
    }
    
    public static func text(_ subtype: TextMimeSubtype, parameters: [String: String] = [:]) -> MimeType {
        MimeType(type: "text", subtype: subtype.rawValue, parameters: parameters)
    }
    
    public static func video(_ subtype: VideoMimeSubtype, parameters: [String: String] = [:]) -> MimeType {
        MimeType(type: "video", subtype: subtype.rawValue, parameters: parameters)
    }
}

public enum ApplicationMimeSubtype: String {
    case atom_xml = "atom+xml"
    case edi_x12 = "EDI-X12"
    case edifact = "EDIFACT"
    case json = "json"
    case javascript = "javascript"
    case octet_stream = "octet-stream"
    case ogg = "ogg"
    case pdf = "pdf"
    case postscript = "postscript"
    case soap_xml = "soap+xml"
    case font_woff = "font-woff"
    case xhtml_xml = "xhtml+xml"
    case xml_dtd = "xml-dtd"
    case xop_xml = "xop+xml"
    case zip = "zip"
    case gzip = "gzip"
    case x_bittorrent = "x-bittorrent"
    case x_tex = "x-tex"
    case xml = "xml"
}

public enum AudioMimeSubtype: String {
    case basic = "basic"
    case l24 = "L24"
    case mp4 = "mp24"
    case aac = "aac"
    case mpeg = "mpeg"
    case ogg = "ogg"
    case vorbis = "vorbis"
    case x_ms_wma = "x-ms-wma"
    case x_ms_wax = "x-ms-wax"
    case vnd_rn_realaudio = "vnd.rn-realaudio"
    case vnd_wave = "vnd.wave"
    case webm = "webm"
}

public enum ImageMimeSubtype: String {
    case gif = "gif"
    case jpeg = "jpeg"
    case pjpeg = "pjpeg"
    case png = "png"
    case svg_xml = "svg+xml"
    case tiff = "tiff"
    case vnd_microsoft_icon = "vnd.microsoft.icon"
    case vnd_wap_wbmp = "vnd.wap.wbmp"
    case webp = "webp"
}

public enum MessageMimeSubtype: String {
    case http = "http"
    case imdn_xml = "imdn+xml"
    case partial = "partial"
    case rfc822 = "rfc822"
}

public enum ModelMimeSubtype: String {
    case example = "example"
    case iges = "iges"
    case mesh = "mesh"
    case vrml = "vrml"
    case x3d_binary = "x3d+binary"
    case x3d_vrml = "x3d+vrml"
    case x3d_xml = "x3d+xml"
}

public enum MultipartMimeSubtype: String {
    case mixed = "mixed"
    case alternative = "alternative"
    case related = "related"
    case form_data = "form-data"
    case signed = "signed"
    case encrypted = "encrypted"
}

public enum TextMimeSubtype: String {
    case cmd = "cmd"
    case css = "css"
    case csv = "csv"
    case html = "html"
    case javascript = "javascript"
    case plain = "plain"
    case php = "php"
    case xml = "xml"
    case markdown = "markdown"
    case cache_manifest = "cache-manifest"
}

public enum VideoMimeSubtype: String {
    case mpeg = "mpeg"
    case mp4 = "mp4"
    case ogg = "ogg"
    case quicktime = "quicktime"
    case webm = "webm"
    case x_ms_wmv = "x-ms-wmv"
    case x_flv = "x-flv"
    case gpp3 = "3gpp"
}
