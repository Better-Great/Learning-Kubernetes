# Mock Exam 1 — CKAD Practice

**Time limit: 2 hours**  
**Target: ≥66% (aim for ≥70% before booking)**  
**Cluster:** `kind-ckad-practice` (run `../scripts/setup-kind.sh` first)

Rules:

1. Start a timer. Work **only** from this file.
2. Do **not** open `SOLUTIONS.md` until time is up.
3. Create resources in the namespaces named in each task (create the namespace if needed).
4. When finished (or time expires), run `./verify.sh` and score yourself.

Suggested time budget: ~6–8 minutes per task. Skip early if stuck.

---

## Q1 — Namespace + labeled Pod (Design) — ~5 min — 4 pts

Create namespace `ckad-a`.

In `ckad-a`, create Pod `web` with image `nginx:1.27`, label `app=web`, and expose container port `80`.

---

## Q2 — Deployment + Service (Deployment / Networking) — ~8 min — 7 pts

In namespace `ckad-b`:

1. Create Deployment `api` with **3** replicas, image `hashicorp/http-echo:1.0`, args `-text=hello-ckad`, container name `echo`, port `5678`.
2. Expose it with ClusterIP Service `api-svc` on port `80` targeting container port `5678`, selector matching the Deployment pods.

---

## Q3 — ConfigMap as env and volume (Config 25%) — ~10 min — 8 pts

In namespace `ckad-c`:

1. Create ConfigMap `app-config` with keys:
   - `APP_MODE=prod`
   - `LOG_LEVEL=info`
2. Create Pod `cfg-pod` (image `busybox:1.36`) that:
   - sleeps forever (`sleep 3600`)
   - has env var `APP_MODE` from ConfigMap key `APP_MODE`
   - mounts the **entire** ConfigMap at `/etc/config`

---

## Q4 — Secret + SecurityContext (Config / Security) — ~10 min — 8 pts

In namespace `ckad-d`:

1. Create Secret `db-cred` of type Opaque with:
   - `username=admin`
   - `password=s3cr3t`
2. Create Pod `secure-pod` (image `busybox:1.36`, command `sleep 3600`) that:
   - runs as user `1000` (`runAsUser: 1000`)
   - has `runAsNonRoot: true`
   - mounts Secret `db-cred` at `/secrets` (read-only)

---

## Q5 — Requests, limits, ResourceQuota (Config) — ~10 min — 7 pts

In namespace `ckad-e`:

1. Create ResourceQuota `compute-quota` limiting the namespace to:
   - `requests.cpu=1`
   - `requests.memory=1Gi`
   - `limits.cpu=2`
   - `limits.memory=2Gi`
   - `pods=5`
2. Create Pod `quota-pod` (image `nginx:1.27`) with:
   - requests: cpu `100m`, memory `128Mi`
   - limits: cpu `200m`, memory `256Mi`

---

## Q6 — Multi-container + InitContainer (Design) — ~12 min — 8 pts

In namespace `ckad-f`, create Pod `init-sidecar`:

1. **Init container** `init-setup` (image `busybox:1.36`) that writes `ready` into `/work/status` then exits. Share emptyDir volume `work` at `/work`.
2. **Main container** `app` (image `busybox:1.36`) that sleeps forever and mounts the same volume at `/work`.
3. **Sidecar** `logger` (image `busybox:1.36`) that runs `tail -f /work/status` and mounts the same volume at `/work`.

---

## Q7 — Job + CronJob (Design) — ~10 min — 7 pts

In namespace `ckad-g`:

1. Create Job `once-job` that runs `busybox:1.36` with command `echo done` and `restartPolicy: Never`. Completions: **1**.
2. Create CronJob `minute-job` that runs every minute (`* * * * *`), image `busybox:1.36`, command `date`, concurrency policy `Forbid`.

---

## Q8 — Probes (Observability) — ~8 min — 6 pts

In namespace `ckad-h`, create Deployment `probe-app` (1 replica, image `nginx:1.27`) with:

- **livenessProbe**: HTTP GET `/` on port `80`, initialDelaySeconds `5`, periodSeconds `5`
- **readinessProbe**: HTTP GET `/` on port `80`, initialDelaySeconds `2`, periodSeconds `3`

---

## Q9 — NetworkPolicy (Networking) — ~12 min — 8 pts

In namespace `ckad-i`:

1. Create Deployment `frontend` (1 replica, image `nginx:1.27`) with label `tier=frontend`.
2. Create Deployment `backend` (1 replica, image `nginx:1.27`) with label `tier=backend`.
3. Create NetworkPolicy `backend-allow-frontend` that:
   - selects pods with `tier=backend`
   - allows **Ingress** only from pods with `tier=frontend` on TCP port `80`
   - (deny everything else by omission — policy present is enough for this mock)

---

## Q10 — ServiceAccount on Pod (Config / Security) — ~6 min — 5 pts

In namespace `ckad-j`:

1. Create ServiceAccount `app-sa`.
2. Create Pod `sa-pod` (image `busybox:1.36`, `sleep 3600`) that uses ServiceAccount `app-sa`.

---

## Q11 — Rolling update + rollback (Deployment) — ~10 min — 7 pts

In namespace `ckad-k`:

1. Create Deployment `roll` with image `nginx:1.26`, 2 replicas.
2. Update the image to `nginx:1.27` (record the change).
3. Roll back to the previous revision.
4. Confirm the running image is `nginx:1.26` again.

---

## Q12 — PVC + Pod volume (Design) — ~10 min — 7 pts

In namespace `ckad-l`:

1. Create PersistentVolumeClaim `data-pvc` requesting `100Mi`, access mode `ReadWriteOnce`, storage class `standard` (kind default).
2. Create Pod `pvc-pod` (image `busybox:1.36`, `sleep 3600`) mounting that PVC at `/data`.

---

## Q13 — Canary-ish traffic split via Service labels (Deployment / Networking) — ~10 min — 6 pts

In namespace `ckad-m`:

1. Create Deployment `app-v1` with label `app=shop,version=v1`, 3 replicas, image `nginx:1.27`.
2. Create Deployment `app-v2` with label `app=shop,version=v2`, 1 replica, image `nginx:1.27`.
3. Create Service `shop-svc` selecting **all** pods with `app=shop` (both versions), port `80`.

---

## Q14 — Fix a broken Deployment (Observability) — ~8 min — 6 pts

In namespace `ckad-n`, apply this broken Deployment, then **fix it** so a Pod becomes Ready:

```bash
kubectl create namespace ckad-n --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: broken
  namespace: ckad-n
spec:
  replicas: 1
  selector:
    matchLabels:
      app: broken
  template:
    metadata:
      labels:
        app: broken
    spec:
      containers:
      - name: web
        image: nginx:1.27
        ports:
        - containerPort: 80
        readinessProbe:
          httpGet:
            path: /does-not-exist
            port: 80
          initialDelaySeconds: 1
          periodSeconds: 2
EOF
```

Fix: make readiness succeed (e.g. probe path `/`). Do not delete the Deployment name `broken`.

---

## Q15 — Helm install (Deployment) — ~8 min — 6 pts

In namespace `ckad-o`:

1. Ensure Helm is available (`helm version`). If missing, install it for this practice session.
2. Add bitnami repo if needed and install chart **nginx** as release name `web` into namespace `ckad-o`:

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install web bitnami/nginx -n ckad-o --create-namespace
```

Confirm release status is `deployed`.

---

## After the exam

```bash
./verify.sh
```

Then open `SOLUTIONS.md` only for tasks you missed. Reset for a clean retry:

```bash
../scripts/reset-mock-exam-1.sh
```
