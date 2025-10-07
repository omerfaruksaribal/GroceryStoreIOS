import Foundation

struct ApiResponse<T: Codable>: Codable {
    let status: Int
    let message: String
    let data: T?
    let timestamp: String
    let errors: [ErrorDetails]?
}

struct ErrorDetails: Codable {
    let field: String
    let errorMessage: String
    let rejectedValue: String
}


/*
Successfull ApiResponse response
 {
    "status": 200,
    "message": "User registered. Activation code sent via email.",
    "data": {
        "userId": "673a0d83c2e3a1234d640766",
        "email": "testuser@gmail.com",
        "message": "Please check (testuser@gmail.com) for the activation code"
    },
    "timestamp": "2024-11-17T15:36:44.202192695",
    "errors": nil
 }

 */
