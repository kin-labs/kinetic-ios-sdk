# AirdropAPI

All URIs are relative to *https://devnet.kinetic.kin.org*

Method | HTTP request | Description
------------- | ------------- | -------------
[**airdropStats**](AirdropAPI.md#airdropstats) | **GET** /api/airdrop/stats | 
[**requestAirdrop**](AirdropAPI.md#requestairdrop) | **POST** /api/airdrop | 


# **airdropStats**
```swift
    open class func airdropStats(completion: @escaping (_ data: AirdropStats?, _ error: Error?) -> Void)
```



### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


AirdropAPI.airdropStats() { (response, error) in
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

[**AirdropStats**](AirdropStats.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **requestAirdrop**
```swift
    open class func requestAirdrop(requestAirdropRequest: RequestAirdropRequest, completion: @escaping (_ data: RequestAirdropResponse?, _ error: Error?) -> Void)
```



### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let requestAirdropRequest = RequestAirdropRequest(account: "account_example", amount: "amount_example", environment: "environment_example", index: 123, mint: "mint_example") // RequestAirdropRequest | 

AirdropAPI.requestAirdrop(requestAirdropRequest: requestAirdropRequest) { (response, error) in
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
 **requestAirdropRequest** | [**RequestAirdropRequest**](RequestAirdropRequest.md) |  | 

### Return type

[**RequestAirdropResponse**](RequestAirdropResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

