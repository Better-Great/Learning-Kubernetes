# CKAD Practice Suite

Hands-on practice only. Theory belongs in the course labs under `../CKAD/`.

Exam shape (CNCF): **~2 hours**, performance tasks in a terminal, pass **66%**. Domains:

| Domain | Weight |
|--------|--------|
| Application Environment, Configuration and Security | 25% |
| Application Design and Build | 20% |
| Application Deployment | 20% |
| Services and Networking | 20% |
| Application Observability and Maintenance | 15% |

## Setup (once)

```bash
cd /home/zealot/Learning-Kubernetes/practice
./scripts/setup-kind.sh
```

This creates a `ckad-practice` kind cluster and sets `kubectl` context. Tear down later with:

```bash
./scripts/teardown-kind.sh
```

## How to practice

### 1. Mock exam (closest to real)

```bash
cd mock-exam-1
# Start a 2-hour timer. Do NOT open SOLUTIONS.md until done.
# Work only from QUESTIONS.md
./verify.sh   # after time is up (or mid-exam if you want a checkpoint)
```

Rules that match the real exam:

- Prefer imperative `kubectl` + `--dry-run=client -o yaml` then edit
- Use namespaces exactly as stated
- Skip / partial-complete if stuck > ~8 minutes; mark and move on
- Docs allowed: https://kubernetes.io/docs/ (and `kubectl explain`)

### 2. Speed drills (daily)

Short timed tasks in `speed-drills/`. Aim to finish each drill under the listed time without peeking.

### 3. Session plan (practice-first)

| Session | What | Time |
|---------|------|------|
| A | Speed drills: Config & Security (25%) | 45–60 min |
| B | Speed drills: Design & Build + Networking | 45–60 min |
| C | Mock exam 1 (full) | 2 hours + 30 min review |
| D | Weak-area drills from verify failures | 60 min |
| E | Second full mock (re-run mock after reset) | 2 hours |

Reset mock exam namespaces between attempts:

```bash
./scripts/reset-mock-exam-1.sh
```

## What “ready” looks like

You are practice-ready when you can:

1. Finish mock exam 1 at **≥70%** on `verify.sh` with **≥15 minutes left**
2. Create ConfigMap/Secret mounts, NetworkPolicy, probes, and Job/CronJob **without hesitation**
3. Debug a broken Pod (`describe` → `logs` → `get events`) in under 4 minutes

Optional next step after local mocks: the official exam includes **Killer.sh** simulator attempts — use those close to exam day.
