# NerdzNetworking

`NerdzNetworking` is a wrapper on top of `URLSession` and `URLRequest` to simplify creating and managing network requests written on `Swift` language.

<br>

# Example

You need to define request.

```swift
class LoginWithFacebookRequest: Request {
    typealias ResponseObjectType = User
    typealias ErrorType = AuthError
    
    let path = "login/facebook"
    let methong = .post
    let body: RequestBody?
    
    init(token: String) {   
        body = .params(
            [
                "token": token
            ]
        )
    }
}
```

And then just use it. (*each call is optional and can be skipped if needed*)

```swift
LoginWithFacebookRequest(token: fbToken)
    .execute()
    
    .onSuccess { user in
        ...
    }
    
    .onFail { error in
        ...
    }
    
    .onStart { operation in
        ...
    }
    
    .onProgress { progress in
        ...
    }
    
    .onDebug { info in
        ...
    }
}
```

<br>

# Ideology

##  Structure

The main ideology for creating `NerdzNetworking` library was to maximaly split networking into small pieces. 
The ideal scenario would be to have a separate class/structure per each request. This should help easily navigate and search information for specific request in files structure. 

![Requests example](https://raw.githubusercontent.com/nerdzlab/NerdzNetworking/master/requests_example.png)

<br>

## Strong typization

Another flow that library truing to follow - predefined options for using and simplicity of using. 
We are trying to use generic types on top of protocols, as well as enumerations instead of raw values. As an example - predefined headers like `Content-Type` or `Accept`. Instead of giving a possibility to put any value, we have defined and enumerations that limits possbie input only to predefined scenarios like `.application(.json)`.
To make it simple, previously mentioned headers already have `.application(.json)` value preselected for you, so in case you are using standard REST API - everything ready from the box.

<br>

# Tutorial

## Endpoint setup

First of all you need to setup your endpoint that will be used later on for executing requests. To do that - you should be using `Endpoint` class.
`Endpoint` class will collect all general settings for performing requests. You can change any parameter at any time you want.

```swift
let endpoint = Endpoint(baseUrl: myBaseUrl)
endpoint.headers = defaultHeaders // Specifying some default headers like OS, device language, device model, etc.
endpoint.headers.authToken = .bearer(tokenString) // Specifying user token
```

After creating your endpoint, you can mark it as a `default`, so every request will pick it up automatically.

```swift
Endpoint.default = endpoint
```

You can change `default` endpoint based on configuration or environment you need.

<br>

## Request creation
To create a request you should implement `Request` protocol. You can or have separate class per each request or an `enum`.

<br>

### Separate class for each request

```swift
class MyRequest: Request {
    typealias ResponseObjectType = MyExpectedResponse
    typealias ErrorType = MyUnexpectedError
    
    let path = "my/path/to/backend" // Required
    let methong = .get // Optional
    let queryParams = [("key", "value")] // Optional
    let body = .params(["key", "value"]) // Optional
    let headers = [RequestHeaderKey("key"): "value", .contentType: "application/json"] // Optional
    let timeout = 60 // Optional, by defauld will be picked from Endpoint
    let endpoint = myEndpoint // Optional, by default will be a Endpoint.default
}
```

This is just an example and probably you will not have all parameters required and static. To have dynamicaly created request - you can just use initializers that willl be taking dynamic parameters required for request. 
As an example - some dynamic bodyParams or dynamic path.

<br>

### Default request

You can use buit in class `DefaultRequest` to perform requests without a need to create a separate class.

```swift
let myRequest = DefaultRequest<MyExpectedResponse, MyUnexpectedError>(
    path: "my/path/to/backend", 
    method: .get, 
    queryParams: [("key", "value")], 
    body: .params(["key", "value"]), 
    headers: [RequestHeaderKey("key"): "value", .contentType: "application/json"], 
    timeout: 60,
    responseConverter: myResponseConverter,
    errorConverter: myErrorConverter,
    endpoint: myEndpoint)
```

<br>

### Multipart request

`NerdzNetworking` library also provide an easy way of creation and execution of multipart form-data requests. You just need to implement `MultipartFormDataRequest` instead of `Request` protocol or use `DefaultMultipartFormDataRequest` class.

In addition to `Request` fields you will need to provide `files` field of `MultipartFile` protocol instances. You can implement this protocol or use `DefaultMultipartFile` class.

```swift
class MyMultipartRequest: MultipartFormDataRequest {
    // Same fields as in Request example
    
    let files: [MultipartFile] = [
        DefaultMultipartFile(resource: fileData, mime: .image(.png), fileName: "avatar1"),
        DefaultMultipartFile(resource: fileUrl, mime: .audio(.mp4), fileName: "song"),
        DefaultMultipartFile(resource: filePath, mime: .image(.jpeg), fileName: "avatar2")
    ]
}
```

<br>

## Request execution

To exucute request you can use next constructions:

- `myRequest.execute()`: will execute `myRequest` on `Endpoint.default`
- `myRequest.execute(on: myEndpoint)`: will execute `myRequest` on `myEndpoint`
- `myEndpoint.execute(myRequest)`: will execute `myRequest` on `myEndpoint`

<br>

### Handling execution process

To handle execution process you can use futures-style methods after `execute` method called. (*every method is optional, so use only those you really need*)

```swift
myRequest
    .execute()
    .responseOn(.main) // Response will be returned in `.main` queue
    .retryOnFail(false) // If this request will fail - system will not try to rerun it again
    
    .onStart { requestOperation in
        // Will be called when request will start and return request operation that allow to control request during the execution
    }
    
    .onProgress { progress in
        // Will provide a progress of request execution. Useful for multipart uploading requests
    }
    
    .onSuccess { response in
        // Will return a response object specified in request under `ResponseType`
    }
    
    .onFail { error in
        // Will return `ErrorResponse` that might contain `ErrorType` specified in request
    }
    
    .onDebug { info in
        // Will return `DebugInfo` that contain a list of useful information for debugging request failure 
    }
```

<br>

## Mapping

For now `NerdzNetworking` library supports only native `Codable` mapping. [Tutorial](https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types).

<br>

## Response converters

`NerdzNetworking` supports response converters that might convert response before mapping process. Might be useful if case you need to adopt response data to internal model, or to bypass parent object to map only chileds.

<br>

### `ResponseJsonConverter`

You can also provide a response converters to convert some unpropertly returned responses beаore mapping into expected response starts. The responsible protocol for this is `ResponseJsonConverter`.

Response converter should be specified in `Request` class under `responseConverter`(*success*) or/and `errorConverter`(*fail*)  fields.

You can have your own converters that implement `ResponseJsonConverter` protocol, or use built in implementations: `KeyPathResponseConverter`, `ClosureResponseConverter`.

<br>

#### `KeyPathResponseConverter`

`KeyPathResponseConverter` allow you to pull a data from `JSON` chileds node by specific `path` to the node. 

```swift
class MyRequest: Request {
    var responseConverter: ResponseJsonConverter {
        KeyPathResponseConverter(path: "path/to/node")
    }
    
    var errorConverter: ResponseJsonConverter {
        KeyPathResponseConverter(path: "path/to/error")
    }
}
```

<br>

#### `ClosureResponseConverter`

`ClosureResponseConverter` allow you to provide custom convertation by closure. You will need to provide a `closure` that takes `Any` and return `Any` after convertation.

```swift
class MyRequest: Request {
    var responseConverter: ResponseJsonConverter {
        ClosureResponseConverter { response in
            // Return converted response for success response
        }
    }
    
    var errorConverter: ResponseJsonConverter {
        ClosureResponseConverter { response in
            // Return converted response for error response
        }
    }
}
```

<br>

#### Custom `ResponseJsonConverter`

You can implement your ovn converter by implementing `ResponseJsonConverter` protocol.

```swift
class MyResponseConverter: ResponseJsonConverter {
    func convertedJson(from json: Any) throws -> Any {
        // Provide convertation and return converted code
    }
}
```

<br>

# Installation

## CocoaPods

You can use [CocoaPods](https://cocoapods.org) dependency manager to install `NerdzNetworking`.
In your `Podfile` spicify:

```ruby
pod 'NerdzNetworking', '~> 1.0.1'
```

<br>

## Swift Package Manager

To add NerdzNetworking to a [Swift Package Manager](https://swift.org/package-manager/) based project, add:

```swift
.package(url: "https://github.com/nerdzlab/NerdzNetworking")
```

<br>

# Docummentation

<br>

## @ `Endpoint` class

Class that represents and endpoint with all settings for requests execution. You need to create at least one instance to be able to execute requests.

<br>

### Properties

Name | Type | Accessibility | Description
------------ | ------------- | ------------- | -------------
`Endpoint.default` | `Endpoint` | `static` `read-write` | An instance of endpoint that will be used for executing request
`baseUrl` | `URL` | `readonly` | An endpoint base url
`decoder` | `JSONDecoder?` | A decoder that will be used by default for decoding json responses if provided
`responseQueue` | `DispatchQueue?` | A queue that will be used by default for dispatching requests completions
`retryingCount` | `Int` | A number of retryings that should happen before aborting an error on request exeqution
`observation` | `ObservationManager` | A manager where you should register observers for observing different types of requests/responses
`requestRetrying` | `RequestRetryingManager` | a manager where you should register retriers
`sessionConfiguration` | `URLSessionConfiguration` | `readonly` | A configuration that is used for inner `URLSession`
`headers` | `[RequestHeaderKey: String]` | `read-write` | A headers that will be used with every request

<br>

### Methods
```
init(
    baseUrl                : URL,
    decoder                : JSONDecoder? = nil,
    responseQueue        : DispatchQueue? = nil,
    sessionConfiguration: URLSessionConfiguration = .default,
    retryingCount        : Int = 1,
    headers                : [RequestHeaderKey: String] = [:]
)
```

*Initializing with all parameters*

Name | Type | Default value | Description
------------ | ------------ | ------------- | -------------
`baseUrl` | `URL` | | An endpoint base url
`decoder` | `JSONDecoder?` | `nil` | A JSON response default decoder
`responseQueue` | `DispatchQueue` | `nil` | A default response queue for completions
`sessionConfiguration`| `URLSessionConfiguration` | `.default` | A configuration that will be used for inner `URLSession`
`retryingCount` | `Int` | `1` | A number of retryings on request failing
`headers` | `[RequestHeaderKey: String]` | `[:]` | A headers that will be used with every request 

<br>

```
func execute<T: Request>(_ request: T) -> ResponseInfoBuilder<T>
```

*Executing request on current endpoint*

Name | Type | Default value | Description
------------ | ------------ | ------------- | -------------
`request` | `Request` | - | Request to be executed

<br>

## @ `Request` protocol

**TYPE**: `protocol`

Protocol that represents a single request. You can imlement this protocol and then execute it

<br>

### `associatedtype`

Name | Type | Accessibility | Description
------------ | ------------- | ------------- | -------------
`ResponseObjectType` | `ResponseObject` | | A type of expected response from server. It should implement `ResponseObject` protocol 
`ErrorType` | `ServerError` | | A type of expected error from server. It should implement `ServerError` protocol 

<br>

### Properties

Name | Type | Accessibility | Description
------------ | ------------- | ------------- | -------------
`path` | `String` | `get` `required` | A request path
`method` | `HTTPMethod` | `get` `required` | A request method
`queryParams` | `[(String, String)]` | `get` `optional` | A request query parameters represented as an array of touples to save order
`body` | `RequestBody?` | `get` `optional` | A request body
`headers` | `[RequestHeaderKey: String]` | `get` `optional` | A request specific headers. Will be used is addition to headers from `Endpoint`
`timeout` | `TimeInterval` | `get` `optional` | A request timeout. If not specified - will be used default from `Endpoint`
`responseConverter` | `ResponseJsonConverter?` | `get` `optional` | A successful response converter. Will be converted before mapping into a `ResponseObjectType`
`errorConverter` | `ResponseJsonConverter?` | `get` `optional` | An error response converter. Will be converted before mapping into a `ErrorType`
`endpoint` | `Endpoint?` | `get` `optional` | An endpoint that will be used for execution
`decoder` | `JSONDecoder?` | `get` `optional` | A JSON response decoder that will be used for decoding response. In case not provided - decoder from `Endpoint` will be used

<br>

### Methods
```
func execute(on endpoint: Endpoint) -> ResponseInfoBuilder<Self>
```

*Executing current request on provided endpoint*

Name | Type | Default value | Description
------------ | ------------ | ------------- | -------------
`endpoint` | `Endpoint` | | Endpoint on what current request will be executed. 

<br>

```
func execute() -> ResponseInfoBuilder<Self>
```
*Executing current request on `Endpoint.default` instance*

<br>

## @ `DefaultRequest` struct

**TYPE**: `struct`

**IMPLEMENT**: `Request`

A default implementation of `Request` protocol that can be used for executing requests without creation of extra class

<br>

### Generics

Name | Types | Description
------------ | ------------- | -------------
`Response` | `ResponseObject` | A type of a successful response object 
`Error` | `ServerError` | A type of an error response object

<br>

### Properties

Name | Type | Accessibility | Description
------------ | ------------- | ------------- | -------------
`path` | `String` | `read-write` | A request path
`method` | `HTTPMethod` | `read-write` | A request method
`queryParams` | `[(String, String)]` | `read-write` | A request query parameters represented as an array of touples to save order
`body` | `RequestBody?` | `read-write` | A request body
`headers` | `[RequestHeaderKey: String]` | `read-write` | A request specific headers. Will be used is addition to headers from `Endpoint`
`timeout` | `TimeInterval` | `read-write` | A request timeout. If not specified - will be used default from `Endpoint`
`responseConverter` | `ResponseJsonConverter?` | `read-write` | A successful response converter. Will be converted before mapping into a `ResponseObjectType`
`errorConverter` | `ResponseJsonConverter?` | `read-write` | An error response converter. Will be converted before mapping into a `ErrorType`
`endpoint` | `Endpoint?` | `read-write` | An endpoint that will be used for execution
`decoder` | `JSONDecoder?` | `read-write` | A JSON response decoder that will be used for decoding response. In case not provided - decoder from `Endpoint` will be used

<br>

### Methods

```
init(
    path                : String, 
    method                : HTTPMethod, 
    queryParams            : [(String, String)] = [], 
    body                : RequestBody? = nil, 
    headers                : [RequestHeaderKey: String] = [:], 
    timeout                : TimeInterval? = nil,
    responseConverter    : ResponseJsonConverter? = nil,
    errorConverter        : ResponseJsonConverter? = nil,
    endpoint            : Endpoint? = nil,
    decoder                : JSONDecoder? = nil
)
```

*Initialize `DefaultRequest` object with all possible parameters*

Name | Type | Default value | Description
------------ | ------------ | ------------- | -------------
`path` | `String` | - | A request path
`method` | `HTTPMethod` | - | A request method
`queryParams` | `[(String, String)]` | `[]` | A request query parameters represented as an array of touples to save order
`bodyParams` | `[String: Any]` | `[:]` | A request body params
`headers` | `[RequestHeaderKey: String]` | `[:]` | A request specific headers. Will be used is addition to headers from `Endpoint`
`timeout` | `TimeInterval` | `nil` | A request timeout. If not specified - will be used default from `Endpoint`
`responseConverter` | `ResponseJsonConverter?` | `nil` | A successful response converter. Will be converted before mapping into a `ResponseObjectType`
`errorConverter` | `ResponseJsonConverter?` | `nil` | An error response converter. Will be converted before mapping into a `ErrorType`
`endpoint` | `Endpoint?` | `nil` | An endpoint that will be used for execution
`decoder` | `JSONDecoder?` | `nil` | A JSON response decoder that will be used for decoding response. In case not provided - decoder from `Endpoint` will be used

<br>

## @ `MultipartFormDataRequest` protocol

**TYPE**: `protocol`

**INHERITS**: `Request` protocol

Protocol that represents a multipart form-data request. Protocol inherits `Request` protocol, and adding files property on top. So mostly it is the same as `Request` protocol.

<br>

### `associatedtype`

Name | Type | Accessibility | Description
------------ | ------------- | ------------- | -------------
`ResponseObjectType` | `ResponseObject` | | A type of expected response from server. It should implement `ResponseObject` protocol 
`ErrorType` | `ServerError` | | A type of expected error from server. It should implement `ServerError` protocol 

<br>

### Properties

Name | Type | Accessibility | Description
------------ | ------------- | ------------- | -------------
`path` | `String` | `get` `required` | A request path
`method` | `HTTPMethod` | `get` `required` | A request method
`queryParams` | `[(String, String)]` | `get` `optional` | A request query parameters represented as an array of touples to save order
`body` | `RequestBody?` | `get` `optional` | A request body
`headers` | `[RequestHeaderKey: String]` | `get` `optional` | A request specific headers. Will be used is addition to headers from `Endpoint`
`timeout` | `TimeInterval` | `get` `optional` | A request timeout. If not specified - will be used default from `Endpoint`
`responseConverter` | `ResponseJsonConverter?` | `get` `optional` | A successful response converter. Will be converted before mapping into a `ResponseObjectType`
`errorConverter` | `ResponseJsonConverter?` | `get` `optional` | An error response converter. Will be converted before mapping into a `ErrorType`
`endpoint` | `Endpoint?` | `get` `optional` | An endpoint that will be used for execution
`decoder` | `JSONDecoder?` | `get` `optional` | A JSON response decoder that will be used for decoding response. In case not provided - decoder from `Endpoint` will be used
`files` | `[MultipartFile]` | `get` `required` | A list of files that needs to be processed with request

<br>

### Methods
```
func execute(on endpoint: Endpoint) -> ResponseInfoBuilder<Self>
```

*Executing current request on provided endpoint*

Name | Type | Default value | Description
------------ | ------------ | ------------- | -------------
`endpoint` | `Endpoint` | | Endpoint on what current request will be executed. 

<br>

```
func execute() -> ResponseInfoBuilder<Self>
```
*Executing current request on `Endpoint.default` instance*

<br>

## @ `DefaultMultipartFormDataRequest` struct

**TYPE**: `struct`

**IMPLEMENT**: `MultipartFormDataRequest`

A default implementation of `MultipartFormDataRequest` protocol that can be used for executing multipart requests without creation of extra class

<br>

### Generics

Name | Types | Description
------------ | ------------- | -------------
`Response` | `ResponseObject` | A type of a successful response object 
`Error` | `ServerError` | A type of an error response object

<br>

### Properties

Name | Type | Accessibility | Description
------------ | ------------- | ------------- | -------------
`path` | `String` | `read-write` | A request path
`method` | `HTTPMethod` | `read-write` | A request method
`queryParams` | `[(String, String)]` | `read-write` | A request query parameters represented as an array of touples to save order
`body` | `RequestBody?` | `read-write` | A request body
`headers` | `[RequestHeaderKey: String]` | `read-write` | A request specific headers. Will be used is addition to headers from `Endpoint`
`timeout` | `TimeInterval` | `read-write` | A request timeout. If not specified - will be used default from `Endpoint`
`responseConverter` | `ResponseJsonConverter?` | `read-write` | A successful response converter. Will be converted before mapping into a `ResponseObjectType`
`errorConverter` | `ResponseJsonConverter?` | `read-write` | An error response converter. Will be converted before mapping into a `ErrorType`
`endpoint` | `Endpoint?` | `read-write` | An endpoint that will be used for execution
`decoder` | `JSONDecoder?` | `read-write` | A JSON response decoder that will be used for decoding response. In case not provided - decoder from `Endpoint` will be used
`files` | `[MultipartFile]` | `read-write` | A list of files that needs to be processed in request

<br>

### Methods

```
init(
    path                : String, 
    method                : HTTPMethod, 
    queryParams            : [(String, String)] = [], 
    body                : RequestBody? = nil, 
    headers                : [RequestHeaderKey: String] = [:], 
    timeout                : TimeInterval? = nil,
    responseConverter    : ResponseJsonConverter? = nil,
    errorConverter        : ResponseJsonConverter? = nil,
    endpoint            : Endpoint? = nil,
    decoder                : JSONDecoder? = nil,
    files                : [MultipartFile] = []
)
```

*Initialize `DefaultMultipartFormDataRequest` object with all possible parameters*

Name | Type | Default value | Description
------------ | ------------ | ------------- | -------------
`path` | `String` | - | A request path
`method` | `HTTPMethod` | - | A request method
`queryParams` | `[(String, String)]` | `[]` | A request query parameters represented as an array of touples to save order
`bodyParams` | `[String: Any]` | `[:]` | A request body params
`headers` | `[RequestHeaderKey: String]` | `[:]` | A request specific headers. Will be used is addition to headers from `Endpoint`
`timeout` | `TimeInterval` | `nil` | A request timeout. If not specified - will be used default from `Endpoint`
`responseConverter` | `ResponseJsonConverter?` | `nil` | A successful response converter. Will be converted before mapping into a `ResponseObjectType`
`errorConverter` | `ResponseJsonConverter?` | `nil` | An error response converter. Will be converted before mapping into a `ErrorType`
`endpoint` | `Endpoint?` | `nil` | An endpoint that will be used for execution
`decoder` | `JSONDecoder?` | `nil` | A JSON response decoder that will be used for decoding response. In case not provided - decoder from `Endpoint` will be used
`files` | `[MultipartFile]` | `[]` | A list of files that needs to be processed in request

<br>

## @ `DefaultMultipartFile` struct

A default implementation of `MultipartFile` protocol that you can use in case you do not want to create additional class for sending multipart request

<br>

### Properties

Name | Type | Accessibility | Description
------------ | ------------- | ------------- | -------------
`fileName` | `String` | `read-write` | A file name
`mime` | `MimeType` | `read-write` | a file mime type
`resource` | `MultipartResourceConvertable` | `read-write` | A representation of file data. Might be `String`, `Data`, `URL`, `InputStream`

<br>

### Methods

```
init(
    resource: MultipartResourceConvertable, 
    mime: MimeType, 
    fileName: String
)
```

*Initialize `DefaultMultipartFile` object with all possible parameters*

Name | Type | Default value | Description
------------ | ------------ | ------------- | -------------
`resource` | `MultipartResourceConvertable` | | A file name
`mime` | `MimeType` | | a file mime type
`fileName` | `String` | | A representation of file data. Might be `String`, `Data`, `URL`, `InputStream`

<br>

## @ `ServerError` protocol

A protocol that represents an error returned from server

<br>

### Properties

Name | Type | Accessibility | Description
------------ | ------------- | ------------- | -------------
`message` | `String` | `get` `required` | A message of an error

<br>

### Supported types

- `String`
- `Optional`

<br>

## @ `HTTPMethod` enum

**TYPE**: `enum`

**INHERITS**: `String`

An enum that represents a request http method.

Name | Description
------------ | ------------
`.get` | A `GET` http method
`.post` | A `POST` http method
`.put` | A `PUT` http method
`.delete` | A `DELETE` http method
`.path` | A `PATH` http method 

<br>

## @ `RequestBody` enum

**TYPE**: `enum`

An enum that represents different types of request body

Name | Parameters | Description
------------ | ------------ | ------------
`.raw` | `value: Data` | A raw data
`.string` | `value: String` | A string body
`.params` | `value: [String: Any]` | A body formed with parameters

<br>

# Next steps

**TBD**

# License

This code is distributed under the MIT license. See the `LICENSE` file for more info.



