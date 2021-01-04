# Hands-on Kubernetes-07 : Kustomize 

Purpose of the this hands-on training is to give students the knowledge of kustomize tool in kubernetes.

## Learning Outcomes

At the end of the this hands-on training, students will be able to;

- Learn uses of kustomize tool in Kubernetes

## Outline

- Part 1 - Setting up the Kubernetes Cluster

- Part 2 - Overview of Kustomize

- Part 3 - Setting cross-cutting fields for resources

- Part 4 - Composing and customizing collections of resources

## Part 1 - Setting up the Kubernetes Cluster

- Launch a Kubernetes Cluster of Ubuntu 20.04 with two nodes (one master, one worker) using the [Cloudformation Template to Create Kubernetes Cluster](./cfn-template-to-create-k8s-cluster.yml). *Note: Once the master node up and running, worker node automatically joins the cluster.*

>*Note: If you have problem with kubernetes cluster, you can use this link for lesson.*
>https://www.katacoda.com/courses/kubernetes/playground

- Check if Kubernetes is running and nodes are ready.

```bash
kubectl cluster-info
kubectl get node
```

## Part 2 - Overview of Kustomize

Kustomize is a tool for customizing Kubernetes configurations. It has the following features to manage application configuration files:

- setting cross-cutting fields for resources

- composing and customizing collections of resources

- generating resources from other sources

## Part 3 - Setting cross-cutting fields for resources

- It is quite common to set cross-cutting fields for all Kubernetes resources in a project. Some use cases for setting cross-cutting fields:
  - setting the same namespace for all Resources
  - adding the same name prefix or suffix
  - adding the same set of labels
  - adding the same set of annotations

- Create a folder and name it `kustomization-lesson`.

```bash
mkdir kustomization-lesson && cd kustomization-lesson
```

- Create another folder in kustomization-lesson and name it `cross-cutting-example`.

```bash
mkdir cross-cutting-example && cd cross-cutting-example
```

- Create a deployment.yaml and kustomization.yaml.

```bash
cat <<EOF >./deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
EOF

cat <<EOF >./kustomization.yaml
namespace: my-namespace
namePrefix: dev-
nameSuffix: "-001"
commonLabels:
  app: bingo
commonAnnotations:
  oncallPager: 800-555-1212
resources:
- deployment.yaml
EOF
```

- Run kubectl kustomize ./ to view those fields are all set in the Deployment Resource.

```bash
kubectl kustomize ./
```

- We get an output like below.

```bash
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    oncallPager: 800-555-1212
  labels:
    app: bingo
  name: dev-nginx-deployment-001
  namespace: my-namespace
spec:
  selector:
    matchLabels:
      app: bingo
  template:
    metadata:
      annotations:
        oncallPager: 800-555-1212
      labels:
        app: bingo
    spec:
      containers:
      - image: nginx
        name: nginx
```

- Firstly run `kubectl apply -f` command to create deployment.

```bash
kubectl apply -f .
```

- After that, create a namespace name it "my-namespace".

```bash
kubectl create namespace my-namespace
```

- Then, run `kubectl apply -k` command to create deployment.

```bash
kubectl apply -k .
```

- List the deployment in all namespaces and notice that there are two different deployments in different namesapaces.

```bash
kubectl get deploy --all-namespaces
```

- We get an output like below. Pay attention the names and namespaces of the deployments.

```bash
NAMESPACE              NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
default                nginx-deployment            1/1     1            1           6m17s
my-namespace           dev-nginx-deployment-001    1/1     1            1           2m41s
```

- Delete deployments.

```bash
kubectl delete -f .
kubectl delete -k .
```

## Part 4 - Composing and customizing collections of resources

It is common to compose a set of Resources in a project and manage them inside the same file or directory. Kustomize offers composing Resources from different files and applying patches or other customization to them.

### Composing 

Kustomize supports composition of different resources. The resources field, in the kustomization.yaml file, defines the list of resources to include in a configuration. Set the path to a resource's configuration file in the resources list.

- Create a folder in kustomization-lesson and name it `composing-example`.

```bash
mkdir composing-example && cd composing-example
```

- Create a deployment.yaml, a service.yaml and  a kustomization.yaml.

```bash
# Create a deployment.yaml file
cat <<EOF > deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-nginx
spec:
  selector:
    matchLabels:
      run: my-nginx
  replicas: 2
  template:
    metadata:
      labels:
        run: my-nginx
    spec:
      containers:
      - name: my-nginx
        image: nginx
        ports:
        - containerPort: 80
EOF

# Create a service.yaml file
cat <<EOF > service.yaml
apiVersion: v1
kind: Service
metadata:
  name: my-nginx
  labels:
    run: my-nginx
spec:
  ports:
  - port: 80
    protocol: TCP
  selector:
    run: my-nginx
EOF

# Create a kustomization.yaml composing them
cat <<EOF >./kustomization.yaml
resources:
- deployment.yaml
- service.yaml
EOF
```

- Run `kubectl kustomize ./` to view the Resources from kubectl kustomize ./ contain both the Deployment and the Service objects.

```bash
kubectl kustomize ./
```

- Run `kubectl apply -k` command to create both the Deployment and the Service objects.

```bash
kubectl apply -k .

service/my-nginx created
deployment.apps/my-nginx created
```

- Delete the Deployment and the Service objects.

```bash
kubectl delete -k .

service "my-nginx" deleted
deployment.apps "my-nginx" deleted
```

### Customizing  

Patches can be used to apply different customizations to Resources. The names inside the patches must match Resource names that are already loaded. 

- Create a folder in kustomization-lesson and name it `customizing-example`.

```bash
mkdir customizing-example && cd customizing-example
```

- Create a deployment.yaml, a patch increase_replicas.yaml, another patch set_memory.yaml and  a kustomization.yaml.

```bash
# Create a deployment.yaml file
cat <<EOF > deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-nginx
spec:
  selector:
    matchLabels:
      run: my-nginx
  replicas: 2
  template:
    metadata:
      labels:
        run: my-nginx
    spec:
      containers:
      - name: my-nginx
        image: nginx
        ports:
        - containerPort: 80
EOF

# Create a patch increase_replicas.yaml
cat <<EOF > increase_replicas.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-nginx
spec:
  replicas: 3
EOF

# Create another patch set_memory.yaml
cat <<EOF > set_memory.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-nginx
spec:
  template:
    spec:
      containers:
      - name: my-nginx
        resources:
        limits:
          memory: 512Mi
EOF

cat <<EOF >./kustomization.yaml
resources:
- deployment.yaml
patches:
- increase_replicas.yaml
- set_memory.yaml
EOF
```

- Run `kubectl kustomize ./` to view the Deployment.

```bash
kubectl kustomize ./

apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      run: my-nginx
  template:
    metadata:
      labels:
        run: my-nginx
    spec:
      containers:
      - image: nginx
        limits:
          memory: 512Mi
        name: my-nginx
        ports:
        - containerPort: 80
```

In addition to patches, Kustomize also offers customizing container images or injecting field values from other objects into containers without creating patches. For example, you can change the image used inside containers by specifying the new image in images field in kustomization.yaml.

- Update the kustomization.yaml as below.

```bash
resources:
- deployment.yaml
images:
- name: nginx
  newName: my.image.registry/nginx
  newTag: 1.4.0
```

- Run `kubectl kustomize ./` to see that the image being used is updated.

```bash
kubectl kustomize ./

apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      run: my-nginx
  template:
    metadata:
      labels:
        run: my-nginx
    spec:
      containers:
      - image: my.image.registry/nginx:1.4.0
        name: my-nginx
        ports:
        - containerPort: 80
```

### Bases and Overlays

Kustomize has the concepts of bases and overlays. A base is a directory with a kustomization.yaml, which contains a set of resources and associated customization. A base could be either a local directory or a directory from a remote repo, as long as a kustomization.yaml is present inside. An overlay is a directory with a kustomization.yaml that refers to other kustomization directories as its bases. A base has no knowledge of an overlay and can be used in multiple overlays. An overlay may have multiple bases and it composes all resources from bases and may also have customization on top of them.

- Create a folder in kustomization-lesson and name it `base-example`.

```bash
mkdir base-example && cd base-example
```

-  Create a directory to hold the base.

```bash
mkdir base
```

- Create a base/deployment.yaml, base/service.yaml and base/kustomization.yaml files.

```bash
# Create a directory to hold the base
mkdir base
# Create a base/deployment.yaml
cat <<EOF > base/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-nginx
spec:
  selector:
    matchLabels:
      run: my-nginx
  replicas: 2
  template:
    metadata:
      labels:
        run: my-nginx
    spec:
      containers:
      - name: my-nginx
        image: nginx
EOF

# Create a base/service.yaml file
cat <<EOF > base/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: my-nginx
  labels:
    run: my-nginx
spec:
  ports:
  - port: 80
    protocol: TCP
  selector:
    run: my-nginx
EOF
# Create a base/kustomization.yaml
cat <<EOF > base/kustomization.yaml
resources:
- deployment.yaml
- service.yaml
EOF
```

- This base can be used in multiple overlays. We can add different namePrefix or other cross-cutting fields in different overlays.

- Create a dev and a prod folder and add kustomization.yaml to both of them.

```bash
mkdir dev
cat <<EOF > dev/kustomization.yaml
bases:
- ../base
namePrefix: dev-
EOF

mkdir prod
cat <<EOF > prod/kustomization.yaml
bases:
- ../base
namePrefix: prod-
EOF
```

- Run `kubectl kustomize ./dev` in `base-example folder` to see that the name of the deployment and the service change for dev folder.

```bash
kubectl kustomize ./dev

apiVersion: v1
kind: Service
metadata:
  labels:
    run: my-nginx
  name: dev-my-nginx
spec:
  ports:
  - port: 80
    protocol: TCP
  selector:
    run: my-nginx
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dev-my-nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      run: my-nginx
  template:
    metadata:
      labels:
        run: my-nginx
    spec:
      containers:
      - image: nginx
        name: my-nginx
```

- Run `kubectl kustomize ./prod` in `base-example folder` to see that the name of the deployment and the service change for prod folder.

```bash
kubectl kustomize ./prod

apiVersion: v1
kind: Service
metadata:
  labels:
    run: my-nginx
  name: prod-my-nginx
spec:
  ports:
  - port: 80
    protocol: TCP
  selector:
    run: my-nginx
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prod-my-nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      run: my-nginx
  template:
    metadata:
      labels:
        run: my-nginx
    spec:
      containers:
      - image: nginx
        name: my-nginx
```