#Beacon API

On a successful authenticated request, an HTTP 2xx (usually HTTP 200) is returned with a response body.
On a response that was not authenticated, an HTTP 401 is returned with an error message.

##User Sessions

###Sign In

    # Request
    POST /api/v2/users/sessions
    {
      "user" : {
        "username" : <string>,
        "password" : <string>
      }
    }
    # Example
    curl -X POST --data "user[username]=user123&user[password]=password123" https://dispatch.trekmedics.org/api/v2/users/sessions/

The "sid" and "auth_token" are returned in the response to this request and must be used in subsequent requests.

###Sign Out

    # Request
    DELETE /api/v2/users/sessions?sid=<string>&auth_token=<string>
    # Example
    curl -X DELETE "https://dispatch.trekmedics.org/api/v2/users/sessions?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

##Incidents

###Index

    # Request
    GET /api/v2/incidents?filter<string>&sid=<string>&auth_token=<string>
    # filter parameter is optional, if "filter=active" then only active incidents are sent in the response
    # Example
    curl -X GET "https://dispatch.trekmedics.org/api/v2/incidents?filter=active&sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

###Show

    # Request
    GET /api/v2/incidents/:id?filter<string>&sid=<string>&auth_token=<string>
    # Example
    curl -X GET "https://dispatch.trekmedics.org/api/v2/incidents/1?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

###Message Log

    # Request
    GET /api/v2/incidents/:id/message_log?filter<string>&sid=<string>&auth_token=<string>
    # Example
    curl -X GET "https://dispatch.trekmedics.org/api/v2/incidents/1/message_log?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

###Create

    # Request
    POST /api/v2/incidents?sid=<string>&auth_token=<string>
    {
      "help_message" : <string>,
      "location" : <string>,
      "number_of_frs_to_allocate" : <integer>,
      "number_of_transport_vehicles_to_allocate" : <integer>,
      "subcategory_id" : <integer>
    }
    # Example
    curl -X POST --data "help_message=Help Message&location=Location&number_of_frs_to_allocate=3&number_of_transport_vehicles_to_allocate=1&subcategory_id=1" "https://dispatch.trekmedics.org/api/v2/incidents?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

###Edit Comment

    # Request
    PATCH /api/v2/incidents/:id/edit_comment?sid=<string>&auth_token=<string>
    {
      "comment" : <string>
    }
    # Note: Replace ":id" in the path with the unquoted integer value of the id to be affected.
    # Example
    curl -X PATCH --data "comment=New Comment" "https://dispatch.trekmedics.org/api/v2/incidents/1/edit_comment?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

###Cancel Incident

    # Request
    POST /api/v2/incidents/:id/cancel_incident?sid=<string>&auth_token=<string>
    {
      "comment" : <string>
    }
    # Note: Replace ":id" in the path with the unquoted integer value of the id to be affected.
    # Example
    curl -X POST --data "comment=Cancellation Comment" "https://dispatch.trekmedics.org/api/v2/incidents/1/cancel_incident?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

###Destroy

    # Request
    DELETE /api/v2/incidents/:id?sid=<string>&auth_token=<string>
    # Note: Replace ":id" in the path with the unquoted integer value of the id to be affected.
    # Example
    curl -X DELETE "https://dispatch.trekmedics.org/api/v2/incidents/1?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

##First Responders

###Index

    # Request
    GET /api/v2/first_responders?sid=<string>&auth_token=<string>
    # Example
    curl -X GET "https://dispatch.trekmedics.org/api/v2/first_responders?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

###Create

    # Request
    POST /api/v2/first_responders?sid=<string>&auth_token=<string>
    {
      "name" : <string>,
      "phone_number" : <string>,
      "locale" : <string>,
      "transportation_mode" : <integer>
    }
    # Example
    curl -X POST --data "name=First Last&phone_number=%2B15555555555&locale=en&transportation_mode=1" "https://dispatch.trekmedics.org/api/v2/first_responders?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

###Update

    # Request
    PATCH /api/v2/first_responders/:id?sid=<string>&auth_token=<string>
    {
      "name" : <string>,
      "phone_number" : <string>,
      "locale" : <string>,
      "transportation_mode" : <integer>
    }
    # Note: Replace ":id" in the path with the unquoted integer value of the id to be affected.
    # Example
    curl -X PATCH --data "name=First M. Last&phone_number=%2B15555555558&locale=es&transportation_mode=1" "https://dispatch.trekmedics.org/api/v2/first_responders/202?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

###Destroy

    # Request
    DELETE /api/v2/first_responders/:id?sid=<string>&auth_token=<string>
    # Note: Replace ":id" in the path with the unquoted integer value of the id to be affected.
    # Example
    curl -X DELETE "https://dispatch.trekmedics.org/api/v2/first_responders/202?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

###Performance Report

    # Request
    GET /api/v2/first_responders/:id/performance_report?sid=<string>&auth_token=<string>
    # Example
    curl -X GET "https://dispatch.trekmedics.org/api/v2/first_responders/1/performance_report?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

###Log In

    # Request
    POST /api/v2/first_responders/:id/log_in?sid=<string>&auth_token=<string>
    # Example
    curl -X POST "https://dispatch.trekmedics.org/api/v2/first_responders/1/log_in?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

###Log Out

    # Request
    POST /api/v2/first_responders/:id/log_out?sid=<string>&auth_token=<string>
    # Example
    curl -X POST "https://dispatch.trekmedics.org/api/v2/first_responders/1/log_out?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

##Hospitals

###Index

    # Request
    GET /api/v2/hospitals?sid=<string>&auth_token=<string>
    # Example
    curl -X GET "https://dispatch.trekmedics.org/api/v2/hospitals?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

###Create

    # Request
    POST /api/v2/hospitals?sid=<string>&auth_token=<string>
    {
      "name" : <string>
      "address" : <string>
    }
    # Example
    curl -X POST --data "name=Hospital 1&address=Guadalajara" "https://dispatch.trekmedics.org/api/v2/hospitals?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

###Update

    # Request
    PATCH /api/v2/hospitals/:id?sid=<string>&auth_token=<string>
    {
      "name" : <string>
      "address" : <string>
    }
    # Note: Replace ":id" in the path with the unquoted integer value of the id to be affected.
    # Example
    curl -X PATCH --data "name=Hospital 1&address=Guadalajara" "https://dispatch.trekmedics.org/api/v2/hospitals/2?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

###Destroy

    # Request
    DELETE /api/v2/hospitals/:id?sid=<string>&auth_token=<string>
    # Example
    curl -X DELETE "https://dispatch.trekmedics.org/api/v2/hospitals/2?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

##Medical Doctors

###Index

    # Request
    GET /api/v2/medical_doctors?sid=<string>&auth_token=<string>
    # Example
    curl -X GET "https://dispatch.trekmedics.org/api/v2/medical_doctors?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

###Create

    # Request
    POST /api/v2/medical_doctors?sid=<string>&auth_token=<string>
    {
      "hospital_id" : <integer>,
      "name" : <string>,
      "phone_number" : <string>
    }
    # Example
    curl -X POST --data "hospital_id=3&name=Dr. Example&phone_number=%2B15555555558" "https://dispatch.trekmedics.org/api/v2/medical_doctors?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

###Update

    # Request
    PATCH /api/v2/medical_doctors/:id?sid=<string>&auth_token=<string>
    {
      "hospital_id" : <integer>,
      "name" : <string>,
      "phone_number" : <string>
    }
    # Note: Replace ":id" in the path with the unquoted integer value of the id to be affected.
    # Example
    curl -X PATCH --data "hospital_id=4&name=Dr. Example, MD&phone_number=%2B15555555550" "https://dispatch.trekmedics.org/api/v2/medical_doctors/7?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

###Destroy

    # Request
    DELETE /api/v2/medical_doctors/:id?sid=<string>&auth_token=<string>
    # Note: Replace ":id" in the path with the unquoted integer value of the id to be affected.
    # Example
    curl -X DELETE "https://dispatch.trekmedics.org/api/v2/medical_doctors/7?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

##Data Centers

###Index

    # Request
    GET /api/v2/data_centers?sid=<string>&auth_token=<string>
    # Example
    curl -X GET "https://dispatch.trekmedics.org/api/v2/data_centers?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

###Create

    # Request
    POST /api/v2/data_centers?sid=<string>&auth_token=<string>
    {
      "name" : <string>,
      "is_simulator" : <integer>
    }
    # Example
    curl -X POST --data "name=Data Center 1&is_simulator=0" "https://dispatch.trekmedics.org/api/v2/data_centers?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

###Update

    # Request
    PATCH /api/v2/data_centers/:id?sid=<string>&auth_token=<string>
    {
      "name" : <string>,
      "is_simulator" : <integer>
    }
    # Note: Replace ":id" in the path with the unquoted integer value of the id to be affected.
    # Example
    curl -X PATCH --data "name=Data Center 2&is_simulator=1" "https://dispatch.trekmedics.org/api/v2/data_centers/4?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

###Destroy

    # Request
    DELETE /api/v2/data_centers/:id?sid=<string>&auth_token=<string>
    # Note: Replace ":id" in the path with the unquoted integer value of the id to be affected.
    # Example
    curl -X DELETE "https://dispatch.trekmedics.org/api/v2/data_centers/4?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

##Users

###Index

    # Request
    GET /api/v2/users?sid=<string>&auth_token=<string>
    # Example
    curl -X GET "https://dispatch.trekmedics.org/api/v2/users?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

###Create

    # Request
    POST /api/v2/users?sid=<string>&auth_token=<string>
    {
      "username" : <string>,
      "password" : <string>,
      "password_confirmation" : <string>,
      "user_role_id" : <integer>,
      "locale" : <string>,
      "data_center_id" : <integer>
    }
    # Example
    # Note: user_role_id: 1 = Admin, 2 = Manager, 3 = Dispatcher, 4 = Supervisor]
    curl -X POST --data "username=test_user&password=password123&password_confirmation=password123&user_role_id=3&locale=en&data_center_id=2" "https://dispatch.trekmedics.org/api/v2/users?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

###Update

    # Request
    PATCH /api/v2/users/:id?sid=<string>&auth_token=<string>
    {
      "username" : <string>,
      "password" : <string>,
      "password_confirmation" : <string>,
      "user_role_id" : <integer>,
      "locale" : <string>,
      "data_center_id" : <integer>
    }
    # Note: user_role_id: 1 = Admin, 2 = Manager, 3 = Dispatcher, 4 = Supervisor]
    # Note: Replace ":id" in the path with the unquoted integer value of the id to be affected.
    # Example
    curl -X PATCH --data "username=test_user1&password=password123&password_confirmation=password123&user_role_id=3&locale=es&data_center_id=2" "https://dispatch.trekmedics.org/api/v2/users/3?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

###Destroy

    # Request
    DELETE /api/v2/users/:id?sid=<string>&auth_token=<string>
    # Note: Replace ":id" in the path with the unquoted integer value of the id to be affected.
    # Example
    curl -X DELETE "https://dispatch.trekmedics.org/api/v2/users/3?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

##Settings

###Index

    # Request
    GET /api/v2/settings?sid=<string>&auth_token=<string>
    # Example
    curl -X GET "https://dispatch.trekmedics.org/api/v2/settings?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

###Update

    # Request
    PATCH /api/v2/settings/:id?sid=<string>&auth_token=<string>
    {
      "value" : <string>
    }
    # Note: Replace ":id" in the path with the unquoted integer value of the id to be affected.
    # Example
    curl -X PATCH --data "value=false" "https://dispatch.trekmedics.org/api/v2/settings/37?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

##Categories

###Index

    # Request
    GET /api/v2/categories?sid=<string>&auth_token=<string>
    # Example
    curl -X GET "https://dispatch.trekmedics.org/api/v2/categories?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

###Create

    # Request
    POST /api/v2/categories?sid=<string>&auth_token=<string>
    {
      "name" : <string>
    }
    # Example
    curl -X POST --data "name=Emergency Category" "https://dispatch.trekmedics.org/api/v2/categories?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

###Update

    # Request
    PATCH /api/v2/categories/:id?sid=<string>&auth_token=<string>
    {
      "name" : <string>
    }
    # Note: Replace ":id" in the path with the unquoted integer value of the id to be affected.
    # Example
    curl -X PATCH --data "name=Emergency Category 2" "https://dispatch.trekmedics.org/api/v2/categories/5?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

###Destroy

    # Request
    DELETE /api/v2/categories/:id?sid=<string>&auth_token=<string>
    # Note: Replace ":id" in the path with the unquoted integer value of the id to be affected.
    # Example
    curl -X DELETE "https://dispatch.trekmedics.org/api/v2/categories/5?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

##Subcategories

###Index

    # Request
    GET /api/v2/subcategories?sid=<string>&auth_token=<string>
    # Example
    curl -X GET "https://dispatch.trekmedics.org/api/v2/subcategories?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

###Create

    # Request
    POST /api/v2/subcategories?sid=<string>&auth_token=<string>
    {
      "category_id" : <integer>,
      "name" : <string>
    }
    # Example
    curl -X POST --data "category_id=1&name=Emergency Subcategory" "https://dispatch.trekmedics.org/api/v2/subcategories?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

###Update

    # Request
    PATCH /api/v2/subcategories/:id?sid=<string>&auth_token=<string>
    {
      "category_id" : <integer>,
      "name" : <string>
    }
    # Note: Replace ":id" in the path with the unquoted integer value of the id to be affected.
    # Example
    curl -X PATCH --data "name=Emergency Subcategory 2" "https://dispatch.trekmedics.org/api/v2/subcategories/18?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

###Destroy

    # Request
    DELETE /api/v2/subcategories/:id?sid=<string>&auth_token=<string>
    # Note: Replace ":id" in the path with the unquoted integer value of the id to be affected.
    # Example
    curl -X DELETE "https://dispatch.trekmedics.org/api/v2/subcategories/18?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

##Outgoing Messages

###Create

    # Request
    POST /api/v2/outgoing_messages?sid=<string>&auth_token=<string>
    {
      "first_responder_id" : <integer>,
      "message" : <string>
    }
    # Example
    curl -X POST --data "first_responder_id=1&message=Test Message" "https://dispatch.trekmedics.org/api/v2/outgoing_messages?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

##Unregistered Parties

###Index

    # Request
    GET /api/v2/unregistered_parties?sid=<string>&auth_token=<string>
    # Example
    curl -X GET "https://dispatch.trekmedics.org/api/v2/unregistered_parties?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

##Administrators

###Index

    # Request
    GET /api/v2/administrators?sid=<string>&auth_token=<string>
    # Example
    curl -X GET "https://dispatch.trekmedics.org/api/v2/administrators?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

###Create

    # Request
    POST /api/v2/administrators?sid=<string>&auth_token=<string>
    {
      "name" : <string>,
      "phone_number" : <string>,
      "email" : <string>,
      "data_center_id" : <integer>
    }
    # Example
    curl -X POST --data "name=Test User&phone_number=%2B15555555555&email=test@example.com&data_center_id=1" "https://dispatch.trekmedics.org/api/v2/administrators?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

###Update

    # Request
    PATCH /api/v2/administrators/:id?sid=<string>&auth_token=<string>
    {
      "name" : <string>,
      "phone_number" : <string>,
      "email" : <string>,
      "data_center_id" : <integer>
    }
    # Example
    curl -X PATCH --data "name=Test User&phone_number=%2B15555555555&email=test@example.com&data_center_id=1" "https://dispatch.trekmedics.org/api/v2/administrators/1?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

###Destroy

    # Request
    DELETE /api/v2/administrators/:id?sid=<string>&auth_token=<string>
    # Example
    curl -X DELETE "https://dispatch.trekmedics.org/api/v2/administrators/1?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

##Alerts

###Index

    # Request
    GET /api/v2/alerts?sid=<string>&auth_token=<string>
    # Example
    curl -X GET "https://dispatch.trekmedics.org/api/v2/alerts?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

##Dispatch Phone Numbers

###Index

    # Request
    GET /api/v2/dispatch_phone_numbers?sid=<string>&auth_token=<string>
    # Example
    curl -X GET "https://dispatch.trekmedics.org/api/v2/dispatch_phone_numbers?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

###Create

    # Request
    POST /api/v2/dispatch_phone_numbers?sid=<string>&auth_token=<string>
    {
      "name" : <string>,
      "phone_number" : <string>,
      "data_center_id" : <integer>
    }
    # Example
    curl -X POST --data "name=Test Dispatcher&phone_number=%2B15555555555&data_center_id=1" "https://dispatch.trekmedics.org/api/v2/dispatch_phone_numbers?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

###Update

    # Request
    PATCH /api/v2/dispatch_phone_numbers/:id?sid=<string>&auth_token=<string>
    {
      "name" : <string>,
      "phone_number" : <string>,
      "data_center_id" : <integer>
    }
    # Example
    curl -X PATCH --data "name=Test Dispatcher&phone_number=%2B15555555555&data_center_id=1" "https://dispatch.trekmedics.org/api/v2/dispatch_phone_numbers/1?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"

###Destroy

    # Request
    DELETE /api/v2/dispatch_phone_numbers/:id?sid=<string>&auth_token=<string>
    # Example
    curl -X DELETE "https://dispatch.trekmedics.org/api/v2/dispatch_phone_numbers/1?sid=B3cc1a4860b9ab28224d1f03d0f2a6f67&auth_token=04c96c4e0111db4df0732f35c4f42ac6"
