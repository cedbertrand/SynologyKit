//
//  SynologyRequest.swift
//  SynologyKit
//
//  Created by xu.shuifeng on 20/09/2017.
//

import Foundation
import Alamofire

protocol SynologyRequest {
    
    var baseURLString: String { get set }
    
    var path: String { get }
    
    var params: Parameters { get set }
    
    var headers: HTTPHeaders? { get set }
    
    func asURLRequest() -> URLRequestConvertible
}

struct SynologyBasicRequest: SynologyRequest {
    
    var baseURLString: String
    
    /// path of the API. The path information can be retrieved by requesting SYNO.API.Info
    var path: String
    
    /// Name of the API requested
    var api: SynologyAPI
    
    /// Method of the API requested
    var method: SynologyMethod
    
    var params: Parameters
    
    /// Version of the API requested
    var version: Int = 1
    
    var headers: HTTPHeaders?
    
    func urlQuery() -> String {
        return "webapi/\(path)?api=\(api.rawValue)&version=\(version)&method=\(method)"
    }
    
    func asURLRequest() -> URLRequestConvertible {
        do {
            let urlString = "\(baseURLString)webapi/\(path)"
            var parameter = params
            parameter["api"] = api.rawValue
            parameter["method"] = method.rawValue
            parameter["version"] = version
            let request = try URLRequest(url: urlString, method: .post, headers: headers)
            let encodedRequest = try URLEncoding.default.encode(request, with: parameter)
            return encodedRequest
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    init(baseURLString: String, path: SynologyCGI, api: SynologyAPI, method: SynologyMethod, params: Parameters) {
        self.baseURLString = baseURLString
        self.path = path.rawValue
        self.api = api
        self.method = method
        self.params = params
    }
}

struct QuickConnectRequest: SynologyRequest {
    
    var baseURLString: String
    
    var path: String
    
    var params: Parameters
    
    var headers: HTTPHeaders?
    
    func asURLRequest() -> URLRequestConvertible {
        do {
            let urlString = baseURLString + path
            let request = try URLRequest(url: urlString, method: .post, headers: headers)
            let encodedRequest = try JSONEncoding.default.encode(request, with: params)
            return encodedRequest
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

public extension SynologyClient {
    
    enum FileSortBy: String {
        case name = "name"
        /// file owner
        case user = "user"
        /// file group
        case group = "group"
        ///  last modified time
        case lastModifiedtime = "mtime"
        ///  last access time
        case lastAccessTime = "atime"
        ///  last change time
        case lastChangeTime = "ctime"
        /// create time
        case createTime = "crtime"
        /// POSIX permission
        case posix = "posix"
    }
    
    enum FileSortDirection: String {
        case ascending = "asc"
        case descending = "desc"
    }
    
    struct AdditionalOptions: OptionSet {
        
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let realPath = AdditionalOptions(rawValue: 1 << 0)
        public static let size = AdditionalOptions(rawValue: 1 << 1)
        public static let owner = AdditionalOptions(rawValue: 1 << 2)
        public static let time = AdditionalOptions(rawValue: 1 << 3)
        public static let perm = AdditionalOptions(rawValue: 1 << 4)
        public static let mountPointType = AdditionalOptions(rawValue: 1 << 5)
        public static let volumeStatus = AdditionalOptions(rawValue: 1 << 6)
        public static let type = AdditionalOptions(rawValue: 1 << 7)
        public static let `default`: AdditionalOptions = [.size, .time, .type]
        
        func value() -> String {
            
            var result: [String] = []
            if self.contains(.realPath) {
                result.append("real_path")
            }
            if contains(.size) {
                result.append("size")
            }
            if contains(.owner) {
                result.append("owner")
            }
            if contains(.time) {
                result.append("time")
            }
            if contains(.perm) {
                result.append("perm")
            }
            if contains(.mountPointType) {
                result.append("mount_point_type")
            }
            if contains(.volumeStatus) {
                result.append("volume_status")
            }
            if contains(.type) {
                result.append("type")
            }
            return result.description
        }
    }

    enum VirtualFolderType: String {
        case cifs
        case iso
    }
    
    /// Compress level. default is moderate
    enum CompressLevel: String {
        /// moderate compression and normal compression speed
        case moderate
        /// pack files with no compress
        case store
        /// fastest compression speed but less compression
        case fastest
        /// slowest compression speed but optimal compression
        case best
    }
    
    /// CompressMode, default is add
    enum CompressMode: String {
        /// Update existing items and add new files. If an archive does not exist, a new one is created.
        case add
        /// Update existing items if newer on the file system and add new files. If the archive does not exist create a new archive.
        case update
        ///  Update existing items of an archive if newer on the file system. Does not add new files to the archive.
        case refreshen
        /// Update older files in the archive and add files that are not already in the archive.
        case synchronize
    }

    enum CompressFormat: String {
        case zip
        case sevenZ = "7z"
    }
}
