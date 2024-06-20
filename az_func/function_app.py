import azure.functions as func
import datetime
import json
import logging

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)


@app.function_name(name="Healthcheck")
@app.route(route="healthcheck")
def main(req: func.HttpRequest) -> func.HttpResponse:
    return func.HttpResponse(status_code=200)


@app.function_name(name="HttpTrigger1")
@app.route(route="req")
def main(req: func.HttpRequest) -> str:
    user = req.params.get("user")
    return f"Hello, {user}!"
