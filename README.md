# Machine Learning API
Recently, Cloud Platforms have introduced tools that abstract away components of
the Machine Learning ecosystem. One of such components is the model API: the endpoint
where the world can interact with the model in real time.

To learn what goes on under the hood of such endpoints, I wanted to build an API myself.
I used the following tools:
- a joblib-serialized model
- an API with Flask
- a uWSGI web server
- a Docker container
- a Makefile to execute repetitive commands
- a .env file to store configuration in a single place
    - the .env file is excluded from version control, but you can see the required list of variables in example.env
- a Bash terminal (but any UNIX-like shell will do)

I am used to working with GCP, so I decided to use:
- the Google Cloud SDK to connect locally to GCP
- a service account + key to operate the deployment with minimal IAM credentials
    - the key in stored in /secrets, but excluded from version control
- a web endpoint hosted by GCP Cloud Run

If you want, you can use this repo to launch your own models to Google Cloud Platform: just follow the
steps in this README.

Still, the set-up is far from ideal. In general, I recommend Data Scientists to use the
abstraction tools (like AI platform) instead of building your own API's.

In the future, I will add a section on how to deploy to AI Platform/Vertex AI for comparison.

Enjoy the read!

* Free software: MIT license

# Usage

## Setting up GCP
If you are new to GCP:
- make an account
- Set up billing
    - In January 2022, you got 300 dollars as free trial. After the trial amount runs out,
GCP will ask you to enable billing before charging you anything
- Download and install the [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- Initialize the SDK by executing
``gcloud init``
- Think of a project ID for your GCP project. Fill in the project ID in the .env file
and read load its contents into your terminal session
``source .env``
From now on, whenever you add variables to .env make sure to read the file afterwards.
- Create a new project
``gcloud projects create $GCP_PROJECT_ID``

If you are not sure if SDK operations were completed successfully, you can always check
in Cloud Console (make sure you've selected the right project).

## Setting up the GCP service account
To avoid accidentally starting/stopping services on different projects, we will create a new GCP service
account that only has the minimal roles required for model deployment.
- Think of a name for you service account (e.g. "machine-learning-api")
- Add the GCP_SERVICE_ACCOUNT_NAME variable to the .env file. Remember to read the .env variables by repeating
``source .env``
- Just to be sure, check if the SDK is logged into the right account by running
``make check-gcp-login``
- Create a service account by running
``make create-service-account``
- Add the roles to the services account
``make add-roles``
- Create a key, so that you can locally use the service account (and no longer your "god-account").
Run
``make create-key``
- Create a new SDK configuration for the service account and connect it to the service account's key.
``make create-config``
- As a final check, run `make check-gcp-login` to make sure the SDK is logged in with the right account.

## Testing the API locally
To run the API locally, you must have Docker installed. You also need a model that is stored as .joblib.
Next:
- Think of a name for your docker project, and set it in .env as DOCKER_PROJECT
- Store the model you want to deploy as models/latest.joblib (see TODOS for note on this design)
- Build the docker image with `make build-image`
    - the .dockerignore will make sure sensitive information (like secrets and the .env file) are
not inside the build context
- Start up a container with `make run-container`
    - You should now be able to access the API throught your webbrowser at http://localhost:$OS_PORT
- To test, you can send a POST request (e.g. with Postman) containing a datasample
TODO: screenshot here
- If all works as expected, shut down the container
`docker ps`
`docker stop image_id_of_running_container`

## Deploying to Cloud Run
Now, we are ready to start the deployment.

### Uploading to Container Registry
First, we must upload the Docker image
to GCP Container Registry.
- configure Docker so that it can do this for us
`make conf-docker-for-gcp`
- Then send the image to Container Registry
`make image-to-gcp`

### Starting Cloud Run
Finally, we tell GCP to take the image from Container Registry
and run the correspdonding container with Cloud Run.

WARNING: By default, the endpoint can be accessed by anyone!
If you want to restrict ingress, make sure to modify the `deploy` command
in the Makefile.

If you want to deploy publically, do the following:
- Set the .env variables starting with CLOUD_RUN to configure the deployment
- Run `make deploy`

You will see a URL appear in your terminal. Click on it to make sure the deployment
was successful. In a similar fashion as in "Testing the API locally", we can
send a POST request to the endpoint.

You can also check the status through the command line by either
`make list-cloud-run` (still in beta) or `make describe-service`.

Cloud Run only incurs costs for the time that's consumed processing requests,
so not for the "uptime". Container registry is so cheap that it is practically free.

### Deleting all resources
To delete the deployment, simply execute
`make delete-deployment`

To delete the image, use
`make delete-latest-gcp-image`

# Developing
TODO: fill me in later

# TODO
- The API will load the model from the filesystem of the image. The downside is that you have to rebuild
the image every time you want to update the model. I see two solutions:
    - Use a Cloud Storage volume to load the model from
    - Create an endpoint to receive a model through POST request (or something similar)
- Add deployment to AI Platform/Vertex AI to show how much easier that is
