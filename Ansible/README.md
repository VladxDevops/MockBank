+++
title = "Ansible Automation"
domain = "ansible"
topics = ["ansible", "keycloak", "stage-1", "validation"]
difficulty = "intermediate"
parent = "../README.md"
children = []
related = [
    "../Documentation/internal/ANSIBLE/ansible.md",
    "../Documentation/internal/ANSIBLE/Stage1/Stage1.md",
    "../Documentation/internal/ANSIBLE/Agents.md"
]
updated_by = "AI Documentation Specialist"
version = "1.0"
status = "Stage 1 playbooks drafted"
+++

> **Parent**: [`../README.md`](../README.md)
> **Stage 1 spec**: [`../Documentation/internal/ANSIBLE/Stage1/Stage1.md`](../Documentation/internal/ANSIBLE/Stage1/Stage1.md)
> **Operating model**: [`../Documentation/internal/ANSIBLE/ansible.md`](../Documentation/internal/ANSIBLE/ansible.md)

# Ansible

This directory holds operational Ansible for the Mock Bank platform. Terraform still provisions GCP resources. These playbooks only validate Keycloak after that infrastructure exists.

## Stage 1

Stage 1 is a read-only gate. It proves the private endpoint, admin access, realm, required clients, and OIDC discovery. It does not create or change Keycloak objects.

| Playbook | What it proves |
| --- | --- |
| [`playbooks/bootstrap.yml`](playbooks/bootstrap.yml) | Environment, private URL, and prod approval marker, then the two checks below |
| [`playbooks/verify-reachability.yml`](playbooks/verify-reachability.yml) | `GET /health/live` returns HTTP 200 and status `UP` |
| [`playbooks/verify-identity.yml`](playbooks/verify-identity.yml) | Admin token, enabled realm, enabled required clients, OIDC discovery document |

`roles/keycloak-health/` and `roles/keycloak-smoke/` are reserved for a later split. Stage 1 keeps the checks in the playbooks so the gate does not depend on empty roles.

Inventory files for dev, test, and prod are not part of this stage. The plays run on `localhost` because the runner calls Keycloak over HTTP, usually through the private Cloud Run proxy.

## Runtime variables

Inject these in the runner. Do not commit values.

| Variable | Required | Purpose |
| --- | --- | --- |
| `KEYCLOAK_ENV` | yes for `bootstrap.yml` | `dev`, `test`, or `prod` |
| `KEYCLOAK_BASE_URL` | yes | Private base URL with no userinfo and no secret query string |
| `KEYCLOAK_ADMIN_USERNAME` | yes for identity checks | Admin username from Secret Manager |
| `KEYCLOAK_ADMIN_PASSWORD` | yes for identity checks | Admin password from Secret Manager |
| `KEYCLOAK_PROD_CHANGE_APPROVED` | prod only | Must be `true` before `bootstrap.yml` runs against prod |
| `KEYCLOAK_REALM` | no | Defaults to `Mockbankrealm` |
| `KEYCLOAK_REQUIRED_CLIENTS` | no | Comma-separated. Defaults to `retail-app,teller-portal` |
| `KEYCLOAK_TRUST_PRIVATE_DNS` | no | Set `true` only when the base URL hostname is private DNS rather than loopback or RFC1918 |

The base URL must be loopback (`localhost`, `127.0.0.1`, `::1`), an RFC1918 address, or a private DNS name attested with `KEYCLOAK_TRUST_PRIVATE_DNS=true`. That keeps admin calls off public routes.

## Run

From the repository root, after the private proxy is up and the variables are exported:

```bash
ansible-playbook Ansible/playbooks/bootstrap.yml
```

Either check can be run alone:

```bash
ansible-playbook Ansible/playbooks/verify-reachability.yml
ansible-playbook Ansible/playbooks/verify-identity.yml
```

A failed check stops the run. Logs report the HTTP status and the object name. They do not include the admin password, the access token, or response bodies.

## Out of scope for Stage 1

Realm import, client creation, roles, groups, scopes, authentication flows, and drift repair belong to later stages. Do not add those tasks to these three playbooks.
