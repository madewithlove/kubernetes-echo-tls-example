.EPHONY: deploy

diff:
	kubectl diff -R -f applications/

deploy:
	kubectl apply -R -f applications/

install-helm:
	kubectl create serviceaccount tiller --namespace kube-system
	kubectl create -f tiller.yaml
	helm init --service-account tiller --upgrade
	helm repo add jetstack https://charts.jetstack.io

install-cert-manager:
	kubectl apply \
		-f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.6/deploy/manifests/00-crds.yaml
	kubectl label namespace kube-system certmanager.k8s.io/disable-validation="true"
	helm install --name cert-manager --namespace kube-system jetstack/cert-manager --version v0.8.0

install-ingress:
	helm install stable/nginx-ingress --name nginx-ingress --set controller.publishService.enabled=true

install-cert-manager-issuers:
	kubectl apply -f cert-manager/staging.yaml
	kubectl apply -f cert-manager/production.yaml

default: diff