--USE DATABASE
use kesavan_db
GO

/**

    1. Write a transaction that inserts a new project and multiple associated tasks. 
    Ensure that if any part of the transaction fails, all changes are rolled back.
**/



BEGIN TRY  
    BEGIN TRANSACTION;   
    SET NOCOUNT ON;

    DECLARE @new_project_id INT;    

    INSERT INTO project (project_name, start_date, end_date, budget, status)  
    VALUES ('SAMPLE PROJECT', '2025-12-01', '2025-12-31', 50000, 'Completed');  

    SET @new_project_id = SCOPE_IDENTITY();  
    --PRINT @new_project_id;
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

        ROLLBACK TRANSACTION;

    PRINT 'Transaction rolled back due to an error.';
    PRINT  'ERROR Message: '+error_message();
END CATCH;

--Dispaly result
SELECT * FROM project

/**
    2. Write a transaction that updates the budget of an existing project and adjusts the priority of all associated tasks. 
     Ensure that if any part of the transaction fails, all changes are rolled back.
**/

--before 
select * from project 
select * from task
BEGIN TRY
    BEGIN TRANSACTION; 
    SET NOCOUNT ON;

        DECLARE @project_id INT = 3; 
        IF NOT EXISTS (SELECT * FROM project WHERE project_id = @project_id)
        THROW 50001, 'Project not found.', 1;
    UPDATE project
    SET budget = budget + 10000 
    WHERE project_id = @project_id;

      

    UPDATE task
    SET priority = 'High'
    WHERE project_id = @project_id;
    
    COMMIT TRANSACTION;
    PRINT 'Transaction committed successfully.';

END TRY
BEGIN CATCH
        ROLLBACK TRANSACTION;
    PRINT 'Transaction rolled back due to an error.';
    PRINT 'ERROR MESSAGE: ' + error_message();
END CATCH;

--after
select * from project where project_id = 3
select * from task where project_id = 3
/*
    3. Do The CRUD Operations to Insert, Update, Delete, Select the Data 
    in Task Table Along with Add Transaction and Error Handling.(Create Seperate SP).
*/


  -- 1. INSERT TASK
CREATE OR ALTER PROCEDURE sp_insert_proced_task
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
        ROLLBACK TRANSACTION;

    PRINT 'Transaction rolled back due to an error.';
    PRINT 'ERROR MESSAGE: ' + error_message();
        END CATCH
END;
GO
--task table
SELECT * FROM project
SELECT * FROM task order by task_id desc
----check the result
EXEC sp_insert_proced_task 'sample tasks','a sample description test','2024-02-15','2025-08-24','High','In Progress',3
--EXEC sp_insert_proced_task 'sample tasks','a sample description  test2','2026-02-15','2025-08-24','High','In Progress',3
--EXEC sp_insert_proced_task 'sample tasks','a sample description teset3','2024-02-15','2025-08-24','High','In Progress',3



   --2. UPDATE TASK

CREATE OR ALTER PROCEDURE sp_update_proced_task
    @task_id INT,
    @task_name VARCHAR(150) = NULL,
    @description VARCHAR(255) = NULL,
    @start_date DATE = NULL,
    @due_date DATE = NULL,
    @priority VARCHAR(150) = NULL,
    @status VARCHAR(70) = NULL,
    @project_id INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM task  WHERE task_id = @task_id)
            THROW 50003, 'Task not found.', 1;

        UPDATE dbo.task
        SET
            task_name = COALESCE(@task_name, task_name),
            description = COALESCE(@description, description),
            start_date = COALESCE(@start_date, start_date),
            due_date = COALESCE(@due_date,due_date),
            priority = COALESCE(@priority,priority),
            status = COALESCE(@status,status),
            project_id = COALESCE(@project_id, project_id)
        WHERE task_id = @task_id;

        COMMIT TRANSACTION;

        PRINT 'Task updated successfully.';
    END TRY
    BEGIN CATCH
            ROLLBACK TRANSACTION;
        PRINT 'Transaction rolled back due to an error.';
        PRINT 'ERROR MESSAGE: ' + error_message();
    END CATCH
END;
GO


--task table
SELECT * FROM project
SELECT * FROM task ORDER BY task_id DESC

--to check the result
EXEC sp_update_proced_task 100,'a project name'

  -- 3. DELETE TASK

CREATE OR ALTER PROCEDURE sp_delete_proced_task
    @task_id INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT * FROM task WHERE task_id = @task_id)
            THROW 50003, 'Task not found.', 1;
            
        DELETE FROM task WHERE task_id = @task_id;
        COMMIT TRANSACTION;
        PRINT 'Task deleted successfully.';
    END TRY
    BEGIN CATCH
            ROLLBACK TRANSACTION;

    PRINT 'Transaction rolled back due to an error.';
    PRINT 'ERROR MESSAGE: ' + error_message();
    END CATCH
END;
GO

--task table
SELECT * FROM project
SELECT * FROM task

--result
EXEC sp_delete_proced_task 139

   --4. SELECT TASKS

CREATE OR ALTER PROCEDURE sp_select_proced_task
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

--task table
SELECT * FROM project
SELECT * FROM task

--result
EXEC sp_select_proced_task 10
