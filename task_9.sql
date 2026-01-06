--USE DATABASE
use kesavan_db
GO

/**

    1. Write a transaction that inserts a new project and multiple associated tasks. 
    Ensure that if any part of the transaction fails, all changes are rolled back.
**/



BEGIN TRY  
    BEGIN TRANSACTION;   

    DECLARE @new_project_id INT;    

    INSERT INTO project (project_name, start_date, end_date, budget, status)  
    VALUES ('E-Commerce Platform Upgrade', '2025-12-01', '2025-12-31', 50000, 'Completed');  

    SET @new_project_id = SCOPE_IDENTITY();  

    INSERT INTO task (task_name, description, start_date, due_date, priority, status, project_id)  
    VALUES 
        ('Requirement Gathering', 'Collect requirements from stakeholders', '2025-08-02', '2025-08-15', 'High', 'Pending', @new_project_id),  
        ('Backend Development', 'Develop backend APIs and database', '2025-08-16', '2025-10-15', 'High', 'Pending', @new_project_id),  
        ('Frontend Development', 'Implement UI and UX designs', '2025-09-01', '2025-11-15', 'Medium', 'Pending', @new_project_id),  
        ('Testing & QA', 'Perform system testing and bug fixes', '2025-11-16', '2025-12-15', 'High', 'Pending', @new_project_id);  

    COMMIT TRANSACTION;
    PRINT 'Transaction committed successfully.';

END TRY
BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'Transaction rolled back due to an error.';

    SELECT 
        ERROR_NUMBER() AS error_number,
        ERROR_MESSAGE() AS error_message,
        ERROR_LINE() AS error_line;
END CATCH;

/**
    2. Write a transaction that updates the budget of an existing project and adjusts the priority of all associated tasks. 
     Ensure that if any part of the transaction fails, all changes are rolled back.
**/
BEGIN TRY
    BEGIN TRANSACTION; 

    DECLARE @project_id INT = 1; 
    UPDATE project
    SET budget = budget + 10000 
    WHERE project_id = @project_id;

    IF @@ROWCOUNT = 0
        THROW 50001, 'Project not found.', 1;

    UPDATE task
    SET priority = 'High'
    WHERE project_id = @project_id;

    COMMIT TRANSACTION;
    PRINT 'Transaction committed successfully.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT < 1
        ROLLBACK TRANSACTION;

    PRINT 'Transaction rolled back due to an error.';

    SELECT 
        ERROR_NUMBER() AS error_number,
        ERROR_MESSAGE() AS error_message,
        ERROR_LINE() AS error_line;
END CATCH;


/*
    3. Do The CRUD Operations to Insert, Update, Delete, Select the Data 
    in Task Table Along with Add Transaction and Error Handling.(Create Seperate SP).
*/


  -- 1. INSERT TASK
CREATE OR ALTER PROCEDURE sp_insert
    @task_name VARCHAR(150),
    @description VARCHAR(255),
    @start_date DATE,
    @due_date DATE,
    @priority VARCHAR(150),
    @status VARCHAR(70),
    @project_id INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO task (task_name, description, start_date, due_date, priority, status, project_id)
        VALUES (@task_name, @description, @start_date, @due_date, @priority, @status, @project_id);

        COMMIT TRANSACTION;
        PRINT 'Task inserted successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT 'Error inserting task.';
        SELECT ERROR_NUMBER() AS error_number, ERROR_MESSAGE() AS error_message, ERROR_LINE() AS error_line;
    END CATCH
END;
GO



   --2. UPDATE TASK

CREATE OR ALTER PROCEDURE sp_update
    @task_id INT,
    @task_name VARCHAR(150),
    @description VARCHAR(255),
    @start_date DATE,
    @due_date DATE,
    @priority VARCHAR(150),
    @status VARCHAR(70),
    @project_id INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE task
        SET task_name = @task_name,
            description = @description,
            start_date = @start_date,
            due_date = @due_date,
            priority = @priority,
            status = @status,
            project_id = @project_id
        WHERE task_id = @task_id;

        IF @@ROWCOUNT = 0
            THROW 50002, 'Task not found.', 1;

        COMMIT TRANSACTION;
        PRINT 'Task updated successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT 'Error updating task.';
        SELECT ERROR_NUMBER() AS error_number, ERROR_MESSAGE() AS error_message, ERROR_LINE() AS error_line;
    END CATCH
END;
GO



  -- 3. DELETE TASK

CREATE OR ALTER PROCEDURE sp_delete
    @task_id INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DELETE FROM task WHERE task_id = @task_id;

        IF @@ROWCOUNT = 0
            THROW 50003, 'Task not found.', 1;

        COMMIT TRANSACTION;
        PRINT 'Task deleted successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT 'Error deleting task.';
        SELECT ERROR_NUMBER() AS error_number, ERROR_MESSAGE() AS error_message, ERROR_LINE() AS error_line;
    END CATCH
END;
GO



   --4. SELECT TASKS

CREATE OR ALTER PROCEDURE sp_select
    @project_id INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @project_id IS NULL
        SELECT * FROM task;
    ELSE
        SELECT * FROM task WHERE project_id = @project_id;
END;
GO
