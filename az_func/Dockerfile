FROM mcr.microsoft.com/azure-functions/python:4-python3.11

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true

WORKDIR /app

RUN apt-get update &&\
    apt-get install libreoffice -y &&\
    apt-get clean -y

COPY requirements.txt requirements.txt
RUN pip install --no-cache --upgrade pip && \
    pip install --no-cache -r requirements.txt
COPY setup.py setup.py
COPY template_populator template_populator
RUN pip install -e .

COPY az_func/* /home/site/wwwroot/
