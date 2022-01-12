#! /bin/bash
# First argument is GCP_PROJECT_ID
# Second argument SERVICE_ACCOUNT_EMAIL
# Third GCP_SERVICE_ACCOUNT_ROLES

# script crashes if any command fails
set -e

# Read environment variables
SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
PROJECT_PATH="$(dirname $SCRIPT_PATH)"
ENV_PATH="$PROJECT_PATH/.env"
source $ENV_PATH

echo "Adding roles for project $GCP_PROJECT_ID and service account $GCP_SERVICE_ACCOUNT_EMAIL..."

# Add roles to service account
for role in ${GCP_SERVICE_ACCOUNT_ROLES} ; do\
    echo "Now at role $role..."

    gcloud projects add-iam-policy-binding\
      $GCP_PROJECT_ID\
      --member="serviceAccount:${GCP_SERVICE_ACCOUNT_EMAIL}"\
      --role=${role}
done

echo "Role adding completed successfully."
