
## TO RUN:

1) Ensure gcloud installed, and authenticated ( where you have a project that you have sufficient permissions into )

2) clone this repo ...

3) cd into `terraform` directory

4) update project name in main.tf 

```
variable "project" {
  type    = string
  default = "CHANGE_TO_YOUR_PROJECT"
}
```

5) Run `terraform apply`, type `yes`, etc...

6) Looks like `gcloud functions ... ` isn't ready for gen2 functions --
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

7) Check logs for workflows ...  Specifically will need to get the logs for the url for the callback, trigger.

8) Run curl for that to unblock ( ex: package shipped )
```aidl

```


### TODO:

* Add logging (ex: to BigQuery ) between steps/events, to be able to run queries, in case of failures, etc

* change data object to be more than 'name' 

* not commit tfstate :-) / remove ... but better to not have public.

* Change project variable, and/or add `sed -i ...` script/command to update for ease-of-use.

* Terraform variables/names cleanup ... implimented whatever to first get things working

*** IMPORTANT: Problem with Terraform Cloud Functions Gen2 ... 
I failed to get the `uri` parameter to pass into the gcp_workflow
for a specific step.  So, commented that step out.



