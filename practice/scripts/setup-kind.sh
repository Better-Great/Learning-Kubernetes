#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-ckad-practice}"

if kind get clusters 2>/dev/null | grep -qx "${CLUSTER_NAME}"; then
  echo "Cluster '${CLUSTER_NAME}' already exists."
else
  echo "Creating kind cluster '${CLUSTER_NAME}'..."
  kind create cluster --name "${CLUSTER_NAME}"
fi

kubectl config use-context "kind-${CLUSTER_NAME}"
kubectl cluster-info
kubectl get nodes
echo
echo "Ready. Context: kind-${CLUSTER_NAME}"
echo "Start mock: cd ../mock-exam-1 && cat QUESTIONS.md"
