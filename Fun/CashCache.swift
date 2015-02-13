// Cash.swift
//
// Copyright (c) 2015 Nick Noble
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

//please see: https://github.com/nnoble/Cash

import Foundation

private let _shared = Cash()

class Cash : NSObject, NSURLConnectionDataDelegate, NSURLConnectionDelegate {
    
    private var connectionToInfoMapping : Dictionary<NSURLConnection, AnyObject> = Dictionary()
    private var authorizationHeader : String? = nil
    private var headers : [String: String]? = nil
    
    class var shared : Cash {
        return _shared;
    }
    
    //MARK: - Header Methods
    
    /**
    Sets the specified headers for all requests.
    */
    func setHeaders(headers : [String: String]) {
        self.headers = headers
    }
    
    /**
    Add a basic auth header to all requests.
    */
    func setBasicAuth(username: NSString, password: NSString) {
        let loginString = NSString(format: "%@:%@", username, password)
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions(nil)
        authorizationHeader = "Basic \(base64LoginString)"
    }
    
    //MARK: - Request Methods
    
    /**
    Make a GET request with forced cache time in seconds. Leave expiration as nil to use the Cache-Control value from the server.
    */
    func get(url: String, expiration: Int?, completionHandler: (NSData!, NSError!) -> Void) {
        let nsurl = NSURL(string: url)!
        let request = NSMutableURLRequest(URL: nsurl)
        request.HTTPMethod = HTTPMethod.GET.rawValue
        sendRequest(request, expiration: expiration, completionHandler: completionHandler)
    }
    
    /**
    Make a POST request with forced cache time in seconds. Uses a Dictionary for the body.  Leave expiration as nil to use the Cache-Control value from the server.
    */
    func post(url: String, body: Dictionary<String, AnyObject>, expiration: Int?, completionHandler: (NSData!, NSError!) -> Void) {
        let nsurl = NSURL(string: url)!
        let request = NSMutableURLRequest(URL: nsurl)
        request.HTTPMethod = HTTPMethod.GET.rawValue
        var error : NSError?
        let jsonData = NSJSONSerialization.dataWithJSONObject(body, options: nil, error: &error)
        if let error = error {
            println("JSON Serialization error: \(error.localizedDescription)")
        } else {
            request.HTTPBody = jsonData!
            sendRequest(request, expiration: expiration, completionHandler: completionHandler)
        }
    }
    
    /**
    Make a request with forced cache time in seconds. Leave expiration as nil to use the Cache-Control value from the server.
    */
    func request(method: HTTPMethod, url: String, body: NSData?, expiration: Int?, completionHandler: (NSData!, NSError!) -> Void) {
        let nsurl = NSURL(string: url)!
        let request = NSMutableURLRequest(URL: nsurl)
        request.HTTPMethod = method.rawValue
        request.HTTPBody = body
        sendRequest(request, expiration: expiration, completionHandler: completionHandler)
    }
    
    /**
    Make a request with forced cache time in seconds. Leave expiration as nil to use the Cache-Control value from the server.
    */
    func sendRequest(request: NSMutableURLRequest, expiration: Int?, completionHandler: (NSData!, NSError!) -> Void) {
        request.cachePolicy = NSURLRequestCachePolicy.UseProtocolCachePolicy
        if let authorizationHeader = authorizationHeader {
            request.setValue(authorizationHeader, forHTTPHeaderField: "Authorization")
        }
        if let headers = headers {
            for (header, value) in headers {
                request.setValue(value, forHTTPHeaderField: header)
            }
        }
        let conn = NSURLConnection(request: request, delegate: self, startImmediately: false)!
        var dict : NSMutableDictionary = NSMutableDictionary()
        if let expiration = expiration {
            dict.setObject(expiration, forKey: "expiration")
        }
        dict.setObject(HandlerWrapper(completionHandler), forKey: "handler")
        connectionToInfoMapping[conn] = dict
        conn.start()
    }
    
    //MARK: - NSURLConnection Delegate Methods
    
    func connection(connection: NSURLConnection, willCacheResponse cachedResponse: NSCachedURLResponse) -> NSCachedURLResponse? {
        if let dict = connectionToInfoMapping[connection] as NSMutableDictionary? {
            if let expiration = dict["expiration"] as Int? {
                let response = cachedResponse.response as NSHTTPURLResponse
                var headers = response.allHeaderFields
                headers["Cache-Control"] = "max-age=\(expiration), private"
                headers.removeValueForKey("Expires")
                headers.removeValueForKey("s-maxage")
                let newResponse = NSHTTPURLResponse(URL: response.URL!, statusCode: response.statusCode, HTTPVersion: "HTTP/1.1", headerFields: headers)
                let cached = NSCachedURLResponse(response: newResponse!, data: cachedResponse.data, userInfo: headers, storagePolicy: NSURLCacheStoragePolicy.Allowed)
                return cached
            }
            return cachedResponse
        }
        return nil
    }
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        if var dict = connectionToInfoMapping[connection] as NSMutableDictionary? {
            dict["data"] = NSMutableData()
        }
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        if let dict = connectionToInfoMapping[connection] as NSMutableDictionary? {
            if let storedData = dict["data"] as NSMutableData? {
                storedData.appendData(data)
            }
        }
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        println(error.localizedDescription)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        if let dict = connectionToInfoMapping.removeValueForKey(connection) as NSMutableDictionary? {
            if let data = dict["data"] as NSMutableData? {
                if let handler = dict["handler"] as HandlerWrapper? {
                    handler.closure!(data, nil)
                }
            } else {
                println("data not found!")
            }
        } else {
            println("connection not found!")
        }
    }
}

//MARK: - Object Wrapper for Block

class HandlerWrapper {
    var closure: ((NSData!, NSError!) -> Void)?
    
    init (closure:((NSData!, NSError!) -> Void)?) {
        self.closure = closure
    }
}

//MARK: - Enum for HTTPMethods

public enum HTTPMethod: String {
    case OPTIONS = "OPTIONS"
    case GET = "GET"
    case HEAD = "HEAD"
    case POST = "POST"
    case PUT = "PUT"
    case PATCH = "PATCH"
    case DELETE = "DELETE"
    case TRACE = "TRACE"
    case CONNECT = "CONNECT"
}
