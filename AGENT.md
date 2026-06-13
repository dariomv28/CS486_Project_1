# AGENT DEFINITION: CAMPUS SPACE MANAGEMENT SYSTEM AGENT

## 1. Role & Mission
You are an AI Agent assigned to execute Phase 1 of the Campus Space Management System project for the course CS486 - Introduction to Database System. Your mission is to complete the database design and implementation based strictly on the business requirements provided.

## 2. Core Business Requirements
You must base all your designs, constraints, and scripts on the following rules from the School of Computer Science:

### 2.1. System Context
* The School manages shared spaces: auditoriums, classrooms, computer laboratories, project laboratories, meeting rooms, and student workspaces.
* The system must manage space booking, approval, usage sessions, maintenance, incident reporting, and facility utilization.

### 2.2. Detailed Requirements
* **Users:** Must have a university account. Store: user ID, full name, email, phone number, role, department, and account status. Roles include: student, lecturer, teaching assistant, facility staff, department administrator, or facility manager.
* **Spaces:** Store: unique space code, space name, space type, building, floor, room number, capacity, current status, and usage policy. Statuses include: available, in use, under maintenance, temporarily closed, or retired.
* **Facilities:** Store the list of facilities available in each space (e.g., projector, whiteboard, microphone, computer, livestreaming equipment, air conditioner).
* **Booking Requests:** Users select a space, requested start time, requested end time, purpose of use, and expected number of participants. Purposes include: lecture, examination, seminar, workshop, meeting, student activity, or administrative event.
* **Booking Status & Constraints:** Statuses include: pending, approved, rejected, cancelled, checked in, completed, or no-show. 
  * The same space cannot have two approved bookings with overlapping time periods.
  * A space under maintenance, closed, or retired cannot be booked.
* **Approvals:** Requires approval from facility staff or manager. Record: staff member, decision time, and decision note. If rejected, store the rejection reason.
* **Usage Sessions:** * **Check-in:** Record actual start time, person who checked in, and initial condition of the space.
  * **Complete:** Record actual end time, final condition of the space, and usage notes.
* **Maintenance:** Track problems like broken projectors, air-conditioning failure, damaged furniture, cleaning issues, or network problems. Store: related space, reporter, assigned staff member, problem description, start time, completion time, status, and result note.

## 3. Required Deliverables
You must execute the following 7 tasks and save the outputs into the `outputs/` folder with exact names:

1. **Task 1: Business Requirement Analysis** -> `outputs/01-business-req-analysis-G10.md`
   * Identify actors, entities, attributes, relationships, cardinalities, and business rules.
2. **Task 2: Conceptual Database Design** -> `outputs/02-erd-design-G10.md`
   * Design an ERD showing main entities, attributes, relationships, cardinalities, and participation constraints.
3. **Task 3: Logical Database Design** -> `outputs/03-logical-design-G10.md`
   * Convert ERD into a relational schema with relations, attributes, primary keys, foreign keys, candidate keys, and key constraints.
4. **Task 4: Database Design Validation** -> `outputs/04-design-validation-G10.md`
   * Evaluate whether the relational schema correctly represents the ERD and satisfies business rules.
5. **Task 5: Database Implementation** -> `outputs/05-db-definition-G10.sql`
   * Implement the database using SQL DDL with tables, keys, constraints, checks, and default values.
6. **Task 6: Sample Data Preparation** -> `outputs/06-sample-data-G10.sql`
   * Insert realistic sample data for testing normal operations and exceptional cases.
7. **Task 7: Query Design** -> `outputs/07-query-design-G10.sql`
   * Design and execute at least 5 meaningful SQL queries. Each query must include: Business question, Target user(s), Short explanation of utility, and the SQL statement.