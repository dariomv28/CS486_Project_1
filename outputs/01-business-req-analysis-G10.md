# Task 1: Business Requirement Analysis

## 1. Project Scope

The Campus Space Management System supports the School of Computer Science in managing shared spaces, booking requests, approvals, actual usage sessions, maintenance work, incident-style problem reporting, and facility utilization.

The system must ensure that only users with university accounts can request or manage spaces, that spaces are booked according to their status and policy, and that staff or managers approve requests before confirmed use.

## 2. Actors

| Actor | Description | Main Responsibilities |
|---|---|---|
| Student | University account holder who may request spaces for student activities or work. | Submit booking requests, check in when authorized, report maintenance problems. |
| Lecturer | Academic staff member who may request teaching or academic spaces. | Submit booking requests for lectures, examinations, seminars, or workshops. |
| Teaching Assistant | Academic support user who may request or assist with space usage. | Submit booking requests, support class or lab activities, report issues. |
| Facility Staff | Staff member responsible for space operations. | Approve or reject bookings, check users in, handle maintenance tasks, update space condition. |
| Department Administrator | Administrative user who may request or coordinate official department events. | Submit administrative event bookings and monitor usage needs. |
| Facility Manager | Senior facility user responsible for oversight. | Approve or reject bookings, supervise facility staff, review utilization and maintenance status. |

## 3. Main Entities and Attributes

### 3.1 User

Represents a university account holder who can request spaces, approve requests if authorized, check in usage sessions, report maintenance problems, or be assigned maintenance work.

Attributes:

| Attribute | Description | Constraint / Domain |
|---|---|---|
| user_id | Unique user identifier. | Primary key. |
| full_name | User's full legal or university name. | Required. |
| email | University email account. | Required, unique. |
| phone_number | Contact number. | Optional or required depending on local policy; stored for contact. |
| role | User role. | student, lecturer, teaching assistant, facility staff, department administrator, facility manager. |
| department | User's department. | Required. |
| account_status | Current account status. | Active/inactive-style domain; only valid accounts may use the system. |

### 3.2 Space

Represents a physical shared space managed by the School.

Attributes:

| Attribute | Description | Constraint / Domain |
|---|---|---|
| space_code | Unique code identifying the space. | Primary key / candidate key. |
| space_name | Display name of the space. | Required. |
| space_type | Category of space. | auditorium, classroom, computer laboratory, project laboratory, meeting room, student workspace. |
| building | Building name or code. | Required. |
| floor | Floor number or label. | Required. |
| room_number | Room number. | Required. |
| capacity | Maximum occupancy. | Positive integer. |
| current_status | Operational status of the space. | available, in use, under maintenance, temporarily closed, retired. |
| usage_policy | Rules or policy text for use of the space. | Required or optional policy text. |

Candidate keys:

| Candidate Key | Rationale |
|---|---|
| space_code | Explicit unique identifier required by the business rules. |
| building + floor + room_number | Physical room location should uniquely identify a space if room numbering is controlled. |

### 3.3 Facility

Represents an available facility or equipment type that may exist in spaces.

Attributes:

| Attribute | Description | Constraint / Domain |
|---|---|---|
| facility_id | Unique facility identifier. | Primary key. |
| facility_name | Facility name. | Required, unique. Examples: projector, whiteboard, microphone, computer, livestreaming equipment, air conditioner. |
| description | Optional details about the facility. | Optional. |

### 3.4 Space Facility

Associative entity showing which facilities are available in which spaces.

Attributes:

| Attribute | Description | Constraint / Domain |
|---|---|---|
| space_code | Related space. | Foreign key to Space. |
| facility_id | Related facility. | Foreign key to Facility. |
| quantity | Number of that facility in the space. | Positive integer, if tracked. |
| condition_note | Optional note about facility condition. | Optional. |

Primary key: space_code + facility_id.

### 3.5 Booking Request

Represents a user's request to reserve a space for a specific time period and purpose.

Attributes:

| Attribute | Description | Constraint / Domain |
|---|---|---|
| booking_id | Unique booking request identifier. | Primary key. |
| requester_id | User who submits the booking. | Foreign key to User. |
| space_code | Requested space. | Foreign key to Space. |
| requested_start_time | Requested start date and time. | Required. |
| requested_end_time | Requested end date and time. | Required; must be later than start time. |
| purpose_of_use | Purpose for using the space. | lecture, examination, seminar, workshop, meeting, student activity, administrative event. |
| expected_participants | Expected number of participants. | Positive integer; should not exceed space capacity. |
| booking_status | Current booking status. | pending, approved, rejected, cancelled, checked in, completed, no-show. |
| created_at | Time the request was submitted. | Default current timestamp. |

### 3.6 Approval

Represents a staff or manager decision on a booking request.

Attributes:

| Attribute | Description | Constraint / Domain |
|---|---|---|
| booking_id | Unique identifier for each approval, referencing the booking request. | Primary key, foreign key to Booking Request. |
| staff_id | Facility staff or manager who made the decision. | Foreign key to User; role must be facility staff or facility manager. |
| decision | Approval decision. | approved or rejected. |
| decision_time | Time of decision. | Required. |
| decision_note | Staff note about the decision. | Optional. |
| rejection_reason | Reason for rejection. | Required if decision is rejected. |

### 3.7 Usage Session

Represents the actual use of an approved booking, including check-in and completion details.

Attributes:

| Attribute | Description | Constraint / Domain |
|---|---|---|
| booking_id | Unique identifier for each usage session, referencing the booking request. | Primary key, foreign key to Booking Request. |
| actual_start_time | Actual check-in/start time. | Required when checked in. |
| checked_in_by | Person who performed check-in. | Foreign key to User. |
| initial_condition | Condition of the space at check-in. | Required at check-in. |
| actual_end_time | Actual completion/end time. | Required when completed. |
| final_condition | Condition of the space at completion. | Required at completion. |
| usage_notes | Notes about use of the space. | Optional. |

### 3.8 Maintenance Record

Represents a reported space problem and its resolution workflow.

Attributes:

| Attribute | Description | Constraint / Domain |
|---|---|---|
| maintenance_id | Unique maintenance record identifier. | Primary key. |
| space_code | Space with the problem. | Foreign key to Space. |
| reporter_id | User who reported the problem. | Foreign key to User. |
| assigned_staff_id | Staff member assigned to handle the problem. | Foreign key to User; role should be facility staff or facility manager. |
| problem_type | Type of problem. | broken projector, air-conditioning failure, damaged furniture, cleaning issue, network problem, or similar controlled category. |
| problem_description | Detailed problem description. | Required. |
| start_time | Time the maintenance issue was opened or started. | Required. |
| completion_time | Time maintenance was completed. | Optional until completed; must be after start time if present. |
| maintenance_status | Current maintenance status. | Open/in progress/completed-style domain. |
| result_note | Resolution or outcome note. | Required or optional depending on status; expected when completed. |

## 4. Relationships, Cardinalities, and Participation

| Relationship | Cardinality | Participation |
|---|---|---|
| User submits Booking Request | User 1 : N Booking Request | Booking Request total; User partial |
| Space receives Booking Request | Space 1 : N Booking Request | Booking Request total; Space partial |
| Space has Facility | Space M : N Facility, resolved by Space Facility | Space Facility total to both parents |
| Booking Request has Approval | Booking Request 1 : 0..1 Approval | Approval total; Booking Request partial |
| User makes Approval | User 1 : N Approval | Approval total; User partial |
| Booking Request creates Usage Session | Booking Request 1 : 0..1 Usage Session | Usage Session total; Booking Request partial |
| User checks in Usage Session | User 1 : N Usage Session | Usage Session total for check-in; User partial |
| Space has Maintenance Record | Space 1 : N Maintenance Record | Maintenance Record total; Space partial |
| User reports Maintenance Record | User 1 : N Maintenance Record | Maintenance Record total; User partial |
| User assigned Maintenance Record | User 1 : N Maintenance Record | Maintenance Record partial for assignment; User partial |

## 5. Business Rules and Constraints

### 5.1 User Rules

1. Every system user must have a university account.
2. Each user must have a unique user ID.
3. Each user email should be unique.
4. User role must be one of: student, lecturer, teaching assistant, facility staff, department administrator, facility manager.
5. Only authorized staff roles, specifically facility staff or facility manager, may approve or reject booking requests.
6. Users with inactive or invalid account status should not be allowed to submit new booking requests.

### 5.2 Space Rules

1. Each space must have a unique space code.
2. Each space must have a valid type: auditorium, classroom, computer laboratory, project laboratory, meeting room, or student workspace.
3. Each space must have a valid status: available, in use, under maintenance, temporarily closed, or retired.
4. Capacity must be a positive number.
5. A space under maintenance, temporarily closed, or retired cannot be booked.
6. A physical location should not duplicate another space with the same building, floor, and room number.

### 5.3 Facility Rules

1. A facility type may be shared by many spaces.
2. A space may contain many facility types.
3. The same facility should not be listed twice for the same space.
4. If quantity is stored, quantity must be positive.

### 5.4 Booking Rules

1. Every booking request must be submitted by exactly one user.
2. Every booking request must select exactly one space.
3. Requested end time must be later than requested start time.
4. Purpose of use must be one of: lecture, examination, seminar, workshop, meeting, student activity, administrative event.
5. Booking status must be one of: pending, approved, rejected, cancelled, checked in, completed, no-show.
6. The same space cannot have two approved bookings with overlapping time periods.
7. A booking cannot be approved if the space is under maintenance, temporarily closed, or retired.
8. Expected participants must be positive and should not exceed the selected space capacity.
9. Only approved bookings should proceed to check-in.
10. Cancelled, rejected, completed, and no-show bookings should not be treated as active reservations.

### 5.5 Approval Rules

1. Each approval decision must be associated with one booking request.
2. Each approval decision must be made by one facility staff member or facility manager.
3. Decision time must be recorded.
4. Rejected bookings must store a rejection reason.
5. Approved bookings must respect the no-overlapping-approved-bookings rule.

### 5.6 Usage Session Rules

1. A usage session must be linked to one booking request.
2. A booking request may have at most one usage session.
3. Check-in records actual start time, person who checked in, and initial condition.
4. Completion records actual end time, final condition, and usage notes.
5. Actual end time must be later than actual start time when both are present.
6. A booking marked checked in should have a usage session with check-in details.
7. A booking marked completed should have completed usage session details.

### 5.7 Maintenance Rules

1. Every maintenance record must refer to one related space.
2. Every maintenance record must have one reporter.
3. A maintenance record may be assigned to a facility staff member or facility manager.
4. Problem description must be recorded.
5. Start time must be recorded.
6. Completion time must be recorded when the maintenance task is completed.
7. Completion time must be later than start time.
8. Result note should be recorded when maintenance is completed.
9. Spaces with unresolved serious maintenance may need their status set to under maintenance.

## 6. Derived Data and Operational Information

The system can derive or report the following information from the stored entities:

| Derived Information | Source Data | Use |
|---|---|---|
| Facility utilization rate | Booking Request and Usage Session | Helps managers evaluate how often spaces are used. |
| Current active bookings | Booking Request status and requested time range | Helps staff monitor current and upcoming space usage. |
| No-show bookings | Booking Request status and Usage Session absence | Helps identify wasted reserved capacity. |
| Maintenance workload | Maintenance Record and assigned staff | Helps managers distribute facility work. |
| Space availability | Space status and approved booking schedule | Helps users and staff identify bookable spaces. |
| Frequently reported problems | Maintenance problem type and descriptions | Helps plan repairs or equipment replacement. |

## 7. Assumptions and Clarifications

1. The phrase "university account" is represented by the User entity and its account status.
2. Facility staff and facility managers are modeled as users with specific roles, not as a separate staff table.
3. Approval history may be stored as multiple approval records per booking; the latest valid decision controls the booking status.
4. Incident reporting is covered by the Maintenance Record entity because the requirements describe reporting facility problems and tracking their resolution.
5. The no-overlap rule applies to approved active reservations for the same space. Rejected, cancelled, completed, and no-show bookings do not block new bookings.
6. Space status and booking status are related but not identical. A space may be generally available while still unavailable during already approved booking periods.

## 8. Summary of Identified Entities

| Entity | Purpose |
|---|---|
| User | Stores university account holders and their roles. |
| Space | Stores managed physical spaces and their booking status. |
| Facility | Stores facility or equipment types. |
| Space Facility | Resolves the many-to-many relationship between spaces and facilities. |
| Booking Request | Stores requested reservations and booking lifecycle status. |
| Approval | Stores staff or manager decisions on booking requests. |
| Usage Session | Stores actual check-in and completion information. |
| Maintenance Record | Stores reported problems, assigned staff, progress, and results. |
