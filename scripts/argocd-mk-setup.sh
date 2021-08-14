# commands to setup argocd after initial deployment.
# TODO currently does not contain things like certificate management (e.g. browser will throw cert error when accessing ui)
# this assumes kubectl is installed and correctly points to a k8s cluster
# slightly modified, but majority is taken from https://argoproj.github.io/argo-cd/getting_started/

mkdir argocd-infra
cd argocd-infra || exit

# create namespace manifest ('kubectl create namespace argocd' would also do this)
echo "apiVersion: v1\nkind: Namespace\nmetadata:\n\tname: argocd" >> argocd-ns.yml

# apply ns definition
kubectl apply argocd-ns.yml

# download argocd k8s manifest
curl https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml >> argocd.yml

# apply it
kubectl apply argocd.yml

# create a load balancer, if you are on minikube a second shell running 'minikube tunnel' is required
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'



# login to argocd server at minikube ip with default port 31617 for https://
argocd login "$(minikube ip)":31617  --username admin --password "$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2)"

# set password. Command opens stdin for the user to set the password
argocd account update-password
