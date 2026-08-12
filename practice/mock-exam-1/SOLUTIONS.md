# Mock Exam 1 — Solutions

Open only after your timed attempt.

## Q1

```bash
kubectl create ns ckad-a
kubectl run web -n ckad-a --image=nginx:1.27 --labels=app=web --port=80
```

## Q2

```bash
kubectl create ns ckad-b
kubectl create deployment api -n ckad-b --image=hashicorp/http-echo:1.0 --replicas=3
kubectl set command deployment/api -n ckad-b -- -text=hello-ckad
# Or edit: kubectl edit deploy api -n ckad-b  # set args under container
kubectl expose deployment api -n ckad-b --name=api-svc --port=80 --target-port=5678
```

Note: `http-echo` uses args; ensure container args are `-text=hello-ckad` (edit if `set command` replaces entrypoint incorrectly — prefer dry-run YAML).

Cleaner:

```bash
kubectl create deployment api -n ckad-b --image=hashicorp/http-echo:1.0 --replicas=3 --dry-run=client -o yaml \
  | sed 's/containers:/containers:\n      - name: echo/' >/dev/null
# Prefer apply from edited YAML:
kubectl apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  namespace: ckad-b
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
      - name: echo
        image: hashicorp/http-echo:1.0
        args: ["-text=hello-ckad"]
        ports:
        - containerPort: 5678
EOF
kubectl expose deployment api -n ckad-b --name=api-svc --port=80 --target-port=5678
```

## Q3

```bash
kubectl create ns ckad-c
kubectl create configmap app-config -n ckad-c --from-literal=APP_MODE=prod --from-literal=LOG_LEVEL=info
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: cfg-pod
  namespace: ckad-c
spec:
  containers:
  - name: app
    image: busybox:1.36
    command: ["sleep","3600"]
    env:
    - name: APP_MODE
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: APP_MODE
    volumeMounts:
    - name: cfg
      mountPath: /etc/config
  volumes:
  - name: cfg
    configMap:
      name: app-config
EOF
```

## Q4

```bash
kubectl create ns ckad-d
kubectl create secret generic db-cred -n ckad-d --from-literal=username=admin --from-literal=password=s3cr3t
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
  namespace: ckad-d
spec:
  securityContext:
    runAsUser: 1000
    runAsNonRoot: true
  containers:
  - name: app
    image: busybox:1.36
    command: ["sleep","3600"]
    volumeMounts:
    - name: creds
      mountPath: /secrets
      readOnly: true
  volumes:
  - name: creds
    secret:
      secretName: db-cred
EOF
```

## Q5

```bash
kubectl create ns ckad-e
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
  namespace: ckad-e
spec:
  hard:
    requests.cpu: "1"
    requests.memory: 1Gi
    limits.cpu: "2"
    limits.memory: 2Gi
    pods: "5"
---
apiVersion: v1
kind: Pod
metadata:
  name: quota-pod
  namespace: ckad-e
spec:
  containers:
  - name: nginx
    image: nginx:1.27
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 200m
        memory: 256Mi
EOF
```

## Q6

```bash
kubectl create ns ckad-f
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: init-sidecar
  namespace: ckad-f
spec:
  initContainers:
  - name: init-setup
    image: busybox:1.36
    command: ["sh","-c","echo ready > /work/status"]
    volumeMounts:
    - name: work
      mountPath: /work
  containers:
  - name: app
    image: busybox:1.36
    command: ["sleep","3600"]
    volumeMounts:
    - name: work
      mountPath: /work
  - name: logger
    image: busybox:1.36
    command: ["tail","-f","/work/status"]
    volumeMounts:
    - name: work
      mountPath: /work
  volumes:
  - name: work
    emptyDir: {}
EOF
```

## Q7

```bash
kubectl create ns ckad-g
kubectl create job once-job -n ckad-g --image=busybox:1.36 -- echo done
kubectl create cronjob minute-job -n ckad-g --image=busybox:1.36 --schedule="* * * * *" -- date
kubectl patch cronjob minute-job -n ckad-g -p '{"spec":{"concurrencyPolicy":"Forbid"}}'
```

## Q8

```bash
kubectl create ns ckad-h
kubectl create deployment probe-app -n ckad-h --image=nginx:1.27
kubectl apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: probe-app
  namespace: ckad-h
spec:
  replicas: 1
  selector:
    matchLabels:
      app: probe-app
  template:
    metadata:
      labels:
        app: probe-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.27
        ports:
        - containerPort: 80
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 2
          periodSeconds: 3
EOF
```

## Q9

```bash
kubectl create ns ckad-i
kubectl create deployment frontend -n ckad-i --image=nginx:1.27
kubectl label deployment frontend -n ckad-i tier=frontend --overwrite
kubectl patch deployment frontend -n ckad-i --type strategic -p '{"spec":{"template":{"metadata":{"labels":{"tier":"frontend","app":"frontend"}}}}}'
# Cleaner: apply labeled YAML
kubectl apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: ckad-i
spec:
  replicas: 1
  selector:
    matchLabels:
      tier: frontend
  template:
    metadata:
      labels:
        tier: frontend
    spec:
      containers:
      - name: nginx
        image: nginx:1.27
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: ckad-i
spec:
  replicas: 1
  selector:
    matchLabels:
      tier: backend
  template:
    metadata:
      labels:
        tier: backend
    spec:
      containers:
      - name: nginx
        image: nginx:1.27
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-allow-frontend
  namespace: ckad-i
spec:
  podSelector:
    matchLabels:
      tier: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: frontend
    ports:
    - protocol: TCP
      port: 80
EOF
```

## Q10

```bash
kubectl create ns ckad-j
kubectl create sa app-sa -n ckad-j
kubectl run sa-pod -n ckad-j --image=busybox:1.36 --restart=Never --overrides='{"spec":{"serviceAccountName":"app-sa"}}' --command -- sleep 3600
```

## Q11

```bash
kubectl create ns ckad-k
kubectl create deployment roll -n ckad-k --image=nginx:1.26 --replicas=2
kubectl set image deployment/roll nginx=nginx:1.27 -n ckad-k --record=true 2>/dev/null || \
  kubectl set image deployment/roll nginx=nginx:1.27 -n ckad-k
kubectl rollout undo deployment/roll -n ckad-k
kubectl rollout status deployment/roll -n ckad-k
kubectl get deploy roll -n ckad-k -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

## Q12

```bash
kubectl create ns ckad-l
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-pvc
  namespace: ckad-l
spec:
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: 100Mi
  storageClassName: standard
---
apiVersion: v1
kind: Pod
metadata:
  name: pvc-pod
  namespace: ckad-l
spec:
  containers:
  - name: app
    image: busybox:1.36
    command: ["sleep","3600"]
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: data-pvc
EOF
```

If PVC stays Pending on kind, check `kubectl get sc` and use the default StorageClass name (often `standard`).

## Q13

```bash
kubectl create ns ckad-m
kubectl apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-v1
  namespace: ckad-m
spec:
  replicas: 3
  selector:
    matchLabels:
      app: shop
      version: v1
  template:
    metadata:
      labels:
        app: shop
        version: v1
    spec:
      containers:
      - name: nginx
        image: nginx:1.27
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-v2
  namespace: ckad-m
spec:
  replicas: 1
  selector:
    matchLabels:
      app: shop
      version: v2
  template:
    metadata:
      labels:
        app: shop
        version: v2
    spec:
      containers:
      - name: nginx
        image: nginx:1.27
---
apiVersion: v1
kind: Service
metadata:
  name: shop-svc
  namespace: ckad-m
spec:
  selector:
    app: shop
  ports:
  - port: 80
    targetPort: 80
EOF
```

## Q14

```bash
kubectl set / patch the readinessProbe path to /
# e.g.
kubectl patch deployment broken -n ckad-n --type='json' -p='[
  {"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/path","value":"/"}
]'
kubectl rollout status deployment/broken -n ckad-n
```

## Q15

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install web bitnami/nginx -n ckad-o --create-namespace
helm status web -n ckad-o
```
