# TransactionAPI

All URIs are relative to *https://devnet.kinetic.kin.org*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getLatestBlockhash**](TransactionAPI.md#getlatestblockhash) | **GET** /api/transaction/latest-blockhash/{environment}/{index} | 
[**getMinimumRentExemptionBalance**](TransactionAPI.md#getminimumrentexemptionbalance) | **GET** /api/transaction/minimum-rent-exemption-balance/{environment}/{index} | 
[**makeTransfer**](TransactionAPI.md#maketransfer) | **POST** /api/transaction/make-transfer | 


# **getLatestBlockhash**
```swift
    open class func getLatestBlockhash(environment: String, index: Int, completion: @escaping (_ data: LatestBlockhashResponse?, _ error: Error?) -> Void)
```



### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let environment = "environment_example" // String | 
let index = 987 // Int | 

TransactionAPI.getLatestBlockhash(environment: environment, index: index) { (response, error) in
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
 **index** | **Int** |  | 

### Return type

[**LatestBlockhashResponse**](LatestBlockhashResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMinimumRentExemptionBalance**
```swift
    open class func getMinimumRentExemptionBalance(environment: String, index: Int, dataLength: Int, completion: @escaping (_ data: MinimumRentExemptionBalanceResponse?, _ error: Error?) -> Void)
```



### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let environment = "environment_example" // String | 
let index = 987 // Int | 
let dataLength = 987 // Int | 

TransactionAPI.getMinimumRentExemptionBalance(environment: environment, index: index, dataLength: dataLength) { (response, error) in
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
 **index** | **Int** |  | 
 **dataLength** | **Int** |  | 

### Return type

[**MinimumRentExemptionBalanceResponse**](MinimumRentExemptionBalanceResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **makeTransfer**
```swift
    open class func makeTransfer(makeTransferRequest: MakeTransferRequest, completion: @escaping (_ data: AppTransaction?, _ error: Error?) -> Void)
```



### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let makeTransferRequest = MakeTransferRequest(commitment: "commitment_example", environment: "environment_example", index: 123, mint: "mint_example", lastValidBlockHeight: 123, referenceId: "referenceId_example", referenceType: "referenceType_example", tx: 123) // MakeTransferRequest | 

TransactionAPI.makeTransfer(makeTransferRequest: makeTransferRequest) { (response, error) in
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
 **makeTransferRequest** | [**MakeTransferRequest**](MakeTransferRequest.md) |  | 

### Return type

[**AppTransaction**](AppTransaction.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

