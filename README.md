### Bacula Backup

  Bacula is an enterprise level backup tool which also works great for home lab environments. Deploing Bacula Backup services on a Kubernetes cluster adds flexability along with the ability to scale to match the current workload. 

Work in progress readme. 

# Requirements

Before deploying the PODs we need to build an image to be used with Kubernetes. This will require either Docker or Podman to build the container image. 

In the following example I am building the container image using podman and specifying a local container registry.

```podman build -t localhost:32000/bacula:15.0.2 .```

Push the image to the local container registry once the build is finished

```podman push localhost:32000/bacula:15.0.2```


Using Buildah
```yum -y install buildah```
```buildah bud -t bacula:15.0.2```

Kubernetes 

The following will deploy K3S with Calico CNI

Deploy K3S CLuster


curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="--flannel-backend=none --cluster-cidr=172.16.0.0/16 --disable-network-policy --disable=traefik,local-storage,metrics-server" sh -

cp /etc/rancher/k3s/k3s.yaml ~/.kube/config

Install Calico Network CNI

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/tigera-operator.yaml

Use the following Installationm Resource to install Calico

kubectl create -f - <<EOF
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  # Configures Calico networking.
  registry: quay.io/
  calicoNetwork:
    ipPools:
    - blockSize: 26
      cidr: 172.16.0.0/16
      encapsulation: VXLAN
      natOutgoing: Enabled
      nodeSelector: all()
EOF

    OR

```snap install microk8s --classic``` 


packages:

python3-kubernetes

# bacula


Deploy Bacula on Kubernetes using Postgres Database

```
kubectl apply -f bacula-postgres-all.yaml -n bacula
```
Once postgres is deployed create the Bacula database tables using the make_postgresql_tables script


```
kubectl cp make_postgresql_tables bacula-postgres-66d96886dd-54mt6:/ -n bacula
kubectl exec -n bacula -ti bacula-postgres-66d96886dd-54mt6 -- bash /make_postgresql_tables
Password for user bacula: 
```
Once the tables are created depkloy the Bacula Director

```
kubectl apply -f bacula-dir-all.yaml -n bacula
```

Verify Bacula Director started successfully

```
kubectl logs bacula-dir-8ff6cdfc8-rrbrc -n bacula 
```

Deploy the Bacula Storage Daemon

```
kubectl apply -f bacula-sd-all.yaml
```

For testing deploy the Bacula File Daemon

```
kubectl apply -f bacula-fd-all.yaml -n bacula
```
