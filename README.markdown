# AlamofireHelper :Understanding Alamofire in a much better way!

This library helps to call [Alamofire](https://github.com/Alamofire/Alamofire). Requests in your project.

This project supports Swift 4.0+ & Alamofire 4.0+

## Usage

GET request:

```swift
AlamofireHelper.get(withUrl: API.LOGIN) { (response, error) in
    if let response = response, let successCode = response[ResponseParams.code.rawValue] as? Int, successCode == 200, let data = response[ResponseParams.data.rawValue] as? [String : Any] {
        //Handle Success Response
        //...
    } else {
        //Handle Error if any
        //...
    }
}
```

POST/PUT/Delete request:

```swift
AlamofireHelper.request(withUrl: API.SIGNUP, methodType: HTTPMethod.post, paramaters, headers) { (response, error) in
    if let response = response, let successCode = response[ResponseParams.code.rawValue] as? Int, successCode == 200, let data = response[ResponseParams.data.rawValue] as? [String : Any] {
        //Handle Success Response
        //...
    } else {
        //Handle Error if any
        //...
    }
}
```

Multipart Upload request with Progress:

```swift
AlamofireHelper.uploadMultipartData(API.UPLOAD, paramaters, dictMultipartData: dictFiles, completion: { (response, error) in
    if let response = response, let successCode = response[ResponseParams.code.rawValue] as? Int, successCode == 200, let data = response[ResponseParams.data.rawValue] as? [String : Any] {
        //Handle Success Response
        //...
    } else {
        //Handle Error if any
        //...
    }) { (progress) in
        //Handle File Uploading Progress
        //...
    }
}
```
