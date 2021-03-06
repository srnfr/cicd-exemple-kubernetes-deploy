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
echo "COMMIT_SHA1 = $COMMIT_SHA1"
echo "---"
echo "IMAGE dans KUBE MANIFESTS : \n $(grep image ./kube/cicd-deployment.yml)"
echo "---"
cat cert.crt
echo "---"
echo "SERVER = $KUBERNETES_SERVER"
echo "---"
echo "TOKEN = $KUBERNETES_TOKEN"
echo "---"
./kubectl --v 6 \
  --kubeconfig=/dev/null \
  --server=https://$KUBERNETES_SERVER \
  --certificate-authority=cert.crt \
  --token=$KUBERNETES_TOKEN \
  apply -f ./kube/
echo "Pause 5sec"
sleep 5
echo "LIST ALL IMAGES OF RUNNING PODS : "
./kubectl get pods -o=jsonpath={..image} | tr -s '[[:space:]]' '\n' |sort |uniq -c
