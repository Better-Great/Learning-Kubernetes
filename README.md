# Learning Kubernetes — CKAD Prep

This repo is the main workspace for preparing for the **Certified Kubernetes Application Developer (CKAD)** exam.

Use it to practice exam topics with hands-on manifests, labs, and notes. Cursor (and this assistant) should help you study toward that goal: explain concepts, write and review YAML, walk through kubectl workflows, and drill CKAD-style scenarios.

## Layout

| Path | Purpose |
|------|---------|
| [`practice/`](./practice/) | **Exam practice** — timed mock exam, verify script, speed drills |
| [`CKAD/`](./CKAD/) | Course labs and practice material, organized by CKAD domains |
| [`learning-2024/`](./learning-2024/) | Earlier Kubernetes YAML practice (archived) |

## Practice for the exam (start here if theory is done)

```bash
cd practice
./scripts/setup-kind.sh          # local kind cluster
# then either:
#   speed-drills/DRILLS.md       # short timed drills
#   mock-exam-1/QUESTIONS.md     # full 2-hour mock (then ./verify.sh)
```

Details: [`practice/README.md`](./practice/README.md).

## CKAD domains (course material)

- **Application Design and Build** — Pods, Jobs, init/multi-containers, volumes, Dockerfiles
- **Application Deployment** — Deployments, labels, Helm
- **Application Environment, Configuration and Security** — ConfigMaps, Secrets, SecurityContext, ResourceQuota, CRDs
- **Application Observability and Maintenance** — Probes, logging
- **Services and Networking** — Services, NetworkPolicies

## How we use this repo

1. Work through labs under `CKAD/` by domain.
2. Prefer declarative YAML and `kubectl` commands you would use under exam time pressure.
3. Keep new practice exercises here; leave `learning-2024/` as historical reference unless you intentionally revisit it.

## Credits

Course labs under `CKAD/` are based on the Udemy course:

- **Course:** [Certified Kubernetes Application Developer | CKAD Exam 2026](https://www.udemy.com/course/certified-kubernetes-application-developer-training/)
- **Instructor:** TechLynk Selenium | DevOps | GenAI | Cloud
- **Platform:** Udemy

All credit for the original course content and teaching material belongs to the instructor and Udemy. This repo is a personal study workspace for CKAD exam preparation.
