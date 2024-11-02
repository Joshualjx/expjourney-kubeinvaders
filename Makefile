kubernetes-version?=v1.26.3
driver?=docker
memory?=2048
cpu?=2
nodes?=1

.PHONY: helm-prep
helm-prep:
	helm repo add kubeinvaders https://lucky-sideburn.github.io/helm-charts/ && helm repo update

.PHONY: init-cluster
init-cluster:
	minikube start \
        --kubernetes-version $(kubernetes-version) \
        --driver $(driver) \
        --memory $(memory) \
        --cpus $(cpu) \
        --nodes $(nodes) \
        --embed-certs  \
		--static-ip 10.211.55.70


.PHONY: setup-cluster
setup-cluster: 
	kubectl apply -f manifests && helm install kubeinvaders --set-string config.target_namespace="namespace1" \
	-n kubeinvaders kubeinvaders/kubeinvaders --set ingress.enabled=true --set ingress.hostName=kubeinvaders.local --set deployment.image.tag=v1.9.6 && kubectl set env deployment/kubeinvaders INSECURE_ENDPOINT=true -n kubeinvaders \
	&& minikube addons enable ingress

.PHONY: set-hostname
set-hostname: 
	echo -n "10.211.55.70 " | sudo tee -a /etc/hosts && echo "kubeinvaders.local" | sudo tee -a /etc/hosts && echo -n "10.211.55.70 " | sudo tee -a /etc/hosts && echo "nginx.local" | sudo tee -a /etc/hosts 

.PHONY: setup
setup: init-cluster setup-cluster set-hostname

.PHONY: delete-cluster
delete-cluster: 
	minikube delete





