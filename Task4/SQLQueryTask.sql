use Company;
GO

--1. Получить список всех должностей компании с количеством сотрудников на каждой из них
SELECT Position.NamePosition, COUNT(EmployeeId) AS CountEmployee
FROM EmployeeProject
JOIN Position ON EmployeeProject.PositionId = Position.Id
GROUP BY Position.NamePosition

--2. Определить список должностей компании, на которых нет сотрудников
SELECT Position.NamePosition
FROM Position
WHERE (SELECT COUNT(EmployeeId) 
		FROM EmployeeProject 
		WHERE PositionId = Position.Id) = 0

--3. Получить список проектов с указанием, сколько сотрудников каждой должности работает на проекте
SELECT Project.NameProject, Position.NamePosition, COUNT(EmployeeProject.EmployeeId)
FROM Project
JOIN EmployeeProject ON Project.Id = EmployeeProject.ProjectId
JOIN Position ON Position.Id = EmployeeProject.PositionId
GROUP BY Project.NameProject, Position.NamePosition 
ORDER BY Project.NameProject

--4. Посчитать на каждом проекте, какое в среднем количество задач приходится на каждого сотрудника
SELECT PR.NameProject, (COUNT(T.Id)/COUNT(DISTINCT EMPR.EmployeeId)) AS AverageTaskToEmployee
FROM Project PR
JOIN EmployeeProject EMPR ON EMPR.ProjectId = PR.Id
JOIN Task T ON T.EmployeeId = EMPR.EmployeeId AND T.ProjectId = EMPR.ProjectId
GROUP BY PR.NameProject

--5. Подсчитать длительность выполнения каждого проекта
SELECT Pr.NameProject, DATEDIFF(day,Pr.CreatiedAt, Pr.ClosedAt) AS DurationOfProject
FROM Project Pr
WHERE Pr.ClosedAt IS NOT NULL

--6. Определить сотрудников с минимальным количеством незакрытых задач
SELECT E.Id, Count(T.Id)
FROM Employee E
JOIN EmployeeProject EMPR ON EMPR.EmployeeId = E.Id
JOIN Task T ON T.EmployeeId = EMPR.EmployeeId AND T.ProjectId = EMPR.ProjectId
JOIN TaskStatus TS ON TS.IdTask = T.Id AND TS.NameStatus != 'closed'
GROUP BY E.Id
HAVING COUNT(T.Id) = (SELECT TOP 1 COUNT(TASK.Id)
					  FROM EmployeeProject
					  JOIN Task ON EmployeeProject.EmployeeId = Task.EmployeeId AND EmployeeProject.ProjectId = Task.ProjectId
					  JOIN TaskStatus ON Task.Id = TaskStatus.IdTask AND TaskStatus.NameStatus != 'closed'
					  GROUP BY EmployeeProject.EmployeeId
					  ORDER BY (COUNT(Task.Id)))

--7. Определить сотрудников с максимальным количеством незакрытых задач, дедлайн которых уже истек
SELECT E.Id, Count(T.Id), T.Id
FROM Employee E
JOIN EmployeeProject EMPR ON EMPR.EmployeeId = E.Id
JOIN Task T ON T.EmployeeId = EMPR.EmployeeId AND T.ProjectId = EMPR.ProjectId AND T.Deadline < GETDATE()
JOIN TaskStatus TS ON TS.IdTask = T.Id AND TS.NameStatus != 'closed'
GROUP BY E.Id, T.Id
HAVING COUNT(T.Id) = (SELECT TOP 1 COUNT(TASK.Id)
					  FROM EmployeeProject
					  JOIN Task ON EmployeeProject.EmployeeId = Task.EmployeeId AND EmployeeProject.ProjectId = Task.ProjectId AND Task.Deadline < GETDATE()
					  JOIN TaskStatus ON Task.Id = TaskStatus.IdTask AND TaskStatus.NameStatus != 'closed'
					  GROUP BY EmployeeProject.EmployeeId
					  ORDER BY  (COUNT(Task.Id)) DESC)

--8. Продлить дедлайн незакрытых задач на 5 дней
UPDATE Task
SET Deadline = DATEADD(DAY, 5, Task.Deadline)
FROM (SELECT * 
	  FROM Task
	  JOIN TaskStatus ON TaskStatus.IdTask = Task.Id
	  WHERE TaskStatus.NameStatus != 'closed') AS Selected
WHERE Task.Id = Selected.Id

--9. Посчитать на каждом проекте количество задач, к которым еще не приступили
SELECT EmployeeProject.ProjectId, Count(Task.Id) AS NumberOfTasksNotYetStarted
FROM EmployeeProject 
JOIN Task ON Task.ProjectId = EmployeeProject.ProjectId AND Task.EmployeeId = EmployeeProject.EmployeeId
JOIN TaskStatus ON TaskStatus.NameStatus IS NULL AND TaskStatus.IdTask = Task.Id
GROUP BY EmployeeProject.ProjectId

--10. Перевести проекты в состояние закрыт, для которых все задачи закрыты 
--    и задать время закрытия временем закрытия задачи проекта, принятой последней
UPDATE Project
SET StateProject = 1,
ClosedAt = MaxDate
FROM( SELECT Pr.Id, Max(TS.DateSetStatus) AS MaxDate
	  FROM Project Pr
	  JOIN EmployeeProject EMPR ON Pr.Id = EMPR.ProjectId
	  JOIN Task T ON T.ProjectId = Pr.Id
	  JOIN TaskStatus TS ON TS.IdTask = T.Id
	  WHERE Pr.StateProject != 1 AND 'closed' = ALL (SELECT TaskStatus.NameStatus 
	  												FROM TaskStatus
	  												JOIN Task ON Task.Id = TaskStatus.IdTask 
	  												AND Task.ProjectId = EMPR.ProjectId)
	  GROUP BY Pr.Id) AS Selected
WHERE Project.Id = Selected.Id

--11. Выяснить по всем проектам, какие сотрудники на проекте не имеют незакрытых задач
SELECT EMPR.ProjectId, EMPR.EmployeeId
FROM EmployeeProject EMPR
JOIN Task T ON T.EmployeeId = EMPR.EmployeeId AND T.ProjectId = EMPR.ProjectId
JOIN TaskStatus TS ON TS.IdTask = T.Id AND 'closed' = ALL (SELECT TaskStatus.NameStatus
														   FROM TaskStatus 
														   JOIN Task ON Task.Id = TaskStatus.IdTask
														   JOIN EmployeeProject ON Task.ProjectId = EmployeeProject.ProjectId 
														   AND Task.EmployeeId = EmployeeProject.EmployeeId 
														   AND EmployeeProject.EmployeeId = EMPR.EmployeeId)



--12. Заданную задачу (по названию) проекта перевести на сотрудника с минимальным количеством выполняемых им задач
GO
CREATE PROCEDURE TaskTransferToEmployee
@taskName VARCHAR(30) AS
BEGIN 

SELECT EmployeeProject.EmployeeId, COUNT(T.Id) AS CountTasks INTO EmployeeWithMinTask
	  FROM EmployeeProject 
	  LEFT JOIN Task T ON T.EmployeeId = EmployeeProject.EmployeeId 
	  LEFT JOIN TaskStatus TS ON T.Id = TS.IdTask 
	  WHERE EmployeeProject.ProjectId = (SELECT TOP 1 ProjectId FROM Task WHERE NameTask = @taskName) 
	  and ((TS.NameStatus != 'completed' AND TS.NameStatus != 'closed')
	  OR TS.IdTask IS NULL)
	  GROUP BY EmployeeProject.EmployeeId
	  ORDER BY COUNT(T.Id)

UPDATE Task 
SET EmployeeId = (SELECT TOP 1 EmployeeId FROM EmployeeWithMinTask)
WHERE Id = (SELECT Task.Id
			FROM Task
			WHERE Task.NameTask = @taskName)

DROP TABLE EmployeeWithMinTask
END

GO
EXEC TaskTransferToEmployee 'adding'
GO
DROP PROCEDURE TaskTransferToEmployee