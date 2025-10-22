install.packages(c("httr", "jsonlite"))
install.packages("clipr")
library(httr)
library(clipr)
library(jsonlite)
url <- "jsonliteurl" <- "https://api.powerflex.io/login"

payload <- "{\"username\":\"ajwong@ucsd.edu\",\"password\":\"Byddolphin1!\"}"
encode <- "json"
response <- VERB("POST", url, body = payload, content_type("application/json"), accept("application/json"), encode = encode)
content(response, "text")
# Parse the response
response_content <- content(response, "text")
parsed <- fromJSON(response_content)
#Tokens expire after 30 min.
# Access the token (assuming it's named 'token' or 'access_token')
api_token <- parsed$access_token
write_clip(api_token)

#Get ACN and ACCs
url <- "https://api.powerflex.io/v1/public/get-my-acn-accs"
auth_header <- paste("Bearer", api_token)
response_acn <- VERB("GET", url, add_headers('authorization' = auth_header), content_type("application/octet-stream"), accept("application/json"))
response_content_acn <- content(response_acn, "text")
parsed_acns <- fromJSON(response_content_acn)

for (acc in parsed_acns$acc) {
  site_url <- paste0("https://api.powerflex.io/v1/public/stations/acn/0051/acc/", acc)
  response_site <- VERB("GET", site_url, add_headers('authorization' = auth_header), content_type("application/octet-stream"), accept("application/json"))
  content(response_evse, "text")
  # Get current time in milliseconds since epoch
  now_ms <- as.numeric(Sys.time()) * 1000
  
  # Calculate cutoff: 30 days ago in milliseconds
  cutoff_ms <- now_ms - (30 * 24 * 60 * 60 * 1000)
  
  # Filter and extract pfid + parking_space
  filtered <- lapply(evse_data, function(evse) {
    if (!is.null(evse$last_online_timestamp) && evse$last_online_timestamp > cutoff_ms) {
      return(list(pfid = evse$pfid, parking_space = evse$parking_space))
    } else {
      return(NULL)
    }
  })
  
  # Remove NULLs
  filtered <- Filter(Negate(is.null), filtered)
  
  # View result
  print(filtered)
  
  
  site_request <- list(
    acn_id = parsed_acns$acn,  # assuming this is a scalar or same length as acc
    acc_id = acc,
    site_url = site_url
  )
}


#Get EVSEs
#url <- "https://api.powerflex.io/v1/public/acn/acn/acc/acc/evses"
#response_evse <- VERB("GET", url, add_headers('authorization' = auth_header), content_type("application/octet-stream"), accept("application/json"))
#evses<- content(response_evse, "text")
#parsed_evses <- fromJSON(evses)
#site data retrieval
#url <- "https://api.powerflex.io/v1/public/site_metadata/acn/0051/acc/30"
#response <- VERB("GET", url, add_headers('authorization' = auth_header), content_type("application/octet-stream"), accept("application/json"))
#content(response, "text")
#Request Site details