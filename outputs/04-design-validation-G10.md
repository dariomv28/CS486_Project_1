# Task 4: Database Design Validation

## 1. Validation Objective

This document validates whether the relational schema from Task 3 correctly represents the conceptual ERD from Task 2 and satisfies the business rules identified in Task 1 for the Campus Space Management System.

The validation checks:

1. Completeness of entity-to-relation mapping.
2. Correctness of primary keys, candidate keys, and foreign keys.
3. Correctness of relationship and cardinality mapping.
4. Coverage of required business rules and constraints.
5. Normalization quality and avoidance of unnecessary redundancy.
6. Identification of rules that require advanced SQL constraints, triggers, stored procedures, or application logic.

## 2. Entity-to-Relation Validation

| ERD Entity | Relational Table | Validation Result | Explanation |
|---|---|---|---|
| `USER` | `users` | Valid | All required user attributes are represented: user ID, full name, email, phone number, role, department, and account status. |
| `SPACE` | `spaces` | Valid | All required space attributes are represented: space code, name, type, building, floor, room number, capacity, current status, and usage policy. |
| `FACILITY` | `facilities` | Valid | Facility types are stored separately to avoid repeating facility names in the `spaces` table. |
| `SPACE_FACILITY` | `space_facilities` | Valid | Correctly resolves the many-to-many relationship between spaces and facilities. |
| `BOOKING_REQUEST` | `booking_requests` | Valid | Stores requester, selected space, requested time range, purpose, expected participants, status, and creation time. |
| `APPROVAL` | `approvals` | Valid | Stores booking decision, staff member, decision time, decision note, and rejection reason. |
| `USAGE_SESSION` | `usage_sessions` | Valid | Stores actual check-in and completion details for approved bookings. |
| `MAINTENANCE_RECORD` | `maintenance_records` | Valid | Stores related space, reporter, assigned staff member, problem details, timing, status, and result note. |

Conclusion: All entities from the conceptual ERD are represented in the relational schema.

## 3. Attribute Coverage Validation

### 3.1 User Attributes

| Required Attribute | Table Attribute | Validation Result |
|---|---|---|
| User ID | `users.user_id` | Covered |
| Full name | `users.full_name` | Covered |
| Email | `users.email` | Covered and unique |
| Phone number | `users.phone_number` | Covered |
| Role | `users.role` | Covered with domain constraint |
| Department | `users.department` | Covered |
| Account status | `users.account_status` | Covered with domain constraint |

### 3.2 Space Attributes

| Required Attribute | Table Attribute | Validation Result |
|---|---|---|
| Unique space code | `spaces.space_code` | Covered as primary key |
| Space name | `spaces.space_name` | Covered |
| Space type | `spaces.space_type` | Covered with domain constraint |
| Building | `spaces.building` | Covered |
| Floor | `spaces.floor` | Covered |
| Room number | `spaces.room_number` | Covered |
| Capacity | `spaces.capacity` | Covered with positive-number constraint |
| Current status | `spaces.current_status` | Covered with domain constraint |
| Usage policy | `spaces.usage_policy` | Covered |

### 3.3 Booking, Approval, Usage, and Maintenance Attributes

| Requirement Area | Validation Result | Explanation |
|---|---|---|
| Facilities available in each space | Covered | `facilities` and `space_facilities` store facility types and their assignment to spaces. |
| Booking request details | Covered | `booking_requests` stores requester, space, time range, purpose, expected participants, status, and creation time. |
| Approval details | Covered | `approvals` stores approving staff, decision time, note, decision, and rejection reason. |
| Check-in details | Covered | `usage_sessions` stores actual start time, checked-in-by user, and initial condition. |
| Completion details | Covered | `usage_sessions` stores actual end time, final condition, and usage notes. |
| Maintenance details | Covered | `maintenance_records` stores related space, reporter, assigned staff, problem description, start time, completion time, status, and result note. |

Conclusion: All required attributes from the business requirements are represented in the logical schema.

## 4. Key Constraint Validation

| Table | Primary Key | Candidate / Unique Keys | Validation Result |
|---|---|---|---|
| `users` | `user_id` | `email` | Valid. User ID uniquely identifies each user; email is also unique. |
| `spaces` | `space_code` | `(building, floor, room_number)` | Valid. Space code is the main identifier; physical room location is also unique. |
| `facilities` | `facility_id` | `facility_name` | Valid. Facility names are prevented from duplicating. |
| `space_facilities` | `(space_code, facility_id)` | Same as primary key | Valid. Prevents duplicate facility entries for the same space. |
| `booking_requests` | `booking_id` | None required | Valid. Booking ID uniquely identifies each request. |
| `approvals` | `approval_id` | None required | Valid. Approval ID uniquely identifies each decision record. |
| `usage_sessions` | `session_id` | `booking_id` | Valid. Session ID identifies the session, and unique booking ID enforces at most one session per booking. |
| `maintenance_records` | `maintenance_id` | None required | Valid. Maintenance ID uniquely identifies each maintenance record. |

Conclusion: Primary keys and candidate keys are appropriate and sufficient for the required data model.

## 5. Relationship and Cardinality Validation

| ERD Relationship | Relational Implementation | Cardinality Validation |
|---|---|---|
| User submits booking requests | `booking_requests.requester_id` references `users.user_id` | Valid. One user can submit many bookings; each booking has exactly one requester. |
| Space receives booking requests | `booking_requests.space_code` references `spaces.space_code` | Valid. One space can receive many bookings; each booking is for exactly one space. |
| Space has facilities | `space_facilities.space_code` references `spaces.space_code` | Valid. One space can have many facility entries. |
| Facility appears in spaces | `space_facilities.facility_id` references `facilities.facility_id` | Valid. One facility type can appear in many spaces. |
| Space M:N Facility | `space_facilities(space_code, facility_id)` | Valid. Associative table correctly resolves the many-to-many relationship. |
| Booking request has approvals | `approvals.booking_id` references `booking_requests.booking_id` | Valid. One booking can have zero or many approval records. |
| User makes approvals | `approvals.staff_id` references `users.user_id` | Valid. One staff user can make many approval decisions. Role restriction requires additional enforcement. |
| Booking request produces usage session | `usage_sessions.booking_id` references `booking_requests.booking_id` with `UNIQUE` | Valid. One booking can have zero or one usage session. |
| User checks in usage session | `usage_sessions.checked_in_by` references `users.user_id` | Valid. One user can check in many sessions; each session records one check-in user. |
| Space has maintenance records | `maintenance_records.space_code` references `spaces.space_code` | Valid. One space can have many maintenance records. |
| User reports maintenance records | `maintenance_records.reporter_id` references `users.user_id` | Valid. One user can report many maintenance issues. |
| User is assigned maintenance records | `maintenance_records.assigned_staff_id` references `users.user_id` and allows NULL | Valid. One staff user can be assigned many records; assignment can be pending. |

Conclusion: The relational schema correctly implements the ERD relationships and cardinalities.

## 6. Participation Constraint Validation

| Participation Rule | Schema Support | Validation Result |
|---|---|---|
| Every booking must have one requester. | `booking_requests.requester_id` is not null and references `users`. | Satisfied. |
| Every booking must have one space. | `booking_requests.space_code` is not null and references `spaces`. | Satisfied. |
| A user may exist without bookings. | No required booking reference in `users`. | Satisfied. |
| A space may exist without bookings. | No required booking reference in `spaces`. | Satisfied. |
| Every space-facility row must reference one space and one facility. | Composite primary key and foreign keys in `space_facilities`. | Satisfied. |
| A booking may be pending without approval. | Approval records are stored separately in `approvals`. | Satisfied. |
| Every approval must reference one booking and one staff user. | `approvals.booking_id` and `approvals.staff_id` are not null foreign keys. | Satisfied. |
| A booking may have no usage session. | `usage_sessions` is separate from `booking_requests`. | Satisfied. |
| A booking may have at most one usage session. | `usage_sessions.booking_id` is unique. | Satisfied. |
| Every maintenance record must reference one space and one reporter. | `space_code` and `reporter_id` are not null foreign keys. | Satisfied. |
| Maintenance assignment may be pending. | `assigned_staff_id` allows NULL. | Satisfied. |

Conclusion: Participation constraints from the ERD are correctly represented.

## 7. Business Rule Validation

| Business Rule | Schema Support | Validation Result |
|---|---|---|
| Users must have university accounts. | `users` stores account details and `account_status`. | Satisfied at data level; account authenticity is an organizational/application rule. |
| User roles must be restricted to allowed roles. | `CHECK` constraint on `users.role`. | Satisfied. |
| User email must be unique. | `UNIQUE (email)` in `users`. | Satisfied. |
| Spaces must have unique space codes. | Primary key on `spaces.space_code`. | Satisfied. |
| Space statuses must be restricted to allowed statuses. | `CHECK` constraint on `spaces.current_status`. | Satisfied. |
| Space types must be restricted to allowed types. | `CHECK` constraint on `spaces.space_type`. | Satisfied. |
| Space capacity must be positive. | `CHECK (capacity > 0)`. | Satisfied. |
| Facility list for each space must be stored. | `space_facilities` links spaces and facilities. | Satisfied. |
| The same facility should not be duplicated for one space. | Composite primary key `(space_code, facility_id)`. | Satisfied. |
| Requested end time must be later than requested start time. | `CHECK (requested_end_time > requested_start_time)`. | Satisfied. |
| Booking purpose must be restricted to allowed purposes. | `CHECK` constraint on `booking_requests.purpose_of_use`. | Satisfied. |
| Booking status must be restricted to allowed statuses. | `CHECK` constraint on `booking_requests.booking_status`. | Satisfied. |
| Rejected approvals must store a rejection reason. | Conditional check on `approvals.rejection_reason`. | Satisfied. |
| Actual end time must be later than actual start time. | Conditional check in `usage_sessions`. | Satisfied. |
| Completed usage must record final condition. | Conditional check in `usage_sessions`. | Satisfied. |
| Maintenance problem type and status must be controlled. | `CHECK` constraints in `maintenance_records`. | Satisfied. |
| Maintenance completion time must be later than start time. | Conditional check in `maintenance_records`. | Satisfied. |
| Completed maintenance must include completion time and result note. | Conditional check in `maintenance_records`. | Satisfied. |
| Only facility staff or managers may approve bookings. | Requires role check against `users.role`. | Partially satisfied; needs trigger, stored procedure, or application logic. |
| Assigned maintenance staff must be facility staff or manager. | Requires role check against `users.role`. | Partially satisfied; needs trigger, stored procedure, or application logic. |
| A space under maintenance, closed, or retired cannot be booked. | Requires checking related `spaces.current_status` during approval or booking. | Partially satisfied; needs trigger, stored procedure, or application logic. |
| Approved bookings for the same space cannot overlap. | Requires cross-row overlap validation. | Partially satisfied; needs exclusion constraint where supported or trigger/application logic. |
| Expected participants should not exceed capacity. | Requires checking related `spaces.capacity`. | Partially satisfied; needs trigger, stored procedure, or application logic. |

Conclusion: The schema satisfies all rules that can be represented with normal relational constraints. Rules involving related-table values or cross-row time overlap are correctly identified as requiring procedural or advanced database enforcement.

## 8. Normalization Validation

| Relation | 1NF Validation | 2NF Validation | 3NF Validation |
|---|---|---|---|
| `users` | Atomic attributes; no repeating groups. | Single-column primary key, so no partial dependency. | User details depend only on user ID; email is a candidate key. |
| `spaces` | Atomic room and status attributes; facilities are not stored as a repeating list. | Single-column primary key, so no partial dependency. | Space details depend on space code; location candidate key is unique. |
| `facilities` | Atomic facility attributes. | Single-column primary key, so no partial dependency. | Facility description depends on facility ID; facility name is unique. |
| `space_facilities` | Atomic attributes. | `quantity` and `condition_note` depend on the full composite key. | No non-key attribute depends on another non-key attribute. |
| `booking_requests` | Atomic booking details. | Single-column primary key, so no partial dependency. | User and space details are not duplicated; only foreign keys are stored. |
| `approvals` | Atomic approval decision details. | Single-column primary key, so no partial dependency. | Booking and staff details remain in parent tables. |
| `usage_sessions` | Atomic session details. | Single-column primary key, so no partial dependency. | Booking details remain in `booking_requests`; user details remain in `users`. |
| `maintenance_records` | Atomic maintenance details. | Single-column primary key, so no partial dependency. | Space and user details are referenced, not duplicated. |

Conclusion: The schema is in Third Normal Form for the stated requirements.

## 9. Integrity Risk Review

| Risk | Impact | Resolution in Later Implementation |
|---|---|---|
| Approval staff role cannot be enforced by a simple foreign key. | A non-staff user could be recorded as approver if no extra rule exists. | Add trigger or stored procedure check in Task 5. |
| Maintenance assignment role cannot be enforced by a simple foreign key. | Maintenance work could be assigned to an invalid user role. | Add trigger or stored procedure check in Task 5. |
| Booking overlap requires comparison with existing bookings. | Two approved bookings might reserve the same space at overlapping times. | Add trigger or exclusion-style constraint in Task 5. |
| Space availability depends on the related space status. | A closed, retired, or maintenance space might be approved. | Add trigger or controlled approval procedure in Task 5. |
| Expected participants depend on related space capacity. | A booking could exceed room capacity. | Add trigger or controlled booking procedure in Task 5. |
| Booking and approval statuses must remain synchronized. | A booking could show `approved` without a matching approval decision. | Add procedural workflow checks or triggers. |

These risks do not invalidate the relational design. They identify business rules that require enforcement beyond basic entity and relationship mapping.

## 10. Overall Validation Result

The relational schema from Task 3 correctly represents the conceptual ERD from Task 2 and satisfies the business requirements from Task 1 at the logical design level.

Validation summary:

| Validation Area | Result |
|---|---|
| Entity mapping | Passed |
| Attribute coverage | Passed |
| Primary key design | Passed |
| Candidate key and unique constraint design | Passed |
| Foreign key design | Passed |
| Relationship cardinality mapping | Passed |
| Participation constraints | Passed |
| Basic business rules | Passed |
| Cross-table and cross-row business rules | Passed with implementation notes |
| Normalization | Passed, satisfies 3NF |

Final conclusion: The design is valid and ready for database implementation in Task 5, provided that the implementation includes procedural or advanced SQL enforcement for cross-table and cross-row rules such as staff authorization, room status validation, capacity validation, and prevention of overlapping approved bookings.
