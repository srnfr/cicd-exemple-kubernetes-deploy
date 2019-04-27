#! /bin/bash
# exit script when any command ran here returns with non-zero exit code
set -e


### SRN BYPASS ####
#exit
####################

COMMIT_SHA1=$CIRCLE_SHA1

# We must export it so it's available for envsubst
export COMMIT_SHA1=$COMMIT_SHA1

# since the only way for envsubst to work on files is using input/output redirection,
#  it's not possible to do in-place substitution, so we need to save the output to another file
#  and overwrite the original with that one.
envsubst <./kube/cicd-deployment.yml >./kube/cicd-deployment.yml.out
mv ./kube/cicd-deployment.yml.out ./kube/cicd-deployment.yml

echo "$KUBERNETES_CLUSTER_CERTIFICATE" | base64 --decode > cert.crt

echo "Debug"
echo "---"
cat cert.crt
echo "---"
echo "SERVER = $KUBERNETES_SERVER"
echo "TOKEN = $KUBERNETES_TOKEN"
echo "---"

./kubectl --v 6 \
  --kubeconfig=/dev/null \
  --server=$KUBERNETES_SERVER \
  --certificate-authority=cert.crt \
  --token=$KUBERNETES_TOKEN \
  apply -f ./kube/
