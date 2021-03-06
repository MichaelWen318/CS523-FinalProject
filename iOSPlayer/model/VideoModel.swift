//
//  VideoModel.swift
//  iOSPlayer
//
//  Created by Michael Wen on 5/1/19.
//  Copyright © 2019 Yining Wen. All rights reserved.
//


import Foundation

// MARK: - VideoModel

enum VideoError: Error {
    case noFile
    case cannotReadFile
    case canotReadAsset
}

struct VideoModel {
    enum FileType: String {
        case videoFile = "Video"
        case noVideoFile = "Other file"
        case directory = "Directory"
        case unknown = "Unknown"
    }
    
    var duration: String
    var fileName: String
    var url: URL
    var fileExtension: String
    var fileType: FileType
    var creationDate: Date
    var fileSize: UInt64
    var thumbnail: Data?
    var directoryContent: Int?
    
    init?(url: URL?) {
        if (url != nil) {
            self.fileName = url!.deletingPathExtension().lastPathComponent
            self.url = url!
            self.fileExtension = url!.pathExtension
            self.fileType = .unknown
            self.fileSize = 0
            self.duration = ""
            self.creationDate = Date(timeIntervalSince1970: 0)
            try! setFileAttributes(url: url!)
        } else {
            return nil
        }
    }
    
    mutating func setFileAttributes(url: URL) throws  {
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: url.path)
            self.creationDate = (attr[FileAttributeKey.creationDate] as? Date)!
            self.fileSize = (attr[FileAttributeKey.size] as! UInt64)/(1024*1024)
            let fileType = attr[FileAttributeKey.type] as! FileAttributeType
            if fileType.rawValue == FileAttributeType.typeRegular.rawValue {
                if Constant.Paths.videoExtensions.contains(url.pathExtension) {
                    self.fileType = .videoFile
                } else {
                    self.fileType = .noVideoFile
                }
            } else if fileType.rawValue == FileAttributeType.typeDirectory.rawValue {
                self.fileType = .directory
            }
        } catch {
            self.fileType = .unknown
            throw VideoError.cannotReadFile
        }
    }
}

