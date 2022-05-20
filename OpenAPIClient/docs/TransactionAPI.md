# TransactionAPI

All URIs are relative to *https://devnet.mogami.io*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getLatestBlockhash**](TransactionAPI.md#getlatestblockhash) | **GET** /api/transaction/latest-blockhash | 
[**getMinimumRentExemptionBalance**](TransactionAPI.md#getminimumrentexemptionbalance) | **GET** /api/transaction/minimum-rent-exemption-balance | 
[**makeTransfer**](TransactionAPI.md#maketransfer) | **POST** /api/transaction/make-transfer | 


# **getLatestBlockhash**
```swift
    open class func getLatestBlockhash(completion: @escaping (_ data: LatestBlockhashResponse?, _ error: Error?) -> Void)
```



### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


TransactionAPI.getLatestBlockhash() { (response, error) in
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
This endpoint does not need any parameter.

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
    open class func getMinimumRentExemptionBalance(dataLength: Double, completion: @escaping (_ data: MinimumRentExemptionBalanceResponse?, _ error: Error?) -> Void)
```



### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let dataLength = 987 // Double | 

TransactionAPI.getMinimumRentExemptionBalance(dataLength: dataLength) { (response, error) in
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
 **dataLength** | **Double** |  | 

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
    open class func makeTransfer(makeTransferRequest: MakeTransferRequest, completion: @escaping (_ data: MakeTransferResponse?, _ error: Error?) -> Void)
```



### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let makeTransferRequest = MakeTransferRequest(index: 123, tx: "TODO") // MakeTransferRequest | 

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

[**MakeTransferResponse**](MakeTransferResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

