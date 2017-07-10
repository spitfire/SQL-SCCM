USE CM_P01
-- For Windows 7, Server 2008 R2 SP1, Windows Server 2012, Server 2012 R2 and Windows 8.1, Windows Vista and Server 2008 SP2
-- This query lists machines that are reporting any of the 'Security Only' updates as 'Required'.
-- If any machine has either March, April or May Monthly Rollup installed, then they wouldn't report March 'Security Only' update as 'Required', but look for the Monthly updates anyway.
-- Also include any Windows 8.1 and Server 2012 R2 machines which do not report ‘KB2919355’ as Installed.

DECLARE @MarchSecurityOnly TABLE (ArticleID NVARCHAR(20))
INSERT INTO @MarchSecurityOnly VALUES ('4012212')
INSERT INTO @MarchSecurityOnly VALUES ('4012213')
INSERT INTO @MarchSecurityOnly VALUES ('4012214')
INSERT INTO @MarchSecurityOnly VALUES ('4012598')

DECLARE @MarchMonthly TABLE (ArticleID NVARCHAR(20))
INSERT INTO @MarchMonthly VALUES ('4012215')
INSERT INTO @MarchMonthly VALUES ('4015549')
INSERT INTO @MarchMonthly VALUES ('4019264')
INSERT INTO @MarchMonthly VALUES ('4012216')
INSERT INTO @MarchMonthly VALUES ('4015550')
INSERT INTO @MarchMonthly VALUES ('4019215')
INSERT INTO @MarchMonthly VALUES ('4012217')
INSERT INTO @MarchMonthly VALUES ('4015551')
INSERT INTO @MarchMonthly VALUES ('4019216')

DECLARE @KB2919355SRV NVARCHAR(50) = '8452bac0-bf53-4fbd-915d-499de08c338b'
DECLARE @KB2919355WSx86 NVARCHAR(50) = '4ca4dbaa-fae4-4a7c-9760-8e202d10128f'
DECLARE @KB2919355WSx64 NVARCHAR(50) = '26e2a7ee-34d5-4161-ab79-56625337046f'

SELECT 
       RS.Name0, 
       UI.ArticleID as ArticleID, 
       UI.BulletinID as BulletinID, 
       UI.Title as Title, 
       SN.StateDescription AS State,
       UCS.LastStatusCheckTime AS LastStateReceived,
       UCS.LastStatusChangeTime AS LastStateChanged,
       UI.CI_UniqueID AS UniqueUpdateID
FROM v_Update_ComplianceStatusReported UCS
JOIN v_UpdateInfo UI ON UCS.CI_ID = UI.CI_ID
JOIN v_R_System RS ON RS.ResourceType=5 AND RS.ResourceID = UCS.ResourceID
JOIN v_StateNames SN ON SN.TopicType=500 AND SN.StateID=2 AND SN.StateID = UCS.Status
WHERE UI.ArticleID IN (SELECT ArticleID FROM @MarchSecurityOnly) 
AND RS.Name0 NOT IN (
       -- Monthly is installed
       SELECT distinct RS.Name0 
       FROM v_Update_ComplianceStatusReported UCS
       JOIN v_UpdateInfo UI ON UCS.CI_ID = UI.CI_ID
       JOIN v_R_System RS ON RS.ResourceType=5 AND RS.ResourceID = UCS.ResourceID
       JOIN v_StateNames SN ON SN.TopicType=500 AND SN.StateID=3 AND SN.StateID = UCS.Status
       WHERE UI.ArticleID IN (SELECT ArticleID FROM @MarchMonthly) 
)
UNION
-- Windows Server 2012 R2 machines that do not report KB2919355 as Installed.
SELECT 
       distinct RS.Name0,
       UI.ArticleID as ArticleID, 
       UI.BulletinID as BulletinID, 
       'KB2919355' as Title,      
       'Update is not Installed' AS State,
       NULL AS LastStateReceived,
       NULL AS LastStateChanged,
       'KB2919355' AS UniqueUpdateID
FROM v_Update_ComplianceStatusReported UCS
JOIN v_UpdateInfo UI ON UCS.CI_ID = UI.CI_ID
JOIN v_R_System RS ON RS.ResourceType=5 AND RS.ResourceID = UCS.ResourceID
JOIN v_StateNames SN ON SN.TopicType=500 AND SN.StateID = UCS.Status AND SN.StateID <> 3
JOIN v_GS_OPERATING_SYSTEM OS ON RS.ResourceID = OS.ResourceID AND OS.BuildNumber0 = '9600' AND OS.Caption0 like '%Server 2012 R2%' -- Server 2012 R2
WHERE UI.CI_UniqueID = @KB2919355SRV -- Server 2012 R2
UNION 
-- Windows 8.1 x86 machines that do not report KB2919355 as Installed.
SELECT 
       distinct RS.Name0,
       UI.ArticleID as ArticleID, 
       UI.BulletinID as BulletinID, 
       'KB2919355' as Title,      
       'Update is not Installed' AS State,
       NULL AS LastStateReceived,
       NULL AS LastStateChanged,
       'KB2919355' AS UniqueUpdateID
FROM v_Update_ComplianceStatusReported UCS
JOIN v_UpdateInfo UI ON UCS.CI_ID = UI.CI_ID
JOIN v_R_System RS ON RS.ResourceType=5 AND RS.ResourceID = UCS.ResourceID
JOIN v_StateNames SN ON SN.TopicType=500 AND SN.StateID = UCS.Status AND SN.StateID <> 3
JOIN v_GS_OPERATING_SYSTEM OS ON RS.ResourceID = OS.ResourceID AND OS.BuildNumber0 = '9600' AND OS.Caption0 like '%Windows 8.1%' -- Windows 8.1
JOIN v_GS_COMPUTER_SYSTEM CS1 ON CS1.ResourceID = RS.ResourceID AND CS1.SystemType0 = 'X86-based PC' -- x86
WHERE UI.CI_UniqueID = @KB2919355WSx86
UNION 
-- Windows 8.1 x64 machines that do not report KB2919355 as Installed.
SELECT 
       distinct RS.Name0,
       UI.ArticleID as ArticleID, 
       UI.BulletinID as BulletinID, 
       'KB2919355' as Title,      
       'Update is not Installed' AS State,
       NULL AS LastStateReceived,
       NULL AS LastStateChanged,
       'KB2919355' AS UniqueUpdateID
FROM v_Update_ComplianceStatusReported UCS
JOIN v_UpdateInfo UI ON UCS.CI_ID = UI.CI_ID
JOIN v_R_System RS ON RS.ResourceType=5 AND RS.ResourceID = UCS.ResourceID
JOIN v_StateNames SN ON SN.TopicType=500 AND SN.StateID = UCS.Status AND SN.StateID <> 3
JOIN v_GS_OPERATING_SYSTEM OS ON RS.ResourceID = OS.ResourceID AND OS.BuildNumber0 = '9600' AND OS.Caption0 like '%Windows 8.1%' -- Windows 8.1
JOIN v_GS_COMPUTER_SYSTEM CS1 ON CS1.ResourceID = RS.ResourceID AND CS1.SystemType0 = 'X64-based PC' -- x64
WHERE UI.CI_UniqueID = @KB2919355WSx64