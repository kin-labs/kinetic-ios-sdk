# AppAPI

All URIs are relative to *https://devnet.kinetic.kin.org*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiAppFeatureControllerAppWebhook**](AppAPI.md#apiappfeaturecontrollerappwebhook) | **POST** /api/app/{environment}/{index}/webhook/{type} | 
[**getAppConfig**](AppAPI.md#getappconfig) | **GET** /api/app/{environment}/{index}/config | 
[**getAppHealth**](AppAPI.md#getapphealth) | **GET** /api/app/{environment}/{index}/health | 


# **apiAppFeatureControllerAppWebhook**
```swift
    open class func apiAppFeatureControllerAppWebhook(environment: String, index: Double, type: String, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```



### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let environment = "environment_example" // String | 
let index = 987 // Double | 
let type = "type_example" // String | 

AppAPI.apiAppFeatureControllerAppWebhook(environment: environment, index: index, type: type) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **environment** | **String** |  | 
 **index** | **Double** |  | 
 **type** | **String** |  | 

### Return type

Void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAppConfig**
```swift
    open class func getAppConfig(environment: String, index: Double, completion: @escaping (_ data: AppConfig?, _ error: Error?) -> Void)
```



### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let environment = "environment_example" // String | 
let index = 987 // Double | 

AppAPI.getAppConfig(environment: environment, index: index) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **environment** | **String** |  | 
 **index** | **Double** |  | 

### Return type

[**AppConfig**](AppConfig.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAppHealth**
```swift
    open class func getAppHealth(environment: String, index: Double, completion: @escaping (_ data: AppHealth?, _ error: Error?) -> Void)
```



### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let environment = "environment_example" // String | 
let index = 987 // Double | 

AppAPI.getAppHealth(environment: environment, index: index) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **environment** | **String** |  | 
 **index** | **Double** |  | 

### Return type

[**AppHealth**](AppHealth.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

