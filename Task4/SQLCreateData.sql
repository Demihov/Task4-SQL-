USE Company
GO

INSERT INTO Employee(FirstName, LastName, Phone)
VALUES
('�����', '�������', 0671645891),
('������', '������', 0672363082),
('����', '����', 0935190283),
('������', '����������', 0935290484),
('������', '��������', 0935120385),
('³�����', '��������', 0975150386),
('����', '˳������', 0935191237),
('������', '��������', 0938765288),
('������', 'ͳ���', 0935710229),
('������', '�������', 0672645891),
('���������', '���������', 0671645892),
('������', '�������', 0671234893),
('����', '�����', 0671645894),
('������', '���������', 0631645895),
('�����', '������', 0675678896),
('������', '�������', 0634567897)

GO

--0 - Project open
--1 - Project close
INSERT INTO Project(NameProject,CreatiedAt,StateProject,ClosedAt)
VALUES
('project1','2020-01-01',0,'2020-01-11'),
('project2','2020-01-01',0,'2020-02-12'),
('project3','2019-12-02',1,'2020-03-07'),
('project4','2019-11-03',0,'2020-04-08'),
('project5','2020-01-04',0,'2020-05-03'),
('project6','2020-01-01',0,'2020-06-10'),
('project7','2020-01-02',1,'2020-07-10'),
('project8','2020-02-05',1,'2020-08-12'),
('project9','2019-10-05',1,'2020-09-11'),
('project10','2019-03-02',1,'2020-10-07'),
('project11','2019-10-10',1,'2020-11-10')

GO


INSERT INTO Position(NamePosition)
VALUES
('Front-end Developer'),
('Junior Developer'),
('Senior Developer'),
('Middle Developer'),
('Architect'),
('Development Team Lead'),
('System Administrators'),
('Systems Analyst')

GO

INSERT INTO EmployeeProject(EmployeeId,ProjectId,PositionId)
VALUES
(1,1,1),
(1,2,1),
(1,5,2),
(2,4,3),
(3,4,5),
(5,4,1),
(4,2,5),
(5,2,5),
(5,6,1),
(7,4,6),
(7,5,5),
(8,4,1)

GO

INSERT INTO Task(NameTask, Deadline, EmployeeId, ProjectId)
VALUES
('creating', '2020-05-10', 1, 1),
('updating', '2020-01-10', 1, 2),
('programming', '2020-02-11', 1, 5),
('adding', '2019-12-12', 2, 4),
('deleting', '2019-12-12', 3, 4),
('updating  ', '2020-01-16', 4, 2),
('creating', '2020-01-19', 5, 6),
('monitoring', '2019-11-16', 7, 4),
('programming', '2020-02-27', 5, 2)

GO

INSERT INTO TaskStatus(IdTask, NameStatus, DateSetStatus, IdEmployeeSetStatus)
VALUES
(1,'completed','2020-03-12',2),
(2,'closed','2019-01-12',3),
(3,'needs some work','2019-02-12',4),
(4,'open','2019-12-12',2),
(5,'completed','2018-12-12',1),
(6,null,'2019-12-29',7),
(7,'closed','2019-01-19',7),
(8,'open','2018-12-15',1),
(9, closed,'2019-02-15',6)