-- Task 7: Query Design - Campus Space Management System
-- DBMS target: Microsoft SQL Server
-- Run after outputs/05-db-definition-G10.sql and outputs/06-sample-data-G10.sql

USE CampusSpaceManagement;
GO

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
DECLARE @requested_start_time DATETIME2(0) = '2026-08-05T08:00:00';
DECLARE @requested_end_time DATETIME2(0) = '2026-08-05T12:00:00';
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
DECLARE @maintenance_as_of_date DATETIME2(0) = '2026-08-12T00:00:00';

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
    DATEDIFF(DAY, mr.start_time, @maintenance_as_of_date) AS days_open,
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

-- Query 8
-- Business question: How many bookings exist by day, status, and purpose?
-- Target user(s): Facility managers, department administrators.
-- Utility: Gives a daily booking demand summary for workload planning and activity-type analysis.
SELECT
    CAST(br.requested_start_time AS DATE) AS booking_date,
    br.booking_status,
    br.purpose_of_use,
    COUNT(*) AS booking_count,
    SUM(br.expected_participants) AS expected_participant_total,
    SUM(DATEDIFF(MINUTE, br.requested_start_time, br.requested_end_time)) / 60.0 AS reserved_hours
FROM dbo.booking_requests AS br
GROUP BY
    CAST(br.requested_start_time AS DATE),
    br.booking_status,
    br.purpose_of_use
ORDER BY booking_date, br.booking_status, br.purpose_of_use;
GO

-- Query 9
-- Business question: Which requester roles have the most cancelled, rejected, or no-show bookings?
-- Target user(s): Facility managers, department administrators.
-- Utility: Helps identify patterns that may require policy reminders, better communication, or approval workflow changes.
SELECT
    u.role AS requester_role,
    COUNT(*) AS total_booking_count,
    SUM(CASE WHEN br.booking_status = N'cancelled' THEN 1 ELSE 0 END) AS cancelled_count,
    SUM(CASE WHEN br.booking_status = N'rejected' THEN 1 ELSE 0 END) AS rejected_count,
    SUM(CASE WHEN br.booking_status = N'no-show' THEN 1 ELSE 0 END) AS no_show_count,
    CAST(
        SUM(CASE WHEN br.booking_status IN (N'cancelled', N'rejected', N'no-show') THEN 1 ELSE 0 END) * 100.0 / COUNT(*)
        AS DECIMAL(10, 2)
    ) AS exception_rate_percent
FROM dbo.booking_requests AS br
JOIN dbo.users AS u ON u.user_id = br.requester_id
GROUP BY u.role
ORDER BY exception_rate_percent DESC, total_booking_count DESC;
GO

-- Query 10
-- Business question: Which approved bookings are past their scheduled end time but still have no usage session?
-- Target user(s): Facility staff, facility managers.
-- Utility: Identifies approved reservations that may need no-show review or manual follow-up.
DECLARE @no_show_review_time DATETIME2(0) = '2026-08-12T00:00:00';

SELECT
    br.booking_id,
    br.requested_start_time,
    br.requested_end_time,
    s.space_code,
    s.space_name,
    requester.full_name AS requester_name,
    requester.email AS requester_email,
    DATEDIFF(HOUR, br.requested_end_time, @no_show_review_time) AS hours_since_scheduled_end
FROM dbo.booking_requests AS br
JOIN dbo.spaces AS s ON s.space_code = br.space_code
JOIN dbo.users AS requester ON requester.user_id = br.requester_id
LEFT JOIN dbo.usage_sessions AS us ON us.booking_id = br.booking_id
WHERE br.booking_status = N'approved'
  AND us.booking_id IS NULL
  AND br.requested_end_time < @no_show_review_time
ORDER BY br.requested_end_time;
GO

-- Query 11
-- Business question: How long did resolved maintenance cases take to complete or cancel?
-- Target user(s): Facility managers, facility staff.
-- Utility: Measures maintenance turnaround time by problem type and staff member for service quality review.
SELECT
    mr.maintenance_id,
    mr.problem_type,
    mr.maintenance_status,
    s.space_code,
    s.space_name,
    assignee.full_name AS assigned_staff_name,
    mr.start_time,
    mr.completion_time,
    DATEDIFF(HOUR, mr.start_time, mr.completion_time) AS resolution_hours,
    mr.result_note
FROM dbo.maintenance_records AS mr
JOIN dbo.spaces AS s ON s.space_code = mr.space_code
LEFT JOIN dbo.users AS assignee ON assignee.user_id = mr.assigned_staff_id
WHERE mr.maintenance_status IN (N'completed', N'cancelled')
  AND mr.completion_time IS NOT NULL
ORDER BY resolution_hours DESC, mr.maintenance_id;
GO

-- Query 12
-- Business question: Which spaces are missing common facilities needed for teaching or events?
-- Target user(s): Facility managers, facility staff.
-- Utility: Highlights facility gaps so staff can plan equipment purchases, movement, or setup before bookings.
WITH required_facilities AS (
    SELECT N'Projector' AS required_facility_name
    UNION ALL SELECT N'Whiteboard'
    UNION ALL SELECT N'Air conditioner'
),
active_spaces AS (
    SELECT
        s.space_code,
        s.space_name,
        s.space_type,
        s.current_status
    FROM dbo.spaces AS s
    WHERE s.current_status <> N'retired'
)
SELECT
    s.space_code,
    s.space_name,
    s.space_type,
    s.current_status,
    rf.required_facility_name AS missing_facility
FROM active_spaces AS s
CROSS JOIN required_facilities AS rf
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.facilities AS f
    WHERE f.space_code = s.space_code
      AND LOWER(f.facility_name) = LOWER(rf.required_facility_name)
)
ORDER BY s.space_code, rf.required_facility_name;
GO

-- Query 13
-- Business question: How much approval work has each facility staff member or manager handled?
-- Target user(s): Facility managers.
-- Utility: Summarizes approval workload, decision mix, and average response time from request creation to decision.
SELECT
    approver.user_id AS staff_id,
    approver.full_name AS staff_name,
    approver.role,
    COUNT(*) AS decision_count,
    SUM(CASE WHEN ap.decision = N'approved' THEN 1 ELSE 0 END) AS approved_count,
    SUM(CASE WHEN ap.decision = N'rejected' THEN 1 ELSE 0 END) AS rejected_count,
    CAST(AVG(DATEDIFF(MINUTE, br.created_at, ap.decision_time) / 60.0) AS DECIMAL(10, 2)) AS average_response_hours
FROM dbo.approvals AS ap
JOIN dbo.booking_requests AS br ON br.booking_id = ap.booking_id
JOIN dbo.users AS approver ON approver.user_id = ap.staff_id
GROUP BY
    approver.user_id,
    approver.full_name,
    approver.role
ORDER BY decision_count DESC, average_response_hours;
GO

-- Query 14
-- Business question: Which active maintenance records may affect pending or approved future bookings in the same space?
-- Target user(s): Facility staff, facility managers, department administrators.
-- Utility: Reveals bookings that may need rescheduling, cancellation, or direct communication because their space has unresolved maintenance.
SELECT
    mr.maintenance_id,
    mr.maintenance_status,
    mr.problem_type,
    mr.start_time AS maintenance_start_time,
    br.booking_id,
    br.booking_status,
    br.requested_start_time,
    br.requested_end_time,
    s.space_code,
    s.space_name,
    requester.full_name AS requester_name
FROM dbo.maintenance_records AS mr
JOIN dbo.spaces AS s ON s.space_code = mr.space_code
JOIN dbo.booking_requests AS br ON br.space_code = mr.space_code
JOIN dbo.users AS requester ON requester.user_id = br.requester_id
WHERE mr.maintenance_status IN (N'reported', N'assigned', N'in progress')
  AND br.booking_status IN (N'pending', N'approved')
  AND br.requested_end_time >= mr.start_time
ORDER BY br.requested_start_time, mr.maintenance_id;
GO

-- Query 15
-- Business question: What is utilization by month, space type, and purpose of use?
-- Target user(s): Facility managers, department administrators.
-- Utility: Supports strategic capacity planning by showing where confirmed demand comes from across space categories and activity types.
SELECT
    CONVERT(CHAR(7), br.requested_start_time, 120) AS booking_month,
    s.space_type,
    br.purpose_of_use,
    COUNT(*) AS confirmed_booking_count,
    SUM(DATEDIFF(MINUTE, br.requested_start_time, br.requested_end_time)) / 60.0 AS reserved_hours,
    SUM(br.expected_participants) AS expected_participants,
    CAST(AVG(CAST(br.expected_participants AS DECIMAL(10, 2)) / s.capacity * 100.0) AS DECIMAL(10, 2)) AS average_capacity_use_percent
FROM dbo.booking_requests AS br
JOIN dbo.spaces AS s ON s.space_code = br.space_code
WHERE br.booking_status IN (N'approved', N'checked in', N'completed')
GROUP BY
    CONVERT(CHAR(7), br.requested_start_time, 120),
    s.space_type,
    br.purpose_of_use
ORDER BY booking_month, reserved_hours DESC, s.space_type;
GO
