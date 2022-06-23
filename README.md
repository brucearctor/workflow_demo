

## TO RUN:
...
1) Ensure gcloud installed, and authenticated ex: `gcloud init...` 
  ( where you have a project that you have sufficient permissions into )
2) Ensure cloudbuild api enabled and also artifactregistry and cloudfunctions, ex in console or via 
  `gcloud services enable cloudbuild.googleapis.com cloudfunctions.googleapis.com artifactregistry.googleapis.com run.googleapis.com`
3) clone this repo ...
4) cd into `shipping` directory
5) update project_id ( replace $PROJECT_ID, ex: affable-context-292903 with your project name ) 
  in 3 spots in the cloudbuild.yaml file
6) run `gcloud builds submit --region=us-central1` to use cloud build to build and push image **
7) cd into `terraform` directory ( `../teraform/` from location of last step )
8) update projectnumber in main.tf
   (project number can be retrieved via `gcloud projects list --format="json" | jq
   -c '.[] | select(.projectId | contains("$PROJECT_ID")).projectNumber'   
   `)
```
variable "projectnumber" {
  type    = string
  default = "CHANGE_TO_YOUR_PROJECTNUMBER"
}
```
9) update project name in main.tf 
```
variable "project" {
  type    = string
  default = "CHANGE_TO_YOUR_PROJECT"
}
```
6) Run `terraform apply`, type `yes`, etc...
7) Looks like `gcloud functions ... ` isn't ready for gen2 functions --
   so needing to go into the console to find the address to invoke
* get the address for 'starting_point' from the console, an example command:
  ( found in cloud functions console, `testing` tab.
```aidl
curl -m 40 -X POST https://starting-point-htyoftei4q-uc.a.run.app \
-H "Authorization:bearer $(gcloud auth print-identity-token)" \
-H "Content-Type:application/json" \
-d '{
  "name": "Hello World"
}'
```

8) Check logs for workflows ...  Specifically will need to get the logs for the url for the callback, trigger.

9) Run curl for that to unblock ( ex: package shipped )
```aidl
curl -X PUT -H "Content-Type: application/json" -d '{"tracking_info": "ABC123"}' -H "Authorization: Bearer $(gcloud auth print-access-token)" $CALLBACK_URI_FOUND_IN_LOGS_FOR_NOW
```



#### Notes:
**  cloud build was needed since I was running on a M1 Mac.

*** I like gRPC, but that isn't supported via Workflows.  I thought about using gRPC Gateway for transcoding, but
  that seemed like overkill [ unless the service would also be used from other contexts ]. I also didn't think it  
  would be very 


### TODO:

* TESTING!  LOTS!  

* Add logging (ex: to BigQuery ) between steps/events, to be able to run queries, in case of failures, etc

* change initial data object to be more than 'name'

* pass around fuller object as well.  

* not commit tfstate :-) / remove ... but better to not have public.

* Change project variable, and/or add scripts ex: `sed ...` to update for ease-of-use.

* Terraform variables/names cleanup ... implimented whatever to first get things working

* Internal ingress only for relevant services

* How sensitive is data... ServicePerimeter?

* File naming and modules