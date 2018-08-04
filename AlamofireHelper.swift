//
//  AlamofireHelper.Swift
//  Created by Sohil Memon
//  Copyright © 2018 Sohil. All rights reserved.
//  Swift Version 4.1
//  Alamofire Version 4.7+

import UIKit
import Alamofire

////////////////////////////////////////////////////////////////
//MARK: Response Params
////////////////////////////////////////////////////////////////

enum ResponseParams: String {
    case code
    case data
    case message
}

////////////////////////////////////////////////////////////////
//MARK: API Manager
///Manage all your API Listing here!
////////////////////////////////////////////////////////////////
struct API {
    fileprivate static let BASE_URL = "http://your_base_url/"
    static let LOGIN = BASE_URL + "login"
    static let SIGNUP = BASE_URL + "signup"
}

////////////////////////////////////////////////////////////////
//MARK: This is specially to manage Background Task
////////////////////////////////////////////////////////////////

class Networking {
    static let sharedInstance = Networking()
    public var sessionManager: Alamofire.SessionManager // most of your web service clients will call through sessionManager
    public var backgroundSessionManager: Alamofire.SessionManager // your web services you intend to keep running when the system backgrounds your app will use this
    private init() {
        self.sessionManager = Alamofire.SessionManager(configuration: URLSessionConfiguration.default)
        self.backgroundSessionManager = Alamofire.SessionManager(configuration: URLSessionConfiguration.background(withIdentifier: "com.your_bundle_id"))
        var backgroundCompletionHandler: (() -> Void)? {
            get {
                return backgroundSessionManager.backgroundCompletionHandler
            }
            set {
                backgroundSessionManager.backgroundCompletionHandler = newValue
            }
        }
    }
}

////////////////////////////////////////////////////////////////
//MARK: AlamofireHelper : To manage All type of requests
////////////////////////////////////////////////////////////////

struct AlamofireHelper {
    
    // MARK: Multipart Data Uploading
    // Parameters : Pass Dictionary as parameter (String of String Type)
    // arrImages : Pass Array of UIImagesData
    typealias Completion = (_ dictonary: Dictionary<String, Any>?, _ error: Error?) -> ()
    typealias Progress = (_ progress: Double) -> ()
    static func uploadMultipartData(_ url: String, _ parameters: Dictionary<String, Any>, headers: [String: String]? = nil, dictMultipartData: Dictionary<String, Any>, completion: @escaping Completion, progressVal: @escaping Progress){
        Networking.sharedInstance.backgroundSessionManager.upload(multipartFormData: { (multipartData) in
            for (key, value) in parameters {
                multipartData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
            }
            for (key, value) in dictMultipartData {
                //Identifying that it's a Image or Video
                if let value = value as? Data {
                    if let _ = UIImage(data: value){
                        multipartData.append(value, withName: key, fileName: "1.jpeg", mimeType: "image/jpeg")
                    }else{
                        multipartData.append(value, withName: key, fileName: "1.mov", mimeType: "video/mov")
                    }
                }
                //This is for if single key has multiple images or video
                else if let arrData = value as? [Data] {
                    for itemData in arrData{
                        if let _ = UIImage(data: itemData){
                            multipartData.append(itemData, withName: key, fileName: "1.jpeg", mimeType: "image/jpeg")
                        }else{
                            multipartData.append(itemData, withName: key, fileName: "1.mov", mimeType: "video/mov")
                        }
                    }
                }
            }
            debugPrint("Total size of file : \(ByteCountFormatter.string(fromByteCount: Int64(multipartData.contentLength), countStyle: .file))")
        }, to: url, headers: headers) { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (progress) in
                    progressVal(progress.fractionCompleted) // Uploading Progress Block
                    print(progress)
                })
                upload.responseJSON { response in
                    if let value = response.result.value as? Dictionary<String, Any> {
                        completion(value, nil)  // Success Response Block
                    } else if let error = response.result.error {
                        completion(nil, error)  // Error Response Block
                    }
                }
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    // MARK: GET Request
    static func getRequest(withUrl url: String, _ headers: [String: String]? = nil, _ completion: @escaping Completion){
        Alamofire.request(url, method: HTTPMethod.get, parameters: nil, encoding: JSONEncoding.default, headers:headers)
            .responseJSON { response in
                switch(response.result) {
                case .success(let data):
                    if let value = data as? Dictionary<String, Any> {
                        completion(value, nil)
                    }
                    break
                case .failure(let error):
                    completion(nil, error)
                    break
                }
        }
    }
    
    // MARK: POST Request
    static func request(withUrl url:String, methodType: HTTPMethod = HTTPMethod.post, _ param : Dictionary<String, Any>?, _ headers: [String: String]? = nil, _ completion: @escaping Completion){
        Alamofire.request(url, method: methodType, parameters: param, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                switch(response.result) {
                case .success(let data):
                    if let value = data as? Dictionary<String, Any> {
                        completion(value, nil)
                    }
                case .failure(let error):
                    completion(nil, error)
                }
        }
    }
}
