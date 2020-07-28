DROP DATABASE IF EXISTS Company;
GO

CREATE DATABASE Company;
GO 

USE Company;
GO

CREATE TABLE Employee(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	Phone INT UNIQUE NOT NULL
);
GO

CREATE TABLE Project(
	Id INT PRIMARY KEY IDENTITY,
	NameProject NVARCHAR(50) UNIQUE NOT NULL,
	CreatiedAt DATE NOT NULL,
	ClosedAt DATE NOT NULL,
	StateProject BIT NOT NULL
)
GO

CREATE TABLE Position(
	Id INT PRIMARY KEY IDENTITY,
	NamePosition VARCHAR(40) NOT NULL
)
GO

CREATE TABLE EmployeeProject(
	EmployeeId INT REFERENCES Employee(Id),
	ProjectId INT REFERENCES Project(Id),
	PositionId INT REFERENCES Position(Id),
	CONSTRAINT PK_EmployeeProject_Id PRIMARY KEY(EmployeeId,ProjectId)
)
GO

CREATE TABLE Task(
	Id INT PRIMARY KEY IDENTITY,
	NameTask NVARCHAR(100) NOT NULL,
	Deadline DATETIME NOT NULL,
	EmployeeId INT NOT NULL,
	ProjectId INT NOT NULL,

	CONSTRAINT FK_Task_To_EmployeeProject FOREIGN KEY (EmployeeId,ProjectId)  REFERENCES EmployeeProject(EmployeeId,ProjectId)
)
GO

CREATE TABLE TaskStatus(
	IdTask INT PRIMARY KEY,
	NameStatus VARCHAR(20),
	DateSetStatus DATETIME NOT NULL,
	IdEmployeeSetStatus INT NOT NULL,
	CONSTRAINT FK_TaskStatus_To_Task FOREIGN KEY (IdTask) REFERENCES Task(Id),
	CONSTRAINT FK_IdEmployeeCheckStatus_To_Employee FOREIGN KEY (IdEmployeeSetStatus) REFERENCES Employee(Id)
)
