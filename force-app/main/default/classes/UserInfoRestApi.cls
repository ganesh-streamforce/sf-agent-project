@RestResource(urlMapping='/api/users/*')
global with sharing class UserInfoRestApi {
    
    /**
     * GET endpoint to retrieve user information by userId
     * Usage: /services/apexrest/api/users/{userId}
     * 
     * @return JSON response with user information or error message
     */
    @HttpGet
    global static void getUserInfo() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            // Extract userId from URL path
            String userId = extractUserIdFromPath(req.requestURI);
            
            if (String.isBlank(userId)) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponse(
                    400,
                    'Bad Request',
                    'userId parameter is required in the URL path'
                )));
                return;
            }
            
            // Query user information
            User user = [
                SELECT 
                    Id,
                    Username,
                    Email,
                    FirstName,
                    LastName,
                    Title,
                    Department,
                    Phone,
                    MobilePhone,
                    IsActive,
                    UserType,
                    CreatedDate,
                    LastModifiedDate,
                    CompanyName
                FROM User
                WHERE Id = :userId
                LIMIT 1
            ];
            
            // Create and return user response
            UserResponse userResponse = new UserResponse(user);
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(userResponse));
            res.addHeader('Content-Type', 'application/json');
            
        } catch (QueryException e) {
            res.statusCode = 404;
            res.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponse(
                404,
                'Not Found',
                'User with the specified ID does not exist'
            )));
        } catch (Exception e) {
            // Check if it's an invalid ID error
            if (e.getMessage().contains('Invalid') || e.getMessage().contains('INVALID_FIELD')) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponse(
                    400,
                    'Bad Request',
                    'Invalid userId format'
                )));
            } else {
                res.statusCode = 500;
                res.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponse(
                    500,
                    'Internal Server Error',
                    'An unexpected error occurred: ' + e.getMessage()
                )));
                System.debug('Error in getUserInfo: ' + e.getMessage() + ' | Stack Trace: ' + e.getStackTraceString());
            }
        }
    }
    
    /**
     * Extract userId from the REST request URI
     * Expected format: /services/apexrest/api/users/{userId}
     */
    private static String extractUserIdFromPath(String requestURI) {
        // Split the URI by forward slash
        String[] pathSegments = requestURI.split('/');
        
        // The userId should be the last segment
        if (pathSegments.size() > 0) {
            String lastSegment = pathSegments[pathSegments.size() - 1];
            if (String.isNotBlank(lastSegment) && lastSegment != 'users') {
                return lastSegment;
            }
        }
        
        return null;
    }
    
    /**
     * Wrapper class for user response
     */
    global class UserResponse {
        global String id;
        global String username;
        global String email;
        global String firstName;
        global String lastName;
        global String title;
        global String department;
        global String phone;
        global String mobilePhone;
        global Boolean isActive;
        global String userType;
        global String createdDate;
        global String lastModifiedDate;
        global String companyName;
        global String message;
        
        global UserResponse(User user) {
            this.id = user.Id;
            this.username = user.Username;
            this.email = user.Email;
            this.firstName = user.FirstName;
            this.lastName = user.LastName;
            this.title = user.Title;
            this.department = user.Department;
            this.phone = user.Phone;
            this.mobilePhone = user.MobilePhone;
            this.isActive = user.IsActive;
            this.userType = user.UserType;
            this.createdDate = user.CreatedDate != null ? user.CreatedDate.format() : null;
            this.lastModifiedDate = user.LastModifiedDate != null ? user.LastModifiedDate.format() : null;
            this.companyName = user.CompanyName;
            this.message = 'User information retrieved successfully';
        }
    }
    
    /**
     * Wrapper class for error response
     */
    global class ErrorResponse {
        global Integer statusCode;
        global String status;
        global String message;
        
        global ErrorResponse(Integer code, String statusMsg, String errorMsg) {
            this.statusCode = code;
            this.status = statusMsg;
            this.message = errorMsg;
        }
    }
}