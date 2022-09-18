# Kinetic iOS
🔋 Kinetic is a next generation API and SDK platform for Solana, brought to you by the Kin Foundation

## Installation

### Using Swift Package Manager
- In Xcode: File > Add Packages...
- Search "https://github.com/kin-labs/kinetic-ios"
- Choose appropriate Dependency Rule for your needs
- Add Package

## Demo App
This package ships with a demo app that gives an example implementation of common functions in the SDK.

To test the demo app:
- Clone this repository
- Open KineticDemoApp/KineticDemoApp.xcodeproj in Xcode
- Build target KineticDemoApp
- To make changes to the UI, look at APIDemoView.swift
- To make changes to the functionality, look at APIDemoViewModel.swift

## Updating OpenAPI generated API
If the backend API (server-side Kinetic) changes, you will need to update the generated Swift version of it contained in this repository. This command does that:
`npx @openapitools/openapi-generator-cli generate -i /path/to/openapi/spec/api-swagger.json -g swift5 -o ./Sources/Kinetic --additional-properties=useAsyncAwait=true`
