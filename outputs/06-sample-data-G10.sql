-- Task 6: Sample Data Preparation - Campus Space Management System
-- DBMS target: Microsoft SQL Server
-- This script assumes that outputs/05-db-definition-G10.sql has already been executed.

USE CampusSpaceManagement;
GO

/* ============================================================
   1. Reset existing sample data
   ============================================================ */
DELETE FROM dbo.maintenance_records;
DELETE FROM dbo.usage_sessions;
DELETE FROM dbo.approvals;
DELETE FROM dbo.booking_requests;
DELETE FROM dbo.facilities;
DELETE FROM dbo.spaces;
DELETE FROM dbo.users;
GO

/* ============================================================
   2. Users
   Covers all user roles and account statuses.
   ============================================================ */
INSERT INTO dbo.users (user_id, full_name, email, phone_number, role, department, account_status)
VALUES
('U001', N'Nguyen Minh An', 'an.nguyen@hcmus.edu.vn', '0901000001', N'student', N'Computer Science', 'active'),
('U002', N'Tran Bao Chau', 'chau.tran@hcmus.edu.vn', '0901000002', N'student', N'Computer Science', 'active'),
('U003', N'Le Quang Minh', 'minh.le@hcmus.edu.vn', '0901000003', N'lecturer', N'Computer Science', 'active'),
('U004', N'Pham Hoang Long', 'long.pham@hcmus.edu.vn', '0901000004', N'teaching assistant', N'Computer Science', 'active'),
('U005', N'Vo Thanh Dat', 'dat.vo@hcmus.edu.vn', '0901000005', N'department administrator', N'Computer Science', 'active'),
('FS001', N'Dang Gia Huy', 'huy.dang.facility@hcmus.edu.vn', '0902000001', N'facility staff', N'Facility Office', 'active'),
('FS002', N'Nguyen Thi Mai', 'mai.nguyen.facility@hcmus.edu.vn', '0902000002', N'facility staff', N'Facility Office', 'active'),
('FM001', N'Truong Thanh Binh', 'binh.truong.manager@hcmus.edu.vn', '0903000001', N'facility manager', N'Facility Office', 'active'),
('FS003', N'Hoang Van Kiet', 'kiet.hoang.facility@hcmus.edu.vn', '0902000003', N'facility staff', N'Facility Office', 'suspended'),
('U006', N'Bui Lan Anh', 'anh.bui@hcmus.edu.vn', '0901000006', N'student', N'Computer Science', 'inactive');
GO

/* ============================================================
   3. Spaces
   Includes available, temporarily closed, and retired spaces.
   ============================================================ */
INSERT INTO dbo.spaces (space_code, space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy)
VALUES
('A101', N'Classroom A101', N'classroom', N'Building A', '1', '101', 60, N'available', N'Used for lectures, seminars, and examinations.'),
('B201', N'Computer Laboratory B201', N'computer laboratory', N'Building B', '2', '201', 40, N'available', N'Food and drinks are not allowed. Computers must be shut down after use.'),
('C301', N'Auditorium C301', N'auditorium', N'Building C', '3', '301', 200, N'available', N'Used for large seminars, workshops, and academic events.'),
('D101', N'Meeting Room D101', N'meeting room', N'Building D', '1', '101', 20, N'available', N'Used for meetings and project discussions.'),
('E101', N'Student Workspace E101', N'student workspace', N'Building E', '1', '101', 30, N'available', N'Used for group study and student projects.'),
('F101', N'Temporarily Closed Classroom F101', N'classroom', N'Building F', '1', '101', 50, N'temporarily closed', N'Closed for renovation.'),
('G001', N'Retired Laboratory G001', N'project laboratory', N'Building G', '0', '001', 25, N'retired', N'No longer available for booking.');
GO

/* ============================================================
   4. Facilities
   Each space has its own list of available facilities.
   ============================================================ */
INSERT INTO dbo.facilities (space_code, facility_name, description, quantity, condition_note)
VALUES
('A101', N'Projector', N'Ceiling-mounted projector', 1, N'Working normally'),
('A101', N'Whiteboard', N'Large front whiteboard', 2, N'Good condition'),
('A101', N'Microphone', N'Wireless microphone set', 1, N'Battery should be checked before class'),
('B201', N'Computer', N'Desktop computers for lab sessions', 40, N'All computers installed with programming tools'),
('B201', N'Projector', N'Projector for instructor demonstrations', 1, N'Working normally'),
('B201', N'Air conditioner', N'Wall-mounted air conditioners', 2, N'One unit requires periodic cleaning'),
('C301', N'Livestreaming equipment', N'Camera and audio system for events', 1, N'Working normally'),
('C301', N'Microphone', N'Handheld wireless microphones', 4, N'Working normally'),
('D101', N'TV screen', N'Large screen for presentations', 1, N'Working normally'),
('D101', N'Whiteboard', N'Meeting whiteboard', 1, N'Good condition'),
('E101', N'Whiteboard', N'Mobile whiteboard', 1, N'Good condition'),
('E101', N'Air conditioner', N'Air conditioner for student workspace', 1, N'Working normally');
GO

/* ============================================================
   5. Booking requests
   Initial rows are inserted as pending/cancelled, then approvals and usage sessions
   below will move some bookings to approved, rejected, checked in, completed, and no-show.
   ============================================================ */
SET IDENTITY_INSERT dbo.booking_requests ON;

INSERT INTO dbo.booking_requests
    (booking_id, requester_id, space_code, requested_start_time, requested_end_time, purpose_of_use, expected_participants, booking_status, created_at)
VALUES
(1, 'U003', 'A101', '2026-08-05T08:00:00', '2026-08-05T10:00:00', N'lecture', 50, N'pending', '2026-07-20T08:30:00'),
(2, 'U004', 'A101', '2026-08-05T10:00:00', '2026-08-05T12:00:00', N'seminar', 30, N'pending', '2026-07-20T09:00:00'),
(3, 'U001', 'B201', '2026-08-06T14:00:00', '2026-08-06T16:00:00', N'student activity', 35, N'pending', '2026-07-21T10:00:00'),
(4, 'U002', 'D101', '2026-08-04T09:00:00', '2026-08-04T10:00:00', N'meeting', 10, N'pending', '2026-07-21T11:00:00'),
(5, 'U003', 'C301', '2026-08-01T13:00:00', '2026-08-01T15:00:00', N'workshop', 120, N'pending', '2026-07-22T08:00:00'),
(6, 'U005', 'E101', '2026-08-07T15:00:00', '2026-08-07T16:00:00', N'administrative event', 12, N'cancelled', '2026-07-22T09:00:00'),
(7, 'U002', 'A101', '2026-08-08T08:00:00', '2026-08-08T10:00:00', N'examination', 45, N'pending', '2026-07-23T08:00:00'),
(8, 'U003', 'C301', '2026-08-10T08:00:00', '2026-08-10T11:00:00', N'examination', 150, N'pending', '2026-07-23T09:00:00'),
(9, 'U001', 'D101', '2026-08-11T14:00:00', '2026-08-11T15:00:00', N'meeting', 8, N'pending', '2026-07-24T08:00:00');

SET IDENTITY_INSERT dbo.booking_requests OFF;
GO

/* ============================================================
   6. Approvals
   The approval trigger automatically synchronizes booking_status.
   Expected statuses after this section:
   - Booking 1, 2, 4, 5, 8, 9 -> approved
   - Booking 3 -> rejected
   - Booking 6 -> cancelled
   - Booking 7 -> pending
   ============================================================ */
INSERT INTO dbo.approvals (booking_id, staff_id, decision, decision_time, decision_note, rejection_reason)
VALUES
(1, 'FS001', N'approved', '2026-07-20T10:00:00', N'Room is available and capacity is suitable.', NULL),
(2, 'FM001', N'approved', '2026-07-20T10:15:00', N'No conflict with the previous booking.', NULL),
(3, 'FS001', N'rejected', '2026-07-21T11:00:00', N'Request rejected because the activity requires special setup not available in this lab.', N'Special setup is not available.'),
(4, 'FS002', N'approved', '2026-07-21T12:00:00', N'Meeting room is available.', NULL),
(5, 'FM001', N'approved', '2026-07-22T09:00:00', N'Auditorium is suitable for the workshop.', NULL),
(8, 'FS001', N'approved', '2026-07-23T10:00:00', N'Auditorium is available for the examination.', NULL),
(9, 'FS002', N'approved', '2026-07-24T09:00:00', N'Meeting room is available.', NULL);
GO

/* ============================================================
   7. Usage sessions
   Demonstrates check-in, active usage, and completed usage.
   The usage trigger automatically synchronizes booking_status.
   ============================================================ */
INSERT INTO dbo.usage_sessions
    (booking_id, actual_start_time, checked_in_by, initial_condition, actual_end_time, final_condition, usage_notes)
VALUES
(4, '2026-08-04T08:55:00', 'FS001', N'Room is clean. TV screen and whiteboard are ready.', NULL, NULL, N'Group checked in five minutes early.'),
(5, '2026-08-01T13:02:00', 'FS002', N'Auditorium is clean. Livestreaming equipment is ready.', NULL, NULL, N'Workshop started slightly after the requested start time.');
GO

UPDATE dbo.usage_sessions
SET actual_end_time = '2026-08-01T15:05:00',
    final_condition = N'Auditorium is clean. All microphones returned.',
    usage_notes = N'Workshop completed successfully.'
WHERE booking_id = 5;
GO

/* Booking 9 is marked as no-show after approval. */
UPDATE dbo.booking_requests
SET booking_status = N'no-show'
WHERE booking_id = 9;
GO

/* ============================================================
   8. Maintenance records
   Includes assigned, in progress, completed, and cancelled examples.
   The maintenance trigger automatically changes a reported record with assigned staff
   to assigned, and marks active maintenance spaces as under maintenance.
   ============================================================ */
INSERT INTO dbo.maintenance_records
    (space_code, reporter_id, assigned_staff_id, problem_type, problem_description, start_time, completion_time, maintenance_status, result_note)
VALUES
('A101', 'U003', 'FS002', N'broken projector', N'The projector sometimes loses signal during lectures.', '2026-07-25T08:00:00', NULL, N'reported', NULL),
('E101', 'U001', 'FS001', N'network problem', N'Wi-Fi connection is unstable in the student workspace.', '2026-07-25T09:00:00', NULL, N'in progress', NULL),
('C301', 'FS001', 'FM001', N'damaged furniture', N'Two chairs were damaged after a large event.', '2026-07-18T08:00:00', '2026-07-19T16:00:00', N'completed', N'Damaged chairs were replaced.'),
('D101', 'U005', NULL, N'cleaning issue', N'The meeting room needs extra cleaning after an event.', '2026-07-19T08:00:00', '2026-07-19T09:30:00', N'cancelled', N'Request cancelled because the room had already been cleaned.');
GO

/* ============================================================
   9. Optional exceptional-case validation tests
   These tests are intentionally expected to fail. They are wrapped in TRY/CATCH
   so the sample script can continue running while proving the trigger error codes work.
   Each CATCH block prints the actual SQL Server error number returned by the trigger.
   ============================================================ */

-- Test 1: Trigger error 51001 - inactive user cannot submit or hold a booking request.
BEGIN TRY
    INSERT INTO dbo.booking_requests
        (requester_id, space_code, requested_start_time, requested_end_time, purpose_of_use, expected_participants)
    VALUES
        ('U006', 'D101', '2026-08-12T09:00:00', '2026-08-12T10:00:00', N'meeting', 5);

    PRINT 'ERROR: Test 1 failed because no error was thrown.';
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 51001
        PRINT 'PASS - Test 1 caught expected error 51001: ' + ERROR_MESSAGE();
    ELSE
        PRINT 'UNEXPECTED - Test 1 caught error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test 2: Trigger error 51002 - unavailable space cannot be booked.
BEGIN TRY
    INSERT INTO dbo.booking_requests
        (requester_id, space_code, requested_start_time, requested_end_time, purpose_of_use, expected_participants)
    VALUES
        ('U003', 'F101', '2026-08-12T13:00:00', '2026-08-12T15:00:00', N'lecture', 30);

    PRINT 'ERROR: Test 2 failed because no error was thrown.';
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 51002
        PRINT 'PASS - Test 2 caught expected error 51002: ' + ERROR_MESSAGE();
    ELSE
        PRINT 'UNEXPECTED - Test 2 caught error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test 3: Trigger error 51003 - expected participants cannot exceed space capacity.
BEGIN TRY
    INSERT INTO dbo.booking_requests
        (requester_id, space_code, requested_start_time, requested_end_time, purpose_of_use, expected_participants)
    VALUES
        ('U003', 'D101', '2026-08-12T10:00:00', '2026-08-12T11:00:00', N'meeting', 50);

    PRINT 'ERROR: Test 3 failed because no error was thrown.';
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 51003
        PRINT 'PASS - Test 3 caught expected error 51003: ' + ERROR_MESSAGE();
    ELSE
        PRINT 'UNEXPECTED - Test 3 caught error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test 4: Trigger error 51004 - approved bookings for the same space cannot overlap.
DECLARE @ConflictBookingId INT;
BEGIN TRY
    INSERT INTO dbo.booking_requests
        (requester_id, space_code, requested_start_time, requested_end_time, purpose_of_use, expected_participants)
    VALUES
        ('U001', 'C301', '2026-08-10T09:00:00', '2026-08-10T10:00:00', N'seminar', 80);

    SET @ConflictBookingId = SCOPE_IDENTITY();

    INSERT INTO dbo.approvals
        (booking_id, staff_id, decision, decision_time, decision_note, rejection_reason)
    VALUES
        (@ConflictBookingId, 'FS001', N'approved', '2026-07-26T11:00:00', N'This should fail because it overlaps with booking 8.', NULL);

    PRINT 'ERROR: Test 4 failed because no error was thrown.';
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 51004
        PRINT 'PASS - Test 4 caught expected error 51004: ' + ERROR_MESSAGE();
    ELSE
        PRINT 'UNEXPECTED - Test 4 caught error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();

    IF @ConflictBookingId IS NOT NULL
    BEGIN
        DELETE FROM dbo.booking_requests
        WHERE booking_id = @ConflictBookingId;
    END;
END CATCH;
GO

-- Test 5: Trigger error 51005 - approver must be active facility staff or facility manager.
BEGIN TRY
    INSERT INTO dbo.approvals
        (booking_id, staff_id, decision, decision_time, decision_note, rejection_reason)
    VALUES
        (7, 'FS003', N'approved', '2026-07-26T10:00:00', N'This should fail because the approver is suspended.', NULL);

    PRINT 'ERROR: Test 5 failed because no error was thrown.';
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 51005
        PRINT 'PASS - Test 5 caught expected error 51005: ' + ERROR_MESSAGE();
    ELSE
        PRINT 'UNEXPECTED - Test 5 caught error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test 6: Trigger error 51006 - usage session can be created only for an approved booking.
BEGIN TRY
    INSERT INTO dbo.usage_sessions
        (booking_id, actual_start_time, checked_in_by, initial_condition)
    VALUES
        (7, '2026-08-08T07:55:00', 'FS001', N'This should fail because booking 7 is still pending.');

    PRINT 'ERROR: Test 6 failed because no error was thrown.';
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 51006
        PRINT 'PASS - Test 6 caught expected error 51006: ' + ERROR_MESSAGE();
    ELSE
        PRINT 'UNEXPECTED - Test 6 caught error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test 7: Trigger error 51007 - assigned maintenance staff must be active facility staff or facility manager.
BEGIN TRY
    INSERT INTO dbo.maintenance_records
        (space_code, reporter_id, assigned_staff_id, problem_type, problem_description, maintenance_status)
    VALUES
        ('D101', 'U005', 'FS003', N'other', N'This should fail because the assigned staff is suspended.', N'reported');

    PRINT 'ERROR: Test 7 failed because no error was thrown.';
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 51007
        PRINT 'PASS - Test 7 caught expected error 51007: ' + ERROR_MESSAGE();
    ELSE
        PRINT 'UNEXPECTED - Test 7 caught error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test 8: Trigger error 51008 - checked_in_by must be active facility staff or facility manager.
BEGIN TRY
    INSERT INTO dbo.usage_sessions
        (booking_id, actual_start_time, checked_in_by, initial_condition)
    VALUES
        (8, '2026-08-10T07:55:00', 'U001', N'This should fail because students cannot check in bookings.');

    PRINT 'ERROR: Test 8 failed because no error was thrown.';
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 51008
        PRINT 'PASS - Test 8 caught expected error 51008: ' + ERROR_MESSAGE();
    ELSE
        PRINT 'UNEXPECTED - Test 8 caught error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test 9: Trigger error 51009 - core booking information cannot be changed after approval/check-in/completion.
BEGIN TRY
    UPDATE dbo.booking_requests
    SET requested_start_time = '2026-08-05T08:30:00'
    WHERE booking_id = 1;

    PRINT 'ERROR: Test 9 failed because no error was thrown.';
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 51009
        PRINT 'PASS - Test 9 caught expected error 51009: ' + ERROR_MESSAGE();
    ELSE
        PRINT 'UNEXPECTED - Test 9 caught error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO

/* ============================================================
   10. Quick verification queries
   ============================================================ */
SELECT booking_id, requester_id, space_code, requested_start_time, requested_end_time, booking_status
FROM dbo.booking_requests
ORDER BY booking_id;

SELECT space_code, space_name, current_status
FROM dbo.spaces
ORDER BY space_code;

SELECT maintenance_id, space_code, assigned_staff_id, maintenance_status, problem_type
FROM dbo.maintenance_records
ORDER BY maintenance_id;
GO
