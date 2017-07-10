USE CM_P01
-- Windows 10 machines that do not have the March (or any of the superseding updates) installed, and could be 'unpatched'.
-- These queries are OS dependent, since we are querying individual KB's, and need to compare those KB's against proper builds to prevent getting inaccurate results.

-- Windows 10 RTM
DECLARE @BuildNumberRTM INT = '10240'
DECLARE @MarchWin10 TABLE (ArticleID NVARCHAR(20))
INSERT INTO @MarchWin10 VALUES ('4012606') -- March Cumulative
INSERT INTO @MarchWin10 VALUES ('4019474')
INSERT INTO @MarchWin10 VALUES ('4015221')
INSERT INTO @MarchWin10 VALUES ('4016637')

-- Windows 10 1511
DECLARE @BuildNumber1511 INT = '10586'
DECLARE @MarchWin101511 TABLE (ArticleID NVARCHAR(20))
INSERT INTO @MarchWin101511 VALUES ('4013198') -- March Cumulative
INSERT INTO @MarchWin101511 VALUES ('4015219')
INSERT INTO @MarchWin101511 VALUES ('4016636')
INSERT INTO @MarchWin101511 VALUES ('4019473')

-- Windows 10 1607
DECLARE @BuildNumber1607 INT = '14393'
DECLARE @MarchWin101607 TABLE (ArticleID NVARCHAR(20))
INSERT INTO @MarchWin101607 VALUES ('4013429') -- March Cumulative
INSERT INTO @MarchWin101607 VALUES ('4015217')
INSERT INTO @MarchWin101607 VALUES ('4015438')
INSERT INTO @MarchWin101607 VALUES ('4016635')
INSERT INTO @MarchWin101607 VALUES ('4019472')

SELECT RS.Name0, OS.BuildNumber0 FROM v_R_System RS
JOIN v_GS_OPERATING_SYSTEM OS ON RS.ResourceID = OS.ResourceID AND OS.BuildNumber0 = @BuildNumber1607
WHERE RS.Name0 NOT IN (
SELECT RS.Name0
FROM v_Update_ComplianceStatusReported UCS
JOIN v_UpdateInfo UI ON UCS.CI_ID = UI.CI_ID
JOIN v_R_System RS ON RS.ResourceType=5 AND RS.ResourceID = UCS.ResourceID
JOIN v_StateNames SN ON SN.TopicType=500 AND SN.StateID=3 AND SN.StateID = UCS.Status
JOIN v_GS_OPERATING_SYSTEM OS ON OS.ResourceID = RS.ResourceID AND OS.BuildNumber0 = @BuildNumber1607
WHERE UI.ArticleID IN (SELECT ArticleID FROM @MarchWin101607)
)
UNION
SELECT RS.Name0, OS.BuildNumber0 FROM v_R_System RS
JOIN v_GS_OPERATING_SYSTEM OS ON RS.ResourceID = OS.ResourceID AND OS.BuildNumber0 = @BuildNumberRTM
WHERE RS.Name0 NOT IN (
SELECT RS.Name0
FROM v_Update_ComplianceStatusReported UCS
JOIN v_UpdateInfo UI ON UCS.CI_ID = UI.CI_ID
JOIN v_R_System RS ON RS.ResourceType=5 AND RS.ResourceID = UCS.ResourceID
JOIN v_StateNames SN ON SN.TopicType=500 AND SN.StateID=3 AND SN.StateID = UCS.Status
JOIN v_GS_OPERATING_SYSTEM OS ON OS.ResourceID = RS.ResourceID AND OS.BuildNumber0 = @BuildNumberRTM
WHERE UI.ArticleID IN (SELECT ArticleID FROM @MarchWin10)
)
UNION
SELECT RS.Name0, OS.BuildNumber0 FROM v_R_System RS
JOIN v_GS_OPERATING_SYSTEM OS ON RS.ResourceID = OS.ResourceID AND OS.BuildNumber0 = @BuildNumber1511
WHERE RS.Name0 NOT IN (
SELECT RS.Name0
FROM v_Update_ComplianceStatusReported UCS
JOIN v_UpdateInfo UI ON UCS.CI_ID = UI.CI_ID
JOIN v_R_System RS ON RS.ResourceType=5 AND RS.ResourceID = UCS.ResourceID
JOIN v_StateNames SN ON SN.TopicType=500 AND SN.StateID=3 AND SN.StateID = UCS.Status
JOIN v_GS_OPERATING_SYSTEM OS ON OS.ResourceID = RS.ResourceID AND OS.BuildNumber0 = @BuildNumber1511
WHERE UI.ArticleID IN (SELECT ArticleID FROM @MarchWin101511)
)