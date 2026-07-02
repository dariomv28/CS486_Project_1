-- Task 5: Database Implementation - Campus Space Management System
-- DBMS target: Microsoft SQL Server
CREATE DATABASE CampusSpaceManagement;
GO
USE CampusSpaceManagement;
GO
IF OBJECT_ID('dbo.trg_usage_sessions_validate_and_sync', 'TR') IS NOT NULL DROP TRIGGER dbo.trg_usage_sessions_validate_and_sync;
IF OBJECT_ID('dbo.trg_approvals_validate_and_sync', 'TR') IS NOT NULL DROP TRIGGER dbo.trg_approvals_validate_and_sync;
IF OBJECT_ID('dbo.trg_booking_requests_validate', 'TR') IS NOT NULL DROP TRIGGER dbo.trg_booking_requests_validate;
IF OBJECT_ID('dbo.trg_maintenance_records_validate_and_sync', 'TR') IS NOT NULL DROP TRIGGER dbo.trg_maintenance_records_validate_and_sync;

IF OBJECT_ID('dbo.maintenance_records', 'U') IS NOT NULL DROP TABLE dbo.maintenance_records;
IF OBJECT_ID('dbo.usage_sessions', 'U') IS NOT NULL DROP TABLE dbo.usage_sessions;
IF OBJECT_ID('dbo.approvals', 'U') IS NOT NULL DROP TABLE dbo.approvals;
IF OBJECT_ID('dbo.booking_requests', 'U') IS NOT NULL DROP TABLE dbo.booking_requests;
IF OBJECT_ID('dbo.facilities', 'U') IS NOT NULL DROP TABLE dbo.facilities;
IF OBJECT_ID('dbo.spaces', 'U') IS NOT NULL DROP TABLE dbo.spaces;
IF OBJECT_ID('dbo.users', 'U') IS NOT NULL DROP TABLE dbo.users;
GO

CREATE TABLE dbo.users (
    user_id VARCHAR(20) NOT NULL,
    full_name NVARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    phone_number VARCHAR(30) NULL,
    role NVARCHAR(35) NOT NULL,
    department NVARCHAR(100) NOT NULL,
    account_status VARCHAR(20) NOT NULL CONSTRAINT df_users_account_status DEFAULT ('active'),
    CONSTRAINT pk_users PRIMARY KEY (user_id),
    CONSTRAINT uq_users_email UNIQUE (email),
    CONSTRAINT chk_users_role CHECK (role IN (
        N'student',
        N'lecturer',
        N'teaching assistant',
        N'facility staff',
        N'department administrator',
        N'facility manager'
    )),
    CONSTRAINT chk_users_account_status CHECK (account_status IN ('active', 'inactive', 'suspended')),
    CONSTRAINT chk_users_email_format CHECK (email LIKE '%@%')
);
GO

CREATE TABLE dbo.spaces (
    space_code VARCHAR(20) NOT NULL,
    space_name NVARCHAR(100) NOT NULL,
    space_type NVARCHAR(40) NOT NULL,
    building NVARCHAR(100) NOT NULL,
    floor VARCHAR(20) NOT NULL,
    room_number VARCHAR(20) NOT NULL,
    capacity INT NOT NULL,
    current_status NVARCHAR(30) NOT NULL CONSTRAINT df_spaces_current_status DEFAULT (N'available'),
    usage_policy NVARCHAR(MAX) NULL,
    CONSTRAINT pk_spaces PRIMARY KEY (space_code),
    CONSTRAINT uq_spaces_location UNIQUE (building, floor, room_number),
    CONSTRAINT chk_spaces_type CHECK (space_type IN (
        N'auditorium',
        N'classroom',
        N'computer laboratory',
        N'project laboratory',
        N'meeting room',
        N'student workspace'
    )),
    CONSTRAINT chk_spaces_capacity CHECK (capacity > 0),
    CONSTRAINT chk_spaces_status CHECK (current_status IN (
        N'available',
        N'in use',
        N'under maintenance',
        N'temporarily closed',
        N'retired'
    ))
);
GO

CREATE TABLE dbo.facilities (
    facility_id INT IDENTITY(1,1) NOT NULL,
    space_code VARCHAR(20) NOT NULL,
    facility_name NVARCHAR(100) NOT NULL,
    description NVARCHAR(MAX) NULL,
    quantity INT NOT NULL CONSTRAINT df_facilities_quantity DEFAULT (1),
    condition_note NVARCHAR(MAX) NULL,
    CONSTRAINT pk_facilities PRIMARY KEY (facility_id),
    CONSTRAINT fk_facilities_space FOREIGN KEY (space_code)
        REFERENCES dbo.spaces(space_code)
        ON DELETE CASCADE,
    CONSTRAINT chk_facilities_quantity CHECK (quantity > 0)
);
GO

CREATE TABLE dbo.booking_requests (
    booking_id INT IDENTITY(1,1) NOT NULL,
    requester_id VARCHAR(20) NOT NULL,
    space_code VARCHAR(20) NOT NULL,
    requested_start_time DATETIME2(0) NOT NULL,
    requested_end_time DATETIME2(0) NOT NULL,
    purpose_of_use NVARCHAR(40) NOT NULL,
    expected_participants INT NOT NULL,
    booking_status NVARCHAR(20) NOT NULL CONSTRAINT df_booking_requests_status DEFAULT (N'pending'),
    created_at DATETIME2(0) NOT NULL CONSTRAINT df_booking_requests_created_at DEFAULT (SYSDATETIME()),
    CONSTRAINT pk_booking_requests PRIMARY KEY (booking_id),
    CONSTRAINT fk_booking_requests_requester FOREIGN KEY (requester_id)
        REFERENCES dbo.users(user_id),
    CONSTRAINT fk_booking_requests_space FOREIGN KEY (space_code)
        REFERENCES dbo.spaces(space_code),
    CONSTRAINT chk_booking_requests_time CHECK (requested_end_time > requested_start_time),
    CONSTRAINT chk_booking_requests_participants CHECK (expected_participants > 0),
    CONSTRAINT chk_booking_requests_purpose CHECK (purpose_of_use IN (
        N'lecture',
        N'examination',
        N'seminar',
        N'workshop',
        N'meeting',
        N'student activity',
        N'administrative event'
    )),
    CONSTRAINT chk_booking_requests_status CHECK (booking_status IN (
        N'pending',
        N'approved',
        N'rejected',
        N'cancelled',
        N'checked in',
        N'completed',
        N'no-show'
    ))
);
GO

CREATE TABLE dbo.approvals (
    booking_id INT NOT NULL,
    staff_id VARCHAR(20) NOT NULL,
    decision NVARCHAR(20) NOT NULL,
    decision_time DATETIME2(0) NOT NULL CONSTRAINT df_approvals_decision_time DEFAULT (SYSDATETIME()),
    decision_note NVARCHAR(MAX) NULL,
    rejection_reason NVARCHAR(MAX) NULL,
    CONSTRAINT pk_approvals PRIMARY KEY (booking_id),
    CONSTRAINT fk_approvals_booking FOREIGN KEY (booking_id)
        REFERENCES dbo.booking_requests(booking_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_approvals_staff FOREIGN KEY (staff_id)
        REFERENCES dbo.users(user_id),
    CONSTRAINT chk_approvals_decision CHECK (decision IN (N'approved', N'rejected')),
    CONSTRAINT chk_approvals_rejection_reason CHECK (decision <> N'rejected' OR rejection_reason IS NOT NULL)
);
GO

CREATE TABLE dbo.usage_sessions (
    booking_id INT NOT NULL,
    actual_start_time DATETIME2(0) NOT NULL CONSTRAINT df_usage_sessions_actual_start_time DEFAULT (SYSDATETIME()),
    checked_in_by VARCHAR(20) NOT NULL,
    initial_condition NVARCHAR(MAX) NOT NULL,
    actual_end_time DATETIME2(0) NULL,
    final_condition NVARCHAR(MAX) NULL,
    usage_notes NVARCHAR(MAX) NULL,
    CONSTRAINT pk_usage_sessions PRIMARY KEY (booking_id),
    CONSTRAINT fk_usage_sessions_booking FOREIGN KEY (booking_id)
        REFERENCES dbo.booking_requests(booking_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_usage_sessions_checked_in_by FOREIGN KEY (checked_in_by)
        REFERENCES dbo.users(user_id),
    CONSTRAINT chk_usage_sessions_actual_time CHECK (actual_end_time IS NULL OR actual_end_time > actual_start_time),
    CONSTRAINT chk_usage_sessions_completion_condition CHECK (actual_end_time IS NULL OR final_condition IS NOT NULL)
);
GO

CREATE TABLE dbo.maintenance_records (
    maintenance_id INT IDENTITY(1,1) NOT NULL,
    space_code VARCHAR(20) NOT NULL,
    reporter_id VARCHAR(20) NOT NULL,
    assigned_staff_id VARCHAR(20) NULL,
    problem_type NVARCHAR(50) NOT NULL,
    problem_description NVARCHAR(MAX) NOT NULL,
    start_time DATETIME2(0) NOT NULL CONSTRAINT df_maintenance_records_start_time DEFAULT (SYSDATETIME()),
    completion_time DATETIME2(0) NULL,
    maintenance_status NVARCHAR(20) NOT NULL CONSTRAINT df_maintenance_records_status DEFAULT (N'reported'),
    result_note NVARCHAR(MAX) NULL,
    CONSTRAINT pk_maintenance_records PRIMARY KEY (maintenance_id),
    CONSTRAINT fk_maintenance_records_space FOREIGN KEY (space_code)
        REFERENCES dbo.spaces(space_code),
    CONSTRAINT fk_maintenance_records_reporter FOREIGN KEY (reporter_id)
        REFERENCES dbo.users(user_id),
    CONSTRAINT fk_maintenance_records_assigned_staff FOREIGN KEY (assigned_staff_id)
        REFERENCES dbo.users(user_id),
    CONSTRAINT chk_maintenance_records_problem_type CHECK (problem_type IN (
        N'broken projector',
        N'air-conditioning failure',
        N'damaged furniture',
        N'cleaning issue',
        N'network problem',
        N'other'
    )),
    CONSTRAINT chk_maintenance_records_status CHECK (maintenance_status IN (
        N'reported',
        N'assigned',
        N'in progress',
        N'completed',
        N'cancelled'
    )),
    CONSTRAINT chk_maintenance_records_completion_time CHECK (completion_time IS NULL OR completion_time > start_time),
    CONSTRAINT chk_maintenance_records_completed_details CHECK (
        maintenance_status <> N'completed'
        OR (completion_time IS NOT NULL AND result_note IS NOT NULL)
    )
);
GO

CREATE INDEX idx_facilities_space
    ON dbo.facilities (space_code);

CREATE INDEX idx_booking_requests_space_time
    ON dbo.booking_requests (space_code, requested_start_time, requested_end_time);

CREATE INDEX idx_booking_requests_status
    ON dbo.booking_requests (booking_status);

CREATE INDEX idx_maintenance_records_space_status
    ON dbo.maintenance_records (space_code, maintenance_status);

CREATE INDEX idx_maintenance_records_assigned_staff
    ON dbo.maintenance_records (assigned_staff_id);
GO

CREATE TRIGGER dbo.trg_booking_requests_validate
ON dbo.booking_requests
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted AS i
        JOIN dbo.users AS u ON u.user_id = i.requester_id
        WHERE u.account_status <> 'active'
    )
    BEGIN
        THROW 51001, 'Only active users can submit or hold booking requests.', 1;
    END;

    IF EXISTS (
        SELECT 1
        FROM inserted AS i
        JOIN dbo.spaces AS s ON s.space_code = i.space_code
        WHERE i.booking_status IN (N'pending', N'approved', N'checked in')
          AND s.current_status IN (N'under maintenance', N'temporarily closed', N'retired')
    )
    BEGIN
        THROW 51002, 'A space under maintenance, temporarily closed, or retired cannot be booked.', 1;
    END;

    IF EXISTS (
        SELECT 1
        FROM inserted AS i
        JOIN dbo.spaces AS s ON s.space_code = i.space_code
        WHERE i.expected_participants > s.capacity
    )
    BEGIN
        THROW 51003, 'Expected participants cannot exceed the selected space capacity.', 1;
    END;

    IF EXISTS (
        SELECT 1
        FROM inserted AS i
        JOIN dbo.booking_requests AS existing
            ON existing.space_code = i.space_code
           AND existing.booking_id <> i.booking_id
           AND existing.booking_status IN (N'approved', N'checked in')
           AND i.requested_start_time < existing.requested_end_time
           AND i.requested_end_time > existing.requested_start_time
        WHERE i.booking_status IN (N'approved', N'checked in')
    )
    BEGIN
        THROW 51004, 'Approved or checked-in bookings for the same space cannot overlap.', 1;
    END;
END;
GO

CREATE TRIGGER dbo.trg_approvals_validate_and_sync
ON dbo.approvals
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted AS i
        JOIN dbo.users AS u ON u.user_id = i.staff_id
        WHERE u.role NOT IN (N'facility staff', N'facility manager')
    )
    BEGIN
        THROW 51005, 'Only facility staff or facility managers can approve or reject booking requests.', 1;
    END;

    WITH latest_decision AS (
        SELECT
            i.booking_id,
            i.decision,
            ROW_NUMBER() OVER (
                PARTITION BY i.booking_id
                ORDER BY i.decision_time DESC, i.booking_id DESC
            ) AS decision_rank
        FROM inserted AS i
    )
    UPDATE br
    SET booking_status = ld.decision
    FROM dbo.booking_requests AS br
    JOIN latest_decision AS ld ON ld.booking_id = br.booking_id
    WHERE ld.decision_rank = 1;
END;
GO

CREATE TRIGGER dbo.trg_usage_sessions_validate_and_sync
ON dbo.usage_sessions
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted AS i
        LEFT JOIN deleted AS d ON d.booking_id = i.booking_id
        JOIN dbo.booking_requests AS br ON br.booking_id = i.booking_id
        WHERE d.booking_id IS NULL
          AND br.booking_status <> N'approved'
    )
    BEGIN
        THROW 51006, 'Usage sessions can be created only for approved bookings.', 1;
    END;

    UPDATE br
    SET booking_status = CASE
        WHEN i.actual_end_time IS NULL THEN N'checked in'
        ELSE N'completed'
    END
    FROM dbo.booking_requests AS br
    JOIN inserted AS i ON i.booking_id = br.booking_id;
END;
GO

CREATE TRIGGER dbo.trg_maintenance_records_validate_and_sync
ON dbo.maintenance_records
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted AS i
        JOIN dbo.users AS u ON u.user_id = i.assigned_staff_id
        WHERE i.assigned_staff_id IS NOT NULL
          AND u.role NOT IN (N'facility staff', N'facility manager')
    )
    BEGIN
        THROW 51007, 'Maintenance records can be assigned only to facility staff or facility managers.', 1;
    END;

    UPDATE mr
    SET maintenance_status = N'assigned'
    FROM dbo.maintenance_records AS mr
    JOIN inserted AS i ON i.maintenance_id = mr.maintenance_id
    WHERE i.assigned_staff_id IS NOT NULL
      AND i.maintenance_status = N'reported';

    UPDATE s
    SET current_status = N'under maintenance'
    FROM dbo.spaces AS s
    JOIN inserted AS i ON i.space_code = s.space_code
    WHERE i.maintenance_status IN (N'reported', N'assigned', N'in progress')
      AND s.current_status NOT IN (N'retired', N'temporarily closed');
END;
GO
