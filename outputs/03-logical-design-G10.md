# Task 3: Logical Database Design

## 1. Design Overview

This logical design converts the conceptual ERD from Task 2 into a relational schema for the Campus Space Management System. Each strong entity becomes a relation, the many-to-many relationship between spaces and facilities becomes an associative relation, and one-to-many relationships are represented through foreign keys.

The design preserves the main business rules from Task 1: users must have university accounts, bookings must reference one requester and one space, approvals must be made by authorized staff or managers, usage sessions must be tied to approved bookings, and maintenance records must identify the affected space and reporter.

## 2. Relation Summary

| No. | Relation | Purpose |
|---|---|---|
| 1 | `users` | Stores university account holders and their roles. |
| 2 | `spaces` | Stores managed campus spaces. |
| 3 | `facilities` | Stores facility and equipment types. |
| 4 | `space_facilities` | Resolves the many-to-many relationship between spaces and facilities. |
| 5 | `booking_requests` | Stores requested reservations and booking lifecycle status. |
| 6 | `approvals` | Stores approval or rejection decisions. |
| 7 | `usage_sessions` | Stores actual check-in and completion information. |
| 8 | `maintenance_records` | Stores reported space problems and maintenance workflow details. |

## 3. Relational Schema

Notation:

- `PK` = Primary Key
- `FK` = Foreign Key
- `CK` = Candidate Key
- `UK` = Unique Key
- `NN` = Not Null
- `CHK` = Check constraint

### 3.1 users

`users(user_id, full_name, email, phone_number, role, department, account_status)`

| Attribute | Data Type | Key / Constraint | Description |
|---|---|---|---|
| user_id | VARCHAR(20) | PK, NN | Unique university user identifier. |
| full_name | VARCHAR(100) | NN | User's full name. |
| email | VARCHAR(150) | UK, NN | Unique university email address. |
| phone_number | VARCHAR(30) |  | Contact number. |
| role | VARCHAR(35) | NN, CHK | User role. |
| department | VARCHAR(100) | NN | User's department. |
| account_status | VARCHAR(20) | NN, CHK | Current account status. |

Primary key:

- `user_id`

Candidate keys:

- `user_id`
- `email`

Domain constraints:

- `role IN ('student', 'lecturer', 'teaching assistant', 'facility staff', 'department administrator', 'facility manager')`
- `account_status IN ('active', 'inactive', 'suspended')`

### 3.2 spaces

`spaces(space_code, space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy)`

| Attribute | Data Type | Key / Constraint | Description |
|---|---|---|---|
| space_code | VARCHAR(20) | PK, NN | Unique code for the space. |
| space_name | VARCHAR(100) | NN | Space name. |
| space_type | VARCHAR(40) | NN, CHK | Type of campus space. |
| building | VARCHAR(100) | UK component, NN | Building name or code. |
| floor | VARCHAR(20) | UK component, NN | Floor label or number. |
| room_number | VARCHAR(20) | UK component, NN | Room number. |
| capacity | INTEGER | NN, CHK | Maximum allowed participants. |
| current_status | VARCHAR(30) | NN, CHK | Operational status of the space. |
| usage_policy | TEXT |  | Space usage policy. |

Primary key:

- `space_code`

Candidate keys:

- `space_code`
- `(building, floor, room_number)`

Domain constraints:

- `space_type IN ('auditorium', 'classroom', 'computer laboratory', 'project laboratory', 'meeting room', 'student workspace')`
- `current_status IN ('available', 'in use', 'under maintenance', 'temporarily closed', 'retired')`
- `capacity > 0`

Unique constraints:

- `UNIQUE (building, floor, room_number)`

### 3.3 facilities

`facilities(facility_id, facility_name, description)`

| Attribute | Data Type | Key / Constraint | Description |
|---|---|---|---|
| facility_id | INTEGER | PK, NN | Unique facility type identifier. |
| facility_name | VARCHAR(100) | UK, NN | Facility or equipment name. |
| description | TEXT |  | Optional facility description. |

Primary key:

- `facility_id`

Candidate keys:

- `facility_id`
- `facility_name`

### 3.4 space_facilities

`space_facilities(space_code, facility_id, quantity, condition_note)`

| Attribute | Data Type | Key / Constraint | Description |
|---|---|---|---|
| space_code | VARCHAR(20) | PK, FK, NN | References the related space. |
| facility_id | INTEGER | PK, FK, NN | References the facility type. |
| quantity | INTEGER | NN, CHK | Number of facility items in the space. |
| condition_note | TEXT |  | Optional condition note. |

Primary key:

- `(space_code, facility_id)`

Foreign keys:

- `space_code` references `spaces(space_code)`
- `facility_id` references `facilities(facility_id)`

Domain constraints:

- `quantity > 0`

Relationship represented:

- Resolves `spaces` M:N `facilities`.

### 3.5 booking_requests

`booking_requests(booking_id, requester_id, space_code, requested_start_time, requested_end_time, purpose_of_use, expected_participants, booking_status, created_at)`

| Attribute | Data Type | Key / Constraint | Description |
|---|---|---|---|
| booking_id | INTEGER | PK, NN | Unique booking request identifier. |
| requester_id | VARCHAR(20) | FK, NN | User who submitted the request. |
| space_code | VARCHAR(20) | FK, NN | Requested space. |
| requested_start_time | TIMESTAMP | NN | Requested start time. |
| requested_end_time | TIMESTAMP | NN | Requested end time. |
| purpose_of_use | VARCHAR(40) | NN, CHK | Purpose of the booking. |
| expected_participants | INTEGER | NN, CHK | Expected number of participants. |
| booking_status | VARCHAR(20) | NN, CHK | Booking lifecycle status. |
| created_at | TIMESTAMP | NN | Time the request was created. |

Primary key:

- `booking_id`

Foreign keys:

- `requester_id` references `users(user_id)`
- `space_code` references `spaces(space_code)`

Domain constraints:

- `requested_end_time > requested_start_time`
- `expected_participants > 0`
- `purpose_of_use IN ('lecture', 'examination', 'seminar', 'workshop', 'meeting', 'student activity', 'administrative event')`
- `booking_status IN ('pending', 'approved', 'rejected', 'cancelled', 'checked in', 'completed', 'no-show')`

Business constraints:

- A booking can be approved only if the related space is not `under maintenance`, `temporarily closed`, or `retired`.
- For the same `space_code`, approved active bookings must not overlap in requested time.
- `expected_participants` should not exceed the `capacity` of the related space.

### 3.6 approvals

`approvals(approval_id, booking_id, staff_id, decision, decision_time, decision_note, rejection_reason)`

| Attribute | Data Type | Key / Constraint | Description |
|---|---|---|---|
| approval_id | INTEGER | PK, NN | Unique approval decision identifier. |
| booking_id | INTEGER | FK, NN | Booking request being approved or rejected. |
| staff_id | VARCHAR(20) | FK, NN | Facility staff member or manager making the decision. |
| decision | VARCHAR(20) | NN, CHK | Approval decision. |
| decision_time | TIMESTAMP | NN | Time of the decision. |
| decision_note | TEXT |  | Optional decision note. |
| rejection_reason | TEXT | Conditional NN | Required when decision is rejected. |

Primary key:

- `approval_id`

Foreign keys:

- `booking_id` references `booking_requests(booking_id)`
- `staff_id` references `users(user_id)`

Domain constraints:

- `decision IN ('approved', 'rejected')`
- If `decision = 'rejected'`, then `rejection_reason IS NOT NULL`.

Business constraints:

- The referenced `staff_id` must identify a user whose role is `facility staff` or `facility manager`.
- The approval decision should be consistent with `booking_requests.booking_status`.

### 3.7 usage_sessions

`usage_sessions(session_id, booking_id, actual_start_time, checked_in_by, initial_condition, actual_end_time, final_condition, usage_notes)`

| Attribute | Data Type | Key / Constraint | Description |
|---|---|---|---|
| session_id | INTEGER | PK, NN | Unique usage session identifier. |
| booking_id | INTEGER | FK, UK, NN | Booking used for the session. |
| actual_start_time | TIMESTAMP | NN | Actual check-in/start time. |
| checked_in_by | VARCHAR(20) | FK, NN | User who performed check-in. |
| initial_condition | TEXT | NN | Condition of the space at check-in. |
| actual_end_time | TIMESTAMP |  | Actual completion/end time. |
| final_condition | TEXT |  | Condition of the space at completion. |
| usage_notes | TEXT |  | Notes about the usage session. |

Primary key:

- `session_id`

Candidate keys:

- `session_id`
- `booking_id`

Foreign keys:

- `booking_id` references `booking_requests(booking_id)`
- `checked_in_by` references `users(user_id)`

Domain constraints:

- If `actual_end_time IS NOT NULL`, then `actual_end_time > actual_start_time`.
- If `actual_end_time IS NOT NULL`, then `final_condition IS NOT NULL`.

Business constraints:

- A booking may have at most one usage session, enforced by `UNIQUE (booking_id)`.
- A usage session should be created only for an approved or checked-in booking.
- A completed booking should have `actual_end_time` and `final_condition` recorded.

### 3.8 maintenance_records

`maintenance_records(maintenance_id, space_code, reporter_id, assigned_staff_id, problem_type, problem_description, start_time, completion_time, maintenance_status, result_note)`

| Attribute | Data Type | Key / Constraint | Description |
|---|---|---|---|
| maintenance_id | INTEGER | PK, NN | Unique maintenance record identifier. |
| space_code | VARCHAR(20) | FK, NN | Space with the problem. |
| reporter_id | VARCHAR(20) | FK, NN | User who reported the problem. |
| assigned_staff_id | VARCHAR(20) | FK | Staff member assigned to the problem. |
| problem_type | VARCHAR(50) | NN, CHK | Category of problem. |
| problem_description | TEXT | NN | Detailed problem description. |
| start_time | TIMESTAMP | NN | Time maintenance was opened or started. |
| completion_time | TIMESTAMP |  | Time maintenance was completed. |
| maintenance_status | VARCHAR(20) | NN, CHK | Current maintenance status. |
| result_note | TEXT |  | Result or resolution note. |

Primary key:

- `maintenance_id`

Foreign keys:

- `space_code` references `spaces(space_code)`
- `reporter_id` references `users(user_id)`
- `assigned_staff_id` references `users(user_id)`

Domain constraints:

- `problem_type IN ('broken projector', 'air-conditioning failure', 'damaged furniture', 'cleaning issue', 'network problem', 'other')`
- `maintenance_status IN ('reported', 'assigned', 'in progress', 'completed', 'cancelled')`
- If `completion_time IS NOT NULL`, then `completion_time > start_time`.
- If `maintenance_status = 'completed'`, then `completion_time IS NOT NULL` and `result_note IS NOT NULL`.

Business constraints:

- The referenced `assigned_staff_id`, when present, must identify a user whose role is `facility staff` or `facility manager`.
- Serious unresolved maintenance should cause the related space status to become `under maintenance`.

## 4. Foreign Key Relationship Summary

| Child Relation | Foreign Key | Parent Relation | Relationship |
|---|---|---|---|
| `space_facilities` | `space_code` | `spaces(space_code)` | A space has listed facilities. |
| `space_facilities` | `facility_id` | `facilities(facility_id)` | A facility appears in spaces. |
| `booking_requests` | `requester_id` | `users(user_id)` | A user submits booking requests. |
| `booking_requests` | `space_code` | `spaces(space_code)` | A booking request selects one space. |
| `approvals` | `booking_id` | `booking_requests(booking_id)` | A booking request has approval decisions. |
| `approvals` | `staff_id` | `users(user_id)` | A staff user makes approval decisions. |
| `usage_sessions` | `booking_id` | `booking_requests(booking_id)` | A booking request produces at most one usage session. |
| `usage_sessions` | `checked_in_by` | `users(user_id)` | A user checks in a usage session. |
| `maintenance_records` | `space_code` | `spaces(space_code)` | A space has maintenance records. |
| `maintenance_records` | `reporter_id` | `users(user_id)` | A user reports maintenance problems. |
| `maintenance_records` | `assigned_staff_id` | `users(user_id)` | A staff user may be assigned maintenance work. |

## 5. Candidate Keys and Unique Constraints

| Relation | Candidate Key / Unique Constraint | Rationale |
|---|---|---|
| `users` | `user_id` | Main identifier for each university account holder. |
| `users` | `email` | University email must uniquely identify a user account. |
| `spaces` | `space_code` | Required unique space code. |
| `spaces` | `(building, floor, room_number)` | Physical room location should be unique. |
| `facilities` | `facility_id` | Main identifier for each facility type. |
| `facilities` | `facility_name` | Facility type names should not duplicate. |
| `space_facilities` | `(space_code, facility_id)` | Prevents the same facility type from being listed twice for one space. |
| `booking_requests` | `booking_id` | Main identifier for each booking request. |
| `approvals` | `approval_id` | Main identifier for each approval decision. |
| `usage_sessions` | `session_id` | Main identifier for each usage session. |
| `usage_sessions` | `booking_id` | Enforces at most one usage session per booking. |
| `maintenance_records` | `maintenance_id` | Main identifier for each maintenance record. |

## 6. Cardinality Mapping from ERD to Relations

| ERD Relationship | Logical Mapping |
|---|---|
| USER 1:N BOOKING_REQUEST | `booking_requests.requester_id` references `users.user_id`. |
| SPACE 1:N BOOKING_REQUEST | `booking_requests.space_code` references `spaces.space_code`. |
| SPACE M:N FACILITY | Associative relation `space_facilities(space_code, facility_id)`. |
| BOOKING_REQUEST 1:N APPROVAL | `approvals.booking_id` references `booking_requests.booking_id`. |
| USER 1:N APPROVAL | `approvals.staff_id` references `users.user_id`. |
| BOOKING_REQUEST 1:0..1 USAGE_SESSION | `usage_sessions.booking_id` references `booking_requests.booking_id` with a unique constraint. |
| USER 1:N USAGE_SESSION | `usage_sessions.checked_in_by` references `users.user_id`. |
| SPACE 1:N MAINTENANCE_RECORD | `maintenance_records.space_code` references `spaces.space_code`. |
| USER 1:N MAINTENANCE_RECORD as reporter | `maintenance_records.reporter_id` references `users.user_id`. |
| USER 0..1:N MAINTENANCE_RECORD as assigned staff | `maintenance_records.assigned_staff_id` references `users.user_id` and allows NULL. |

## 7. Important Business Rules for Implementation

Some business rules are simple relational constraints and can be implemented using primary keys, foreign keys, unique constraints, `NOT NULL`, and `CHECK` constraints. Others require assertions, triggers, stored procedures, or application logic because they depend on values in multiple rows or related tables.

| Business Rule | Logical Enforcement Method |
|---|---|
| User email must be unique. | `UNIQUE (email)` in `users`. |
| User role must be valid. | `CHECK` constraint on `users.role`. |
| Space code must be unique. | Primary key on `spaces.space_code`. |
| Building, floor, and room number should identify one physical room. | `UNIQUE (building, floor, room_number)` in `spaces`. |
| Space status must be valid. | `CHECK` constraint on `spaces.current_status`. |
| Capacity must be positive. | `CHECK (capacity > 0)` in `spaces`. |
| Requested end time must be after requested start time. | `CHECK (requested_end_time > requested_start_time)` in `booking_requests`. |
| Booking purpose and status must be valid. | `CHECK` constraints in `booking_requests`. |
| Rejected approvals must include a rejection reason. | Conditional `CHECK` constraint in `approvals`. |
| Each booking can have at most one usage session. | `UNIQUE (booking_id)` in `usage_sessions`. |
| Completed usage sessions must include end time and final condition. | Conditional `CHECK` constraint in `usage_sessions`. |
| Maintenance completion time must be after start time. | Conditional `CHECK` constraint in `maintenance_records`. |
| Completed maintenance must include completion time and result note. | Conditional `CHECK` constraint in `maintenance_records`. |
| Staff approving bookings must be facility staff or facility manager. | Trigger or application rule checking `users.role`. |
| Assigned maintenance staff must be facility staff or facility manager. | Trigger or application rule checking `users.role`. |
| A closed, retired, or under-maintenance space cannot be approved for booking. | Trigger or application rule checking related `spaces.current_status`. |
| Approved bookings for the same space cannot overlap. | Exclusion constraint where supported, otherwise trigger or application rule. |
| Expected participants should not exceed space capacity. | Trigger or application rule checking related `spaces.capacity`. |

## 8. Normalization Check

The schema is designed to satisfy Third Normal Form for the stated requirements.

| Relation | Normalization Reasoning |
|---|---|
| `users` | User attributes depend on `user_id`; email is separately unique. No repeating groups. |
| `spaces` | Space attributes depend on `space_code`; location candidate key is unique. No repeating facility list is stored here. |
| `facilities` | Facility attributes depend on `facility_id`; facility name is unique. |
| `space_facilities` | Quantity and condition note depend on the full composite key `(space_code, facility_id)`. |
| `booking_requests` | Booking details depend on `booking_id`; user and space details remain in their own relations. |
| `approvals` | Decision attributes depend on `approval_id`; user and booking details are referenced by foreign keys. |
| `usage_sessions` | Actual usage details depend on `session_id`; booking details remain in `booking_requests`. |
| `maintenance_records` | Maintenance details depend on `maintenance_id`; user and space details are referenced by foreign keys. |

## 9. Complete Schema Listing

```text
users(
    user_id PK,
    full_name,
    email UK,
    phone_number,
    role,
    department,
    account_status
)

spaces(
    space_code PK,
    space_name,
    space_type,
    building,
    floor,
    room_number,
    capacity,
    current_status,
    usage_policy,
    UK(building, floor, room_number)
)

facilities(
    facility_id PK,
    facility_name UK,
    description
)

space_facilities(
    space_code PK FK -> spaces.space_code,
    facility_id PK FK -> facilities.facility_id,
    quantity,
    condition_note
)

booking_requests(
    booking_id PK,
    requester_id FK -> users.user_id,
    space_code FK -> spaces.space_code,
    requested_start_time,
    requested_end_time,
    purpose_of_use,
    expected_participants,
    booking_status,
    created_at
)

approvals(
    approval_id PK,
    booking_id FK -> booking_requests.booking_id,
    staff_id FK -> users.user_id,
    decision,
    decision_time,
    decision_note,
    rejection_reason
)

usage_sessions(
    session_id PK,
    booking_id UK FK -> booking_requests.booking_id,
    actual_start_time,
    checked_in_by FK -> users.user_id,
    initial_condition,
    actual_end_time,
    final_condition,
    usage_notes
)

maintenance_records(
    maintenance_id PK,
    space_code FK -> spaces.space_code,
    reporter_id FK -> users.user_id,
    assigned_staff_id FK -> users.user_id,
    problem_type,
    problem_description,
    start_time,
    completion_time,
    maintenance_status,
    result_note
)
```
