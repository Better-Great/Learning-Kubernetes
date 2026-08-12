# CKAD Speed Drills

Do these with a timer. No solutions in this file — use `kubectl explain` / docs if stuck, then check course labs under `../../CKAD/`.

Reset between drills: delete the drill namespace.

---

## Drill A — Config & Security (25%) — 20 minutes

Namespace: `drill-a`

1. ConfigMap `cfg` from literals `COLOR=blue`, `SIZE=large`. Pod mounts whole CM at `/cfg`, and env `COLOR` from key `COLOR`. Image `busybox`, sleep.
2. Secret `tok` with `token=abc123`. Same pod (or new) mounts it at `/tok` read-only.
3. Pod `safe` with `runAsUser: 1000`, `runAsNonRoot: true`, `readOnlyRootFilesystem: true` on the container (may need emptyDir for writable paths if the image requires it — or use a command that needs no writes).
4. ResourceQuota: max 3 pods in the namespace; create 2 pods successfully.

**Pass:** all resources exist; describe pods show mounts and securityContext.

---

## Drill B — Workloads (Design 20%) — 15 minutes

Namespace: `drill-b`

1. Job that prints `hello` and completes.
2. CronJob every 5 minutes (`*/5 * * * *`) with `concurrencyPolicy: Forbid`.
3. Pod with initContainer that creates `/data/ready`, main container cats it then sleeps (shared emptyDir).

**Pass:** Job Complete; CronJob present; Pod Running.

---

## Drill C — Deployments (20%) — 15 minutes

Namespace: `drill-c`

1. Deployment `web` nginx:1.26, 3 replicas.
2. Change image to nginx:1.27; watch rollout.
3. Undo rollback; confirm image 1.26.
4. Scale to 5.

**Pass:** `kubectl rollout history` shows revisions; final image 1.26, replicas 5.

---

## Drill D — Services & NetworkPolicy (20%) — 20 minutes

Namespace: `drill-d`

1. Two Deployments: `client` and `server` (nginx), labels `role=client` / `role=server`.
2. Service `server-svc` → server pods port 80.
3. NetworkPolicy: server allows ingress **only** from `role=client` on TCP 80.
4. Optional: from a debug pod with `role=client`, `wget -qO- server-svc` succeeds conceptually (policy present is enough if CNI supports NetworkPolicy — kind does with default CNI limitations; still write the policy correctly).

**Pass:** netpol YAML selects server; ingress from client selector.

---

## Drill E — Observability (15%) — 15 minutes

Namespace: `drill-e`

1. Deployment with liveness + readiness HTTP probes on `/`.
2. Break readiness (wrong path), observe Pods not Ready.
3. Fix probes; confirm Ready.
4. `kubectl logs` and `kubectl describe` on a pod — practice the debug loop.

**Pass:** Ready replicas = desired after fix.

---

## Daily cadence (when theory feels done)

| Day | Drills | Cap |
|-----|--------|-----|
| Mon | A + E | 40 min |
| Tue | B + C | 35 min |
| Wed | D + A (weak bits only) | 40 min |
| Thu | Full mock exam 1 | 2h |
| Fri | Review fails + speed redo | 60 min |
| Sat | Full mock again (reset) | 2h |

Book the exam when mock scores stay ≥70% with time remaining.
