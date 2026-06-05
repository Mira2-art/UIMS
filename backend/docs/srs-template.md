# Software Requirements Specification (SRS) Template

## Document Control

| Field | Value |
|---|---|
| Project | Trustech School Information System (SIS) |
| Module ID | `<MOD-X>` |
| Module Name | `<Module Name>` |
| Version | `<v0.1>` |
| Status | Draft / Review / Approved |
| Author(s) | `<Name(s)>` |
| Reviewer(s) | `<Name(s)>` |
| Date | `<YYYY-MM-DD>` |
| Related Docs | `docs/arch.md`, API specs, UI flows |

---

## 1. Introduction

### 1.1 Purpose
Define the functional and non-functional requirements for `<Module Name>`.

### 1.2 Scope
- In scope:
  - `<item>`
  - `<item>`
- Out of scope:
  - `<item>`
  - `<item>`

### 1.3 Definitions and Acronyms
| Term | Meaning |
|---|---|
| RBAC | Role-Based Access Control |
| SLA | Service Level Agreement |
| PII | Personally Identifiable Information |
| `<Term>` | `<Meaning>` |

### 1.4 References
- `docs/arch.md`
- `<External standard/policy>`

---

## 2. Stakeholders and Actors

### 2.1 Stakeholders
- Product Owner: `<name>`
- Engineering: `<name/team>`
- Compliance/Finance/Registry: `<name/team>`

### 2.2 Actors
| Actor | Description |
|---|---|
| Student | `<access summary>` |
| Lecturer | `<access summary>` |
| General Admin | `<access summary>` |
| Finance Admin | `<access summary>` |
| Department Admin | `<access summary>` |
| System Admin | `<access summary>` |

---

## 3. Module Context

### 3.1 Upstream Dependencies
| Source Module | Data/Capability Consumed |
|---|---|
| `<MOD-X>` | `<item>` |

### 3.2 Downstream Consumers
| Consumer Module | Data/Events Published |
|---|---|
| `<MOD-Y>` | `<item>` |

### 3.3 Assumptions
- `<assumption>`
- `<assumption>`

### 3.4 Constraints
- Technical: `<constraint>`
- Regulatory: `<constraint>`
- Operational: `<constraint>`

---

## 4. Functional Requirements

### 4.1 Feature List
| Feature ID | Feature Name | Priority |
|---|---|---|
| FR-001 | `<feature>` | Critical / High / Medium / Low |
| FR-002 | `<feature>` | Critical / High / Medium / Low |

### 4.2 Detailed Requirements

#### FR-001 `<Feature Name>`
- Description: `<what it does>`
- Trigger: `<user/system action>`
- Preconditions:
  - `<condition>`
- Main Flow:
  1. `<step>`
  2. `<step>`
  3. `<step>`
- Alternate Flows:
  - A1: `<alternate>`
  - A2: `<alternate>`
- Postconditions:
  - `<state change>`
- Acceptance Criteria:
  - [ ] `<measurable check>`
  - [ ] `<measurable check>`

#### FR-002 `<Feature Name>`
- Description: `<...>`
- Trigger: `<...>`
- Preconditions:
  - `<...>`
- Main Flow:
  1. `<...>`
- Alternate Flows:
  - A1: `<...>`
- Postconditions:
  - `<...>`
- Acceptance Criteria:
  - [ ] `<...>`

---

## 5. Business Rules

| Rule ID | Rule Statement | Severity on Violation |
|---|---|---|
| BR-001 | `<rule>` | Blocker / Warning / Info |
| BR-002 | `<rule>` | Blocker / Warning / Info |

Examples:
- `<example rule for prerequisite enforcement>`
- `<example rule for role-scope enforcement>`

---

## 6. RBAC and Permission Matrix

| Action | Student | Lecturer | General Admin | Finance Admin | Department Admin | System Admin |
|---|---|---|---|---|---|---|
| `<action>` | Allow/Deny | Allow/Deny | Allow/Deny | Allow/Deny | Allow/Deny | Allow/Deny |
| `<action>` | Allow/Deny | Allow/Deny | Allow/Deny | Allow/Deny | Allow/Deny | Allow/Deny |

Scope rules:
- `<department-scoped write example>`
- `<finance-only access example>`

---

## 7. Data Requirements

### 7.1 Entity Model (Module-Owned)
| Entity | Purpose | Key Fields |
|---|---|---|
| `<EntityName>` | `<purpose>` | `<id, status, ...>` |

### 7.2 Entity Relationships
- `<EntityA 1..* EntityB>`
- `<EntityC *..1 EntityD>`

### 7.3 Data Validation Rules
| Field | Rule | Error Message |
|---|---|---|
| `<field>` | `<validation>` | `<message>` |

### 7.4 Data Retention and Archival
- Retention: `<duration>`
- Archival trigger: `<condition>`
- Soft-delete or hard-delete: `<strategy>`

---

## 8. API Requirements

### 8.1 Endpoint Catalog
| Endpoint ID | Method | Path | Auth | Description |
|---|---|---|---|---|
| API-001 | GET | `/api/v1/<resource>` | Role(s) | `<purpose>` |
| API-002 | POST | `/api/v1/<resource>` | Role(s) | `<purpose>` |

### 8.2 Request/Response Contracts
#### API-001 `<Name>`
- Request params: `<query/path/body>`
- Success response: `<schema summary>`
- Error responses:
  - `400`: `<reason>`
  - `401`: `<reason>`
  - `403`: `<reason>`
  - `404`: `<reason>`
  - `409`: `<reason>`

### 8.3 Idempotency and Concurrency
- Idempotent operations: `<list>`
- Concurrency control: `<optimistic lock/version/transaction policy>`

---

## 9. State Model (If Applicable)

### 9.1 Lifecycle States
| State | Description |
|---|---|
| `<state>` | `<description>` |

### 9.2 State Transitions
| From | Event | To | Guard Condition |
|---|---|---|---|
| `<state>` | `<event>` | `<state>` | `<condition>` |

### 9.3 Invalid Transitions
- `<transition>` must be rejected with `<error code>`.

---

## 10. Non-Functional Requirements

### 10.1 Performance
- P95 latency target: `<e.g., 300ms>`
- Throughput target: `<e.g., 200 req/s>`

### 10.2 Reliability
- Availability target: `<e.g., 99.9%>`
- Retry policy: `<policy>`

### 10.3 Security
- AuthN/AuthZ requirements: `<details>`
- Sensitive data handling: `<PII policy>`
- Audit logging: `<required actions>`

### 10.4 Observability
- Required logs: `<events>`
- Required metrics: `<metrics>`
- Required traces: `<critical flows>`

### 10.5 Scalability
- Horizontal scaling strategy: `<strategy>`
- Bottleneck assumptions: `<assumption>`

---

## 11. Error Handling

| Error Scenario | HTTP Code | Error Code | User Message | Recovery |
|---|---|---|---|---|
| `<scenario>` | 400 | `<ERR_CODE>` | `<message>` | `<action>` |

Global error format:
```json
{
  "error": {
    "code": "ERR_CODE",
    "message": "Human-readable message",
    "details": {}
  }
}
```

---

## 12. Events and Integrations

### 12.1 Outbound Events
| Event Name | Trigger | Payload Summary | Consumer |
|---|---|---|---|
| `<event>` | `<trigger>` | `<payload>` | `<module/service>` |

### 12.2 Inbound Events
| Event Name | Source | Processing Rule |
|---|---|---|
| `<event>` | `<source>` | `<rule>` |

### 12.3 External Integrations
| System | Purpose | Failure Handling |
|---|---|---|
| `<payment/email/sms>` | `<purpose>` | `<retry/fallback>` |

---

## 13. Reporting Requirements (If Applicable)

| Report | Audience | Filters | Frequency |
|---|---|---|---|
| `<report name>` | `<role>` | `<filter list>` | Real-time / Daily / Monthly |

---

## 14. Test Strategy and Acceptance

### 14.1 Test Coverage
- Unit tests: `<scope>`
- Integration tests: `<scope>`
- Contract tests: `<scope>`
- End-to-end tests: `<scope>`

### 14.2 Acceptance Test Cases
| Test ID | Requirement Ref | Scenario | Expected Result |
|---|---|---|---|
| AT-001 | FR-001 | `<scenario>` | `<result>` |

### 14.3 Exit Criteria
- [ ] All critical and high requirements tested.
- [ ] No open critical defects.
- [ ] Security and permission checks passed.

---

## 15. Traceability Matrix

| Requirement ID | Design/Entity/API | Test Case ID | Status |
|---|---|---|---|
| FR-001 | `<api/entity>` | AT-001 | Draft / Implemented / Verified |

---

## 16. Open Questions and Risks

### 16.1 Open Questions
- `<question>`
- `<question>`

### 16.2 Risks
| Risk | Impact | Mitigation |
|---|---|---|
| `<risk>` | High/Medium/Low | `<mitigation>` |

---

## 17. Change Log

| Version | Date | Author | Change Summary |
|---|---|---|---|
| v0.1 | `<YYYY-MM-DD>` | `<name>` | Initial draft |
