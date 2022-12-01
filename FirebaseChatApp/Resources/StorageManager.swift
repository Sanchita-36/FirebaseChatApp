//
//  StorageManager.swift
//  FirebaseChatApp
//
//  Created by Sanchita Lachke on 28/11/22.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    static let shared = StorageManager()
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    //upload pictures to firebase storage and returns completion with URL string to download
    public  func uploadProfilePicture(with data: Data,
                                      fileName: String,
                                      completion: @escaping UploadPictureCompletion) {
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: { metadata, error in
            
            guard error == nil else {
                //failed
                print("Failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL(completion: {
                url, error in
                guard let url = url else {
                    print("Failed to get downloaded url")
                    completion(.failure(StorageErrors.failedToGetDownloadedUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("Download url returnd: \(urlString)")
                completion(.success(urlString))
            })
            
        })
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadedUrl
    }
    
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)
       
        reference.downloadURL (completion: { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadedUrl))
                return
            }
            completion(.success(url))
        })
    }
    
}
