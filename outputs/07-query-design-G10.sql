-- Task 7: Query Design - Campus Space Management System
-- DBMS target: Microsoft SQL Server
-- Run after outputs/05-db-definition-G10.sql and outputs/06-sample-data-G10.sql

-- Query 1
-- Business question: Which booking requests are scheduled or recently processed, and what is their approval and usage status?
-- Target user(s): Facility staff, facility managers, department administrators.
-- Utility: Gives staff a joined operational schedule showing requester, space, booking status, latest decision, and check-in/completion information.
SELECT
    br.booking_id,
    br.booking_status,
    br.requested_start_time,
    br.requested_end_time,
    br.purpose_of_use,
    br.expected_participants,
    s.space_code,
    s.space_name,
    s.space_type,
    u.full_name AS requester_name,
    u.role AS requester_role,
    a.decision AS latest_decision,
    a.decision_time,
    approver.full_name AS approver_name,
    us.actual_start_time,
    us.actual_end_time
FROM dbo.booking_requests AS br
JOIN dbo.users AS u ON u.user_id = br.requester_id
JOIN dbo.spaces AS s ON s.space_code = br.space_code
OUTER APPLY (
    SELECT TOP (1)
        ap.decision,
        ap.decision_time,
        ap.staff_id
    FROM dbo.approvals AS ap
    WHERE ap.booking_id = br.booking_id
    ORDER BY ap.decision_time DESC, ap.booking_id DESC
) AS a
LEFT JOIN dbo.users AS approver ON approver.user_id = a.staff_id
LEFT JOIN dbo.usage_sessions AS us ON us.booking_id = br.booking_id
ORDER BY br.requested_start_time, br.booking_id;
GO

-- Query 2
-- Business question: Which spaces are available for a requested time period and have enough capacity?
-- Target user(s): Students, lecturers, teaching assistants, department administrators.
-- Utility: Helps requesters and staff identify bookable spaces before submitting or approving a reservation.
DECLARE @requested_start_time DATETIME2(0) = '2026-07-01T08:00:00';
DECLARE @requested_end_time DATETIME2(0) = '2026-07-01T12:00:00';
DECLARE @minimum_capacity INT = 30;

SELECT
    s.space_code,
    s.space_name,
    s.space_type,
    s.building,
    s.floor,
    s.room_number,
    s.capacity,
    s.current_status,
    STRING_AGG(CONCAT(f.facility_name, N' (', f.quantity, N')'), N', ') AS facilities
FROM dbo.spaces AS s
LEFT JOIN dbo.facilities AS f ON f.space_code = s.space_code
WHERE s.current_status = N'available'
  AND s.capacity >= @minimum_capacity
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.booking_requests AS br
      WHERE br.space_code = s.space_code
        AND br.booking_status IN (N'approved', N'checked in')
        AND dbo.fn_time_ranges_overlap(
            @requested_start_time,
            @requested_end_time,
            br.requested_start_time,
            br.requested_end_time
        ) = 1
  )
GROUP BY
    s.space_code,
    s.space_name,
    s.space_type,
    s.building,
    s.floor,
    s.room_number,
    s.capacity,
    s.current_status
ORDER BY s.capacity DESC, s.space_code;
GO

-- Query 3
-- Business question: Which spaces are used most heavily by approved, checked-in, or completed bookings?
-- Target user(s): Facility managers, department administrators.
-- Utility: Summarizes booking volume, reserved hours, and participant demand to support utilization analysis and room planning.
SELECT
    s.space_code,
    s.space_name,
    s.space_type,
    COUNT(br.booking_id) AS active_or_confirmed_booking_count,
    SUM(DATEDIFF(MINUTE, br.requested_start_time, br.requested_end_time)) / 60.0 AS reserved_hours,
    SUM(br.expected_participants) AS total_expected_participants,
    CAST(AVG(CAST(br.expected_participants AS DECIMAL(10, 2)) / s.capacity * 100.0) AS DECIMAL(10, 2)) AS average_capacity_use_percent
FROM dbo.spaces AS s
JOIN dbo.booking_requests AS br ON br.space_code = s.space_code
WHERE br.booking_status IN (N'approved', N'checked in', N'completed')
GROUP BY
    s.space_code,
    s.space_name,
    s.space_type,
    s.capacity
ORDER BY reserved_hours DESC, active_or_confirmed_booking_count DESC;
GO

-- Query 4
-- Business question: What unresolved maintenance work exists, and who is responsible for it?
-- Target user(s): Facility staff, facility managers.
-- Utility: Shows open maintenance workload, including unassigned issues, so managers can prioritize repair work and staff assignment.
SELECT
    mr.maintenance_id,
    mr.maintenance_status,
    mr.problem_type,
    mr.start_time,
    s.space_code,
    s.space_name,
    s.current_status AS space_status,
    reporter.full_name AS reporter_name,
    COALESCE(assignee.full_name, N'Unassigned') AS assigned_staff_name,
    DATEDIFF(DAY, mr.start_time, SYSUTCDATETIME()) AS days_open,
    mr.problem_description
FROM dbo.maintenance_records AS mr
JOIN dbo.spaces AS s ON s.space_code = mr.space_code
JOIN dbo.users AS reporter ON reporter.user_id = mr.reporter_id
LEFT JOIN dbo.users AS assignee ON assignee.user_id = mr.assigned_staff_id
WHERE mr.maintenance_status IN (N'reported', N'assigned', N'in progress')
ORDER BY
    CASE mr.maintenance_status
        WHEN N'in progress' THEN 1
        WHEN N'assigned' THEN 2
        WHEN N'reported' THEN 3
        ELSE 4
    END,
    mr.start_time;
GO

-- Query 5
-- Business question: Which booking requests still need staff attention or were rejected, and why?
-- Target user(s): Facility staff, facility managers, requesters.
-- Utility: Separates pending requests from rejected requests and displays the latest decision context for follow-up.
WITH latest_approval AS (
    SELECT
        ap.booking_id,
        ap.staff_id,
        ap.decision,
        ap.decision_time,
        ap.decision_note,
        ap.rejection_reason
    FROM dbo.approvals AS ap
)
SELECT
    br.booking_id,
    br.booking_status,
    br.requested_start_time,
    br.requested_end_time,
    br.purpose_of_use,
    u.full_name AS requester_name,
    s.space_name,
    la.decision,
    la.decision_time,
    approver.full_name AS approver_name,
    la.decision_note,
    la.rejection_reason
FROM dbo.booking_requests AS br
JOIN dbo.users AS u ON u.user_id = br.requester_id
JOIN dbo.spaces AS s ON s.space_code = br.space_code
LEFT JOIN latest_approval AS la
    ON la.booking_id = br.booking_id
LEFT JOIN dbo.users AS approver ON approver.user_id = la.staff_id
WHERE br.booking_status IN (N'pending', N'rejected')
ORDER BY br.booking_status, br.requested_start_time;
GO

-- Query 6
-- Business question: Which approved bookings have no usage session recorded yet?
-- Target user(s): Facility staff, facility managers.
-- Utility: Helps staff monitor upcoming approved reservations that still require check-in or may later need no-show review.
SELECT
    br.booking_id,
    br.requested_start_time,
    br.requested_end_time,
    br.booking_status,
    s.space_code,
    s.space_name,
    u.full_name AS requester_name,
    u.email AS requester_email,
    br.expected_participants
FROM dbo.booking_requests AS br
JOIN dbo.spaces AS s ON s.space_code = br.space_code
JOIN dbo.users AS u ON u.user_id = br.requester_id
LEFT JOIN dbo.usage_sessions AS us ON us.booking_id = br.booking_id
WHERE br.booking_status = N'approved'
  AND us.booking_id IS NULL
ORDER BY br.requested_start_time;
GO

-- Query 7
-- Business question: What is the complete facility inventory for each space, including maintenance exposure?
-- Target user(s): Facility managers, facility staff.
-- Utility: Combines space status, facility counts, and unresolved maintenance counts to support room readiness checks.
WITH facility_summary AS (
    SELECT
        f.space_code,
        COUNT(*) AS facility_type_count,
        SUM(f.quantity) AS total_facility_items,
        STRING_AGG(f.facility_name, N', ') AS facility_list
    FROM dbo.facilities AS f
    GROUP BY f.space_code
),
maintenance_summary AS (
    SELECT
        mr.space_code,
        COUNT(*) AS unresolved_maintenance_count
    FROM dbo.maintenance_records AS mr
    WHERE mr.maintenance_status IN (N'reported', N'assigned', N'in progress')
    GROUP BY mr.space_code
)
SELECT
    s.space_code,
    s.space_name,
    s.space_type,
    s.current_status,
    s.capacity,
    COALESCE(fs.facility_type_count, 0) AS facility_type_count,
    COALESCE(fs.total_facility_items, 0) AS total_facility_items,
    fs.facility_list,
    COALESCE(ms.unresolved_maintenance_count, 0) AS unresolved_maintenance_count
FROM dbo.spaces AS s
LEFT JOIN facility_summary AS fs ON fs.space_code = s.space_code
LEFT JOIN maintenance_summary AS ms ON ms.space_code = s.space_code
ORDER BY unresolved_maintenance_count DESC, s.space_code;
GO
