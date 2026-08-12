#!/usr/bin/env bash
set -euo pipefail

# Wipe namespaces used by mock-exam-1 so you can re-attempt cleanly.
NS=(ckad-a ckad-b ckad-c ckad-d ckad-e ckad-f ckad-g ckad-h ckad-i ckad-j ckad-k ckad-l ckad-m ckad-n ckad-o)

echo "Deleting mock-exam-1 namespaces (if present)..."
for ns in "${NS[@]}"; do
  kubectl delete namespace "${ns}" --ignore-not-found --wait=false
done

echo "Waiting for namespaces to terminate..."
for ns in "${NS[@]}"; do
  while kubectl get namespace "${ns}" &>/dev/null; do
    sleep 1
  done
done

echo "Clean. Re-run QUESTIONS.md from a timer."
