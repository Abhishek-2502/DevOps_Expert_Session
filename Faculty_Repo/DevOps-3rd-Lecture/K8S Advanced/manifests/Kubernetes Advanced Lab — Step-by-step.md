Kubernetes Advanced Lab — Step-by-step Hands-on Manual

Hands-on practice of Kubernetes core concepts: Deployments, Services, PVC, ConfigMaps, Secrets, StatefulSets, Ingress, HPA.

Environment assumptions:

Docker installed and running.

Kubernetes CLI (kubectl) installed.

Minikube installed (or any local Kubernetes cluster).

Basic familiarity with terminal commands.

Folder structure (recommended):

<workspace>/
├─ manifests/


All YAML files will be stored in the manifests folder.

0) Cluster Setup

Start minikube with Docker driver and enable required addons:

# Start minikube
minikube start --driver=docker

# Enable ingress and metrics-server
minikube addons enable ingress
minikube addons enable metrics-server

# Verify cluster
kubectl cluster-info
minikube ip

1) Create folders
# Replace <workspace> with your desired folder
mkdir -p <workspace>/manifests
cd <workspace>

2) Create manifest files

Create the following YAML files inside the manifests folder:

2.1 app.yaml — Deployment + NodePort Service
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo-deploy
spec:
  replicas: 2
  selector:
    matchLabels:
      app: demo
  template:
    metadata:
      labels:
        app: demo
    spec:
      containers:
        - name: web
          image: nginx:1.23
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: demo-svc
spec:
  type: NodePort
  selector:
    app: demo
  ports:
    - port: 80
      targetPort: 80

2.2 pvc-demo.yaml — PVC + Pod
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: demo-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Mi
---
apiVersion: v1
kind: Pod
metadata:
  name: pvc-demo
spec:
  containers:
    - name: busy
      image: busybox
      command: ["sh","-c","echo hello > /data/hello.txt; sleep 3600"]
      volumeMounts:
        - mountPath: /data
          name: storage
  volumes:
    - name: storage
      persistentVolumeClaim:
        claimName: demo-pvc

2.3 config-secret.yaml — ConfigMap + Secret + Pod
apiVersion: v1
kind: ConfigMap
metadata:
  name: demo-config
data:
  APP_ENV: "production"
  WELCOME_MSG: "Hello from ConfigMap"

---
apiVersion: v1
kind: Secret
metadata:
  name: demo-secret
type: Opaque
stringData:
  DB_USER: admin
  DB_PASS: s3cr3t

---
apiVersion: v1
kind: Pod
metadata:
  name: config-secret-demo
spec:
  containers:
    - name: tester
      image: busybox
      command: ["sh","-c","echo Config APP_ENV=$APP_ENV; echo Secret user from secret: $DB_USER; cat /etc/config/WELCOME_MSG; sleep 3600"]
      env:
        - name: APP_ENV
          valueFrom:
            configMapKeyRef:
              name: demo-config
              key: APP_ENV
        - name: DB_USER
          valueFrom:
            secretKeyRef:
              name: demo-secret
              key: DB_USER
      volumeMounts:
        - name: cfg
          mountPath: /etc/config
        - name: sec
          mountPath: /etc/secret
          readOnly: true
  volumes:
    - name: cfg
      configMap:
        name: demo-config
    - name: sec
      secret:
        secretName: demo-secret

2.4 statefulset.yaml — StatefulSet + Headless Service
apiVersion: v1
kind: Service
metadata:
  name: web
spec:
  clusterIP: None
  selector:
    app: web
  ports:
    - port: 80
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  serviceName: "web"
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: nginx
          image: nginx:1.23
          ports:
            - containerPort: 80
  volumeClaimTemplates:
    - metadata:
        name: www
      spec:
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 50Mi

2.5 ingress.yaml — Ingress Resource
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: demo-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
    - host: demo.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: demo-svc
                port:
                  number: 80

3) Apply base app
kubectl apply -f app.yml
kubectl get deploy,pods,svc -o wide

# Quick test via port-forward
kubectl port-forward svc/demo-svc 8080:80
# Open browser: http://localhost:8080
# Or test via curl
curl http://localhost:8080

4) Rolling Update & Rollback
# Update image
kubectl set image deployment/demo-deploy web=nginx:1.25 --record
kubectl rollout status deployment/demo-deploy
kubectl rollout history deployment/demo-deploy

# Rollback
kubectl rollout undo deployment/demo-deploy

5) Scaling & HPA
# Manual scaling
kubectl scale deployment/demo-deploy --replicas=4
kubectl get pods -l app=demo

# Auto HPA (requires metrics-server)
kubectl autoscale deployment demo-deploy --cpu-percent=50 --min=2 --max=5
kubectl get hpa -w

# Generate load in another terminal
kubectl run -it --rm loadgen --image=busybox --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://demo-svc.default.svc.cluster.local; done"

6) Persistent vs Ephemeral Storage
kubectl apply -f pvc-demo.yml
kubectl get pvc,pod pvc-demo
kubectl exec -it pvc-demo -- cat /data/hello.txt

7) ConfigMaps & Secrets
kubectl apply -f config-secret.yml
kubectl get configmap demo-config
kubectl get secret demo-secret
kubectl logs pod/config-secret-demo

8) StatefulSet & Headless Service
kubectl apply -f statefulset.yml
kubectl get sts,pods,pvc

# Delete a pod to see stable identity
kubectl delete pod web-1
kubectl get pods -w

9) Ingress

Windows
# Open PowerShell as Administrator.

# Run:
notepad C:\Windows\System32\drivers\etc\hosts

# Add a new line at the end:
192.168.49.2 demo.local

# Save the file.


# macOS / Linux
sudo nano /etc/hosts

# Add the same line:
192.168.49.2 demo.local

Save and exit (Ctrl+O, Ctrl+X in nano).

This step ensures that when you hit http://demo.local in your browser or via curl, your machine knows to send traffic to your minikube cluster.

# Apply the Ingress in Kubernetes

kubectl apply -f "ingress.yml"
kubectl get ingress

Kubernetes will create the Ingress object.
The Ingress controller (enabled via minikube addons enable ingress) will route incoming requests for demo.local to the demo-svc service.

# Test ingress
curl http://demo.local

10) Cleanup
kubectl delete -f ingress.yml
kubectl delete -f statefulset.yml
kubectl delete -f config-secret.yml
kubectl delete -f pvc-demo.yml
kubectl delete -f app.yml

minikube stop
minikube delete