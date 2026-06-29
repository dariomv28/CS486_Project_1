-- Task 6: Sample Data Preparation - Campus Space Management System
-- DBMS target: Microsoft SQL Server
-- Run after outputs/05-db-definition-G10.sql

DELETE FROM dbo.maintenance_records;
DELETE FROM dbo.usage_sessions;
DELETE FROM dbo.approvals;
DELETE FROM dbo.booking_requests;
DELETE FROM dbo.space_facilities;
DELETE FROM dbo.facilities;
DELETE FROM dbo.spaces;
DELETE FROM dbo.users;
GO

DBCC CHECKIDENT ('dbo.maintenance_records', RESEED, 0);
DBCC CHECKIDENT ('dbo.booking_requests', RESEED, 0);
DBCC CHECKIDENT ('dbo.facilities', RESEED, 0);
GO

INSERT INTO dbo.users (user_id, full_name, email, phone_number, role, department, account_status) VALUES
('U001', N'Nguyen Minh Anh', 'anh.nguyen@university.edu', '0901000001', N'student', N'Computer Science', 'active'),
('U002', N'Tran Quoc Bao', 'bao.tran@university.edu', '0901000002', N'lecturer', N'Computer Science', 'active'),
('U003', N'Le Thu Chi', 'chi.le@university.edu', '0901000003', N'teaching assistant', N'Computer Science', 'active'),
('U004', N'Pham Hoang Duy', 'duy.pham@university.edu', '0901000004', N'facility staff', N'Facilities Office', 'active'),
('U005', N'Hoang Gia Linh', 'linh.hoang@university.edu', '0901000005', N'department administrator', N'Computer Science', 'active'),
('U006', N'Do Thanh Mai', 'mai.do@university.edu', '0901000006', N'facility manager', N'Facilities Office', 'active'),
('U007', N'Bui Hai Nam', 'nam.bui@university.edu', '0901000007', N'student', N'Computer Science', 'inactive'),
('U008', N'Vu Khanh Ngan', 'ngan.vu@university.edu', '0901000008', N'facility staff', N'Facilities Office', 'active'),
('U009', N'Dang Nhat Phong', 'phong.dang@university.edu', '0901000009', N'lecturer', N'Information Systems', 'active');
GO

INSERT INTO dbo.spaces (space_code, space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy) VALUES
('CS-AUD-101', N'Main CS Auditorium', N'auditorium', N'CS Building', '1', '101', 250, N'available', N'Priority for seminars, examinations, and school-wide events.'),
('CS-CLS-201', N'Database Classroom', N'classroom', N'CS Building', '2', '201', 80, N'available', N'Academic classes have priority during weekdays.'),
('CS-LAB-301', N'Programming Laboratory', N'computer laboratory', N'CS Building', '3', '301', 40, N'available', N'Food and drinks are not allowed near computers.'),
('CS-LAB-302', N'Networks Laboratory', N'computer laboratory', N'CS Building', '3', '302', 35, N'under maintenance', N'Bookings allowed only after maintenance clearance.'),
('CS-PROJ-401', N'Capstone Project Laboratory', N'project laboratory', N'Innovation Center', '4', '401', 25, N'available', N'Project teams must clean benches after use.'),
('CS-MEET-501', N'Faculty Meeting Room', N'meeting room', N'Administration Block', '5', '501', 20, N'available', N'Department and committee meetings have priority.'),
('CS-WORK-601', N'Student Collaboration Space', N'student workspace', N'Learning Commons', '6', '601', 60, N'available', N'Open for student academic activities.'),
('CS-CLS-202', N'Temporarily Closed Classroom', N'classroom', N'CS Building', '2', '202', 60, N'temporarily closed', N'Closed for renovation.'),
('CS-OLD-001', N'Retired Legacy Lab', N'computer laboratory', N'Old Engineering Block', '1', '001', 30, N'retired', N'No longer available for booking.');
GO

SET IDENTITY_INSERT dbo.facilities ON;

INSERT INTO dbo.facilities (facility_id, facility_name, description) VALUES
(1, N'projector', N'Ceiling or portable projector for presentations.'),
(2, N'whiteboard', N'Writing board for teaching and discussion.'),
(3, N'microphone', N'Audio microphone for large rooms.'),
(4, N'computer', N'Desktop computer workstation.'),
(5, N'livestreaming equipment', N'Camera and encoder equipment for live events.'),
(6, N'air conditioner', N'Room air-conditioning unit.'),
(7, N'network access', N'Wired or wireless network access.'),
(8, N'video conferencing equipment', N'Camera, speaker, and display setup for hybrid meetings.');

SET IDENTITY_INSERT dbo.facilities OFF;
GO

INSERT INTO dbo.space_facilities (space_code, facility_id, quantity, condition_note) VALUES
('CS-AUD-101', 1, 2, N'Both projectors operational.'),
('CS-AUD-101', 2, 1, N'Large side whiteboard.'),
('CS-AUD-101', 3, 4, N'Two handheld and two lapel microphones.'),
('CS-AUD-101', 5, 1, N'Livestreaming rack available on request.'),
('CS-AUD-101', 6, 4, N'Central air conditioning.'),
('CS-CLS-201', 1, 1, N'Projector tested this semester.'),
('CS-CLS-201', 2, 2, N'Front and side boards.'),
('CS-CLS-201', 6, 1, N'Working normally.'),
('CS-LAB-301', 1, 1, N'Projector connected to instructor machine.'),
('CS-LAB-301', 4, 40, N'Windows and Linux dual-boot workstations.'),
('CS-LAB-301', 7, 40, N'Gigabit wired access.'),
('CS-LAB-302', 4, 35, N'Network lab machines under inspection.'),
('CS-LAB-302', 7, 35, N'Core switch replacement pending.'),
('CS-PROJ-401', 2, 1, N'Movable whiteboard.'),
('CS-PROJ-401', 4, 10, N'High-performance workstations.'),
('CS-PROJ-401', 7, 10, N'Project VLAN available.'),
('CS-MEET-501', 1, 1, N'Short-throw projector.'),
('CS-MEET-501', 8, 1, N'Hybrid meeting kit.'),
('CS-WORK-601', 2, 3, N'Portable whiteboards.'),
('CS-WORK-601', 6, 2, N'Open-area air conditioning.'),
('CS-WORK-601', 7, 1, N'Campus Wi-Fi coverage.');
GO

SET IDENTITY_INSERT dbo.booking_requests ON;

INSERT INTO dbo.booking_requests (booking_id, requester_id, space_code, requested_start_time, requested_end_time, purpose_of_use, expected_participants, booking_status, created_at) VALUES
(1, 'U001', 'CS-WORK-601', '2026-07-01T13:00:00', '2026-07-01T15:00:00', N'student activity', 35, N'pending', '2026-06-10T08:10:00'),
(2, 'U002', 'CS-CLS-201', '2026-07-01T09:00:00', '2026-07-01T11:00:00', N'lecture', 70, N'pending', '2026-06-10T08:20:00'),
(3, 'U005', 'CS-AUD-101', '2026-07-02T14:00:00', '2026-07-02T16:00:00', N'seminar', 180, N'pending', '2026-06-10T08:30:00'),
(4, 'U003', 'CS-LAB-301', '2026-07-03T10:00:00', '2026-07-03T13:00:00', N'workshop', 38, N'pending', '2026-06-10T08:40:00'),
(5, 'U009', 'CS-MEET-501', '2026-07-04T09:00:00', '2026-07-04T10:00:00', N'meeting', 15, N'pending', '2026-06-10T08:50:00'),
(6, 'U005', 'CS-MEET-501', '2026-07-05T15:00:00', '2026-07-05T17:00:00', N'administrative event', 18, N'cancelled', '2026-06-10T09:00:00'),
(7, 'U001', 'CS-PROJ-401', '2026-07-06T09:00:00', '2026-07-06T12:00:00', N'student activity', 12, N'pending', '2026-06-10T09:10:00');

SET IDENTITY_INSERT dbo.booking_requests OFF;
GO

INSERT INTO dbo.approvals (booking_id, staff_id, decision, decision_time, decision_note, rejection_reason) VALUES
(2, 'U004', N'approved', '2026-06-10T10:00:00', N'Classroom is available for the scheduled lecture.', NULL),
(3, 'U006', N'approved', '2026-06-10T10:05:00', N'Auditorium approved for department seminar.', NULL),
(4, 'U004', N'approved', '2026-06-10T10:10:00', N'Lab available with 40 computers.', NULL),
(5, 'U006', N'rejected', '2026-06-10T10:15:00', N'Rejected due to a higher-priority faculty committee reservation.', N'Faculty committee meeting has priority.'),
(7, 'U008', N'approved', '2026-06-10T10:20:00', N'Project laboratory approved for capstone work.', NULL);
GO

INSERT INTO dbo.usage_sessions (booking_id, actual_start_time, checked_in_by, initial_condition, actual_end_time, final_condition, usage_notes) VALUES
(4, '2026-07-03T10:05:00', 'U004', N'Lab was clean; all instructor equipment working.', '2026-07-03T12:50:00', N'Room left clean; one workstation reported slow network login.', N'Workshop completed successfully.'),
(7, '2026-07-06T09:03:00', 'U008', N'Project benches clean and all assigned workstations available.', NULL, NULL, N'Session currently checked in.');
GO

SET IDENTITY_INSERT dbo.maintenance_records ON;

INSERT INTO dbo.maintenance_records (maintenance_id, space_code, reporter_id, assigned_staff_id, problem_type, problem_description, start_time, completion_time, maintenance_status, result_note) VALUES
(1, 'CS-LAB-302', 'U002', 'U004', N'air-conditioning failure', N'Air-conditioning unit stops after ten minutes of use.', '2026-06-09T08:00:00', NULL, N'in progress', NULL),
(2, 'CS-CLS-201', 'U002', 'U008', N'broken projector', N'Projector brightness is low and image flickers.', '2026-06-08T13:00:00', '2026-06-09T16:00:00', N'completed', N'Projector lamp replaced and tested.'),
(3, 'CS-MEET-501', 'U005', NULL, N'cleaning issue', N'Whiteboard markers leaked and table requires cleaning.', '2026-06-11T09:30:00', NULL, N'reported', NULL),
(4, 'CS-LAB-301', 'U003', 'U004', N'network problem', N'One workstation had slow login during workshop.', '2026-07-03T13:15:00', '2026-07-03T15:00:00', N'completed', N'Network profile reset on affected workstation.');

SET IDENTITY_INSERT dbo.maintenance_records OFF;
GO

PRINT 'Normal sample data inserted successfully.';
GO

-- Exceptional case 1: inactive users cannot submit booking requests.
BEGIN TRY
    INSERT INTO dbo.booking_requests (requester_id, space_code, requested_start_time, requested_end_time, purpose_of_use, expected_participants)
    VALUES ('U007', 'CS-WORK-601', '2026-07-08T09:00:00', '2026-07-08T10:00:00', N'student activity', 10);
END TRY
BEGIN CATCH
    PRINT 'Expected failure - inactive user booking: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Exceptional case 2: expected participants cannot exceed room capacity.
BEGIN TRY
    INSERT INTO dbo.booking_requests (requester_id, space_code, requested_start_time, requested_end_time, purpose_of_use, expected_participants)
    VALUES ('U005', 'CS-AUD-101', '2026-07-08T10:00:00', '2026-07-08T12:00:00', N'seminar', 300);
END TRY
BEGIN CATCH
    PRINT 'Expected failure - capacity exceeded: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Exceptional case 3: a space under maintenance cannot be booked.
BEGIN TRY
    INSERT INTO dbo.booking_requests (requester_id, space_code, requested_start_time, requested_end_time, purpose_of_use, expected_participants)
    VALUES ('U002', 'CS-LAB-302', '2026-07-09T09:00:00', '2026-07-09T11:00:00', N'workshop', 20);
END TRY
BEGIN CATCH
    PRINT 'Expected failure - maintenance space booking: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Exceptional case 4: approving an overlapping booking is rejected by the trigger.
DECLARE @overlap_booking_id INT;

INSERT INTO dbo.booking_requests (requester_id, space_code, requested_start_time, requested_end_time, purpose_of_use, expected_participants)
VALUES ('U009', 'CS-CLS-201', '2026-07-01T10:00:00', '2026-07-01T12:00:00', N'lecture', 45);

SET @overlap_booking_id = SCOPE_IDENTITY();

BEGIN TRY
    INSERT INTO dbo.approvals (booking_id, staff_id, decision, decision_note)
    VALUES (@overlap_booking_id, 'U004', N'approved', N'This approval should fail because it overlaps booking 2.');
END TRY
BEGIN CATCH
    PRINT 'Expected failure - overlapping approved booking: ' + ERROR_MESSAGE();
END CATCH;

DELETE FROM dbo.booking_requests WHERE booking_id = @overlap_booking_id;
GO

-- Exceptional case 5: only facility staff or managers can approve requests.
DECLARE @nonstaff_booking_id INT;

INSERT INTO dbo.booking_requests (requester_id, space_code, requested_start_time, requested_end_time, purpose_of_use, expected_participants)
VALUES ('U001', 'CS-AUD-101', '2026-07-10T09:00:00', '2026-07-10T10:00:00', N'student activity', 30);

SET @nonstaff_booking_id = SCOPE_IDENTITY();

BEGIN TRY
    INSERT INTO dbo.approvals (booking_id, staff_id, decision, decision_note)
    VALUES (@nonstaff_booking_id, 'U001', N'approved', N'This approval should fail because the approver is a student.');
END TRY
BEGIN CATCH
    PRINT 'Expected failure - non-staff approval: ' + ERROR_MESSAGE();
END CATCH;

DELETE FROM dbo.booking_requests WHERE booking_id = @nonstaff_booking_id;
GO

-- Exceptional case 6: maintenance work cannot be assigned to a non-staff user.
BEGIN TRY
    INSERT INTO dbo.maintenance_records (space_code, reporter_id, assigned_staff_id, problem_type, problem_description)
    VALUES ('CS-WORK-601', 'U001', 'U001', N'cleaning issue', N'This assignment should fail because the assignee is a student.');
END TRY
BEGIN CATCH
    PRINT 'Expected failure - invalid maintenance assignee: ' + ERROR_MESSAGE();
END CATCH;
GO

PRINT 'Exceptional validation cases completed. Expected failures were caught and reported.';
GO
