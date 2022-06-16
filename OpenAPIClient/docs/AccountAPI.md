# AccountAPI

All URIs are relative to *https://devnet.kinetic.kin.org*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiAccountFeatureControllerGetAccountInfo**](AccountAPI.md#apiaccountfeaturecontrollergetaccountinfo) | **GET** /api/account/info/{environment}/{index}/{accountId} | 
[**createAccount**](AccountAPI.md#createaccount) | **POST** /api/account/create | 
[**getBalance**](AccountAPI.md#getbalance) | **GET** /api/account/balance/{environment}/{index}/{accountId} | 
[**getHistory**](AccountAPI.md#gethistory) | **GET** /api/account/history/{environment}/{index}/{accountId} | 
[**tokenAccounts**](AccountAPI.md#tokenaccounts) | **GET** /api/account/token-accounts/{environment}/{index}/{accountId} | 


# **apiAccountFeatureControllerGetAccountInfo**
```swift
    open class func apiAccountFeatureControllerGetAccountInfo(environment: String, index: Double, accountId: String, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```



### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let environment = "environment_example" // String | 
let index = 987 // Double | 
let accountId = "accountId_example" // String | 

AccountAPI.apiAccountFeatureControllerGetAccountInfo(environment: environment, index: index, accountId: accountId) { (response, error) in
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
 **accountId** | **String** |  | 

### Return type

Void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createAccount**
```swift
    open class func createAccount(createAccountRequest: CreateAccountRequest, completion: @escaping (_ data: AppTransaction?, _ error: Error?) -> Void)
```



### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let createAccountRequest = CreateAccountRequest(environment: "environment_example", index: 123, mint: "mint_example", tx: "TODO") // CreateAccountRequest | 

AccountAPI.createAccount(createAccountRequest: createAccountRequest) { (response, error) in
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
 **createAccountRequest** | [**CreateAccountRequest**](CreateAccountRequest.md) |  | 

### Return type

[**AppTransaction**](AppTransaction.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getBalance**
```swift
    open class func getBalance(environment: String, index: Double, accountId: String, completion: @escaping (_ data: BalanceResponse?, _ error: Error?) -> Void)
```



### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let environment = "environment_example" // String | 
let index = 987 // Double | 
let accountId = "accountId_example" // String | 

AccountAPI.getBalance(environment: environment, index: index, accountId: accountId) { (response, error) in
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
 **accountId** | **String** |  | 

### Return type

[**BalanceResponse**](BalanceResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getHistory**
```swift
    open class func getHistory(environment: String, index: Double, accountId: String, completion: @escaping (_ data: [HistoryResponse]?, _ error: Error?) -> Void)
```



### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let environment = "environment_example" // String | 
let index = 987 // Double | 
let accountId = "accountId_example" // String | 

AccountAPI.getHistory(environment: environment, index: index, accountId: accountId) { (response, error) in
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
 **accountId** | **String** |  | 

### Return type

[**[HistoryResponse]**](HistoryResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tokenAccounts**
```swift
    open class func tokenAccounts(environment: String, index: Double, accountId: String, completion: @escaping (_ data: [String]?, _ error: Error?) -> Void)
```



### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let environment = "environment_example" // String | 
let index = 987 // Double | 
let accountId = "accountId_example" // String | 

AccountAPI.tokenAccounts(environment: environment, index: index, accountId: accountId) { (response, error) in
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
 **accountId** | **String** |  | 

### Return type

**[String]**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

