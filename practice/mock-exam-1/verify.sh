#!/usr/bin/env bash
# Auto-score mock-exam-1. Run after your timed attempt.
set -u

PASS=0
FAIL=0
TOTAL_PTS=0
EARNED=0

ok() { echo "  PASS ($2 pts) — $1"; PASS=$((PASS+1)); EARNED=$((EARNED+$2)); TOTAL_PTS=$((TOTAL_PTS+$2)); }
bad() { echo "  FAIL (0/$2) — $1"; FAIL=$((FAIL+1)); TOTAL_PTS=$((TOTAL_PTS+$2)); }

check() {
  local desc="$1" pts="$2"
  shift 2
  if "$@" &>/dev/null; then ok "$desc" "$pts"; else bad "$desc" "$pts"; fi
}

echo "=== Mock Exam 1 — Verify ==="
echo

echo "Q1 Namespace + Pod"
check "ns ckad-a" 1 kubectl get ns ckad-a
check "pod web Running" 2 kubectl get pod web -n ckad-a --field-selector=status.phase=Running
check "label app=web" 1 kubectl get pod web -n ckad-a -o jsonpath='{.metadata.labels.app}' | grep -qx web

echo "Q2 Deployment + Service"
check "deploy api replicas=3" 3 kubectl get deploy api -n ckad-b -o jsonpath='{.spec.replicas}' | grep -qx 3
check "svc api-svc port 80" 2 kubectl get svc api-svc -n ckad-b -o jsonpath='{.spec.ports[0].port}' | grep -qx 80
check "svc targetPort 5678" 2 kubectl get svc api-svc -n ckad-b -o jsonpath='{.spec.ports[0].targetPort}' | grep -qx 5678

echo "Q3 ConfigMap"
check "configmap app-config" 2 kubectl get cm app-config -n ckad-c
check "env APP_MODE from cm" 3 kubectl get pod cfg-pod -n ckad-c -o jsonpath='{.spec.containers[0].env[?(@.name=="APP_MODE")].valueFrom.configMapKeyRef.name}' | grep -qx app-config
check "volume mount /etc/config" 3 kubectl get pod cfg-pod -n ckad-c -o jsonpath='{.spec.containers[0].volumeMounts[?(@.mountPath=="/etc/config")].name}' | grep -q .

echo "Q4 Secret + SecurityContext"
check "secret db-cred" 2 kubectl get secret db-cred -n ckad-d
check "runAsUser 1000" 3 kubectl get pod secure-pod -n ckad-d -o jsonpath='{.spec.securityContext.runAsUser}' | grep -qx 1000
check "secret volume mount" 3 kubectl get pod secure-pod -n ckad-d -o jsonpath='{.spec.volumes[?(@.secret)].secret.secretName}' | grep -qx db-cred

echo "Q5 Quota"
check "resourcequota exists" 3 kubectl get quota compute-quota -n ckad-e
check "quota-pod resources set" 4 kubectl get pod quota-pod -n ckad-e -o jsonpath='{.spec.containers[0].resources.requests.cpu}' | grep -qx 100m

echo "Q6 Init + sidecar"
check "init container present" 3 kubectl get pod init-sidecar -n ckad-f -o jsonpath='{.spec.initContainers[0].name}' | grep -qx init-setup
check "two containers" 3 kubectl get pod init-sidecar -n ckad-f -o jsonpath='{.spec.containers[*].name}' | grep -q logger
check "pod Running" 2 kubectl get pod init-sidecar -n ckad-f --field-selector=status.phase=Running

echo "Q7 Job + CronJob"
check "job once-job" 3 kubectl get job once-job -n ckad-g
check "cronjob minute-job schedule" 2 kubectl get cronjob minute-job -n ckad-g -o jsonpath='{.spec.schedule}' | grep -qx '* * * * *'
check "concurrency Forbid" 2 kubectl get cronjob minute-job -n ckad-g -o jsonpath='{.spec.concurrencyPolicy}' | grep -qx Forbid

echo "Q8 Probes"
check "liveness http /" 3 kubectl get deploy probe-app -n ckad-h -o jsonpath='{.spec.template.spec.containers[0].livenessProbe.httpGet.path}' | grep -qx /
check "readiness http /" 3 kubectl get deploy probe-app -n ckad-h -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.path}' | grep -qx /

echo "Q9 NetworkPolicy"
check "netpol exists" 3 kubectl get netpol backend-allow-frontend -n ckad-i
check "frontend labeled" 2 kubectl get pods -n ckad-i -l tier=frontend --no-headers | grep -q .
check "backend labeled" 3 kubectl get pods -n ckad-i -l tier=backend --no-headers | grep -q .

echo "Q10 ServiceAccount"
check "sa app-sa" 2 kubectl get sa app-sa -n ckad-j
check "pod uses app-sa" 3 kubectl get pod sa-pod -n ckad-j -o jsonpath='{.spec.serviceAccountName}' | grep -qx app-sa

echo "Q11 Rollback"
check "deploy roll image nginx:1.26" 7 kubectl get deploy roll -n ckad-k -o jsonpath='{.spec.template.spec.containers[0].image}' | grep -qx nginx:1.26

echo "Q12 PVC"
check "pvc data-pvc" 3 kubectl get pvc data-pvc -n ckad-l
check "pod mounts pvc" 4 kubectl get pod pvc-pod -n ckad-l -o jsonpath='{.spec.volumes[0].persistentVolumeClaim.claimName}' | grep -qx data-pvc

echo "Q13 Canary labels"
check "app-v1 replicas 3" 2 kubectl get deploy app-v1 -n ckad-m -o jsonpath='{.spec.replicas}' | grep -qx 3
check "app-v2 replicas 1" 2 kubectl get deploy app-v2 -n ckad-m -o jsonpath='{.spec.replicas}' | grep -qx 1
check "svc selects app=shop" 2 kubectl get svc shop-svc -n ckad-m -o jsonpath='{.spec.selector.app}' | grep -qx shop

echo "Q14 Fix broken"
check "broken deployment Ready" 6 kubectl get deploy broken -n ckad-n -o jsonpath='{.status.readyReplicas}' | grep -qx 1

echo "Q15 Helm"
if command -v helm &>/dev/null; then
  check "helm release web deployed" 6 helm status web -n ckad-o -o json 2>/dev/null | grep -q '"status":"deployed"'
else
  bad "helm not installed" 6
fi

echo
echo "=== Score: ${EARNED}/${TOTAL_PTS} pts ==="
PCT=$(( EARNED * 100 / TOTAL_PTS ))
echo "Percentage: ${PCT}%"
if (( PCT >= 66 )); then
  echo "Result: PASS threshold met (≥66%). Aim for ≥70% with time left before booking."
else
  echo "Result: Below 66%. Review SOLUTIONS.md for failed items, then reset and retry."
fi
echo "Checks: ${PASS} passed, ${FAIL} failed"
