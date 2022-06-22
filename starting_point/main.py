import os
import sys
from flask import escape
import functions_framework
import message_pb2
from google.protobuf import json_format

from google.cloud import workflows_v1beta
from google.cloud.workflows.executions_v1beta.types import executions

from google.cloud.workflows.executions_v1beta.services.executions import ExecutionsClient
from google.cloud.workflows.executions_v1beta.types import CreateExecutionRequest, Execution
import json

@functions_framework.http
def starting_point(request):

    project = os.environ['GCP_PROJECT']
    location = os.environ['FUNCTION_REGION']
    # COULD PASS IN DIFFERENT WORKFLOWS in the request, etc
    workflow = os.environ['WORKFLOW_NAME']

    request_json = request.get_json(silent=True)

    message = None
    try:
        message = json_format.ParseDict(request_json, message_pb2.Order())
    except Exception as e:
        # I ALSO LIKE 418 :-)
        # 400 was chosen, but 422 seems also OK
        # CHOSE TO 'reject' rather than process/salvage 'bad' data
        return "Bad Data", 400

    execution_client = ExecutionsClient()

    parent = "projects/{}/locations/{}/workflows/{}".format(project, location, workflow)
    execution = Execution(argument = json_format.MessageToJson(message))
    
    response = None
    try:
        response = execution_client.create_execution(request={"parent": parent, "execution":execution})
    except Exception as e:
        print(e)
        return "Error occurred when triggering workflow execution", 500

    #LOG TO BQ BEFORE RETURNING/COMPLETING?
    return "OK", 200
