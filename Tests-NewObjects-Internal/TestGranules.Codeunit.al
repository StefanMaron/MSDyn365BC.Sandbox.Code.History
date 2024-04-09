codeunit 132532 "Test Granules"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Permissions]
    end;

    var
        Assert: Codeunit Assert;
        TableDataNotInAnyPermissionSetTxt: Label 'Table %1 "%2" does not exist in any permission set.', Comment = '%1=Table No.,%2=Table Name';
        TableDataNotInLocalPermissionSetTxt: Label 'Table %1 "%2" does not exist in the local permission set.', Comment = '%1=Table No.,%2=Table Name';
        TableDataNotInFullPermissionSetTxt: Label 'Table %1 "%2" does not exist in the O365 Full Access permission set.', Comment = '%1=Table No.,%2=Table Name';
        TableDataOnlyInFullPermissionSetTxt: Label 'Table %1 "%2" exists in the O365 Full Access permission set, but not in any other O365 permission set. Each object has to be added to at least one non-O365 FULL ACCESS PS.', Comment = '%1=Table No.,%2=Table Name';
#pragma warning disable AA0470        
        PermissionDoesNotExistsTxt: Label 'Table Data with ID %1 exists in permission set %2 but not as an application table (read test for resolution).';
        PermissionNotInPSWithSufficientPermissionsErr: Label 'Insufficient permissions (read test for resolution). Permission %1 "%2" (%3) Role ID %4 and Permissions: Read %5, Insert %6, Modify %7, Delete %8, Execute %9 does not exist with sufficient permissions in Permission Set Role ID %10.';
#pragma warning restore AA0470        
        XO365FULLTxt: Label 'D365 FULL ACCESS';
        XO365BUSFULLTxt: Label 'D365 BUS FULL ACCESS';
        XO365EXTENSIONMGTTxt: Label 'D365 EXTENSION MGT';
        XO365PREMIUMBUSTxt: Label 'D365 BUS PREMIUM';
        XCUSTOMERVIEWTxt: Label 'D365 CUSTOMER, VIEW';
        XCUSTOMEREDITTxt: Label 'D365 CUSTOMER, EDIT';
        XO365BACKUPRESTORETxt: Label 'D365 BACKUP/RESTORE';
        XITEMEDITTxt: Label 'D365 ITEM, EDIT';
        XSALESDOCCREATETxt: Label 'D365 SALES DOC, EDIT';
        XSALESDOCPOSTTxt: Label 'D365 SALES DOC, POST';
        XSETUPTxt: Label 'D365 SETUP';
        XACCOUNTSRECEIVABLETxt: Label 'D365 ACC. RECEIVABLE';
        XJOURNALSEDITTxt: Label 'D365 JOURNALS, EDIT';
        XJOURNALSPOSTTxt: Label 'D365 JOURNALS, POST';
        XACCOUNTSPAYABLETxt: Label 'D365 ACC. PAYABLE';
        XVENDORVIEWTxt: Label 'D365 VENDOR, VIEW';
        XVENDOREDITTxt: Label 'D365 VENDOR, EDIT';
        XSECURITYTxt: Label 'SECURITY', Locked = true;
        XPURCHDOCCREATETxt: Label 'D365 PURCH DOC, EDIT';
        XPURCHDOCPOSTTxt: Label 'D365 PURCH DOC, POST';
        ProfileManagementTok: Label 'D365 PROFILE MGT', Locked = true;
        XLOCALTxt: Label 'LOCAL';
        XFIXEDASSETSVIEWTxt: Label 'D365 FA, VIEW';
        XFIXEDASSETSEDITTxt: Label 'D365 FA, EDIT';
        XTEAMMEMBERTxt: Label 'D365 TEAM MEMBER';
        D365AccountantsTxt: Label 'D365 ACCOUNTANTS';
        D365CompanyHubTxt: Label 'D365 COMPANY HUB';
        PlanConfigurationMissingLocalErr: Label '%1 plan doesn''t contain %2 default permission set.', Comment = '%1 = plan ID, %2 = Permission Set ID';
        TeamsUsersMissingLoginErr: Label 'Teams Users user plan configuration doesn''t contain Login permission set.';
        D365PermissionSetPrefixFilterTok: Label 'D365*';
        ReadTok: Label 'D365 READ', Locked = true;
        D365EssentialPermissionSetFilterTok: Label '<>D365PREM*&D365*';
        BasicISVTok: Label 'D365 BASIC ISV', Locked = true;
        D365MonitorFieldsTok: Label 'D365 Monitor Fields', Locked = true;
        XRetentionPolSetupTok: Label 'RETENTION POL. SETUP', Locked = true;
        XSnapshotDebugTok: Label 'D365 SNAPSHOT DEBUG';
        XAttachDebuggingTok: Label 'D365 ATTACH DEBUG';
        D365AutomationTok: Label 'D365 AUTOMATION';
        D365DIMCORRECTIONTok: Label 'D365 DIM CORRECTION', Locked = true;
        D365CreateFieldsTok: Label 'D365 Create Fields', Locked = true;
        TeamsUsersTok: Label 'TEAMS USERS', Locked = true;
        LocalReadTxt: Label 'LOCAL READ', Locked = true;
        LoginTxt: Label 'LOGIN', Locked = true;
        BackupRestoreDataTok: Label 'D365 BACKUP/RESTORE', Locked = true;
        BackupRestoreDataDescription: Label 'Backup or restore database';

    [Test]
    [Scope('OnPrem')]
    procedure ExtensionManagementNotAssignedToPlansOrUsers()
    var
        PermissionSetInPlanBuffer: Record "Permission Set In Plan Buffer";
        AccessControl: Record "Access Control";
        PlanConfiguration: Codeunit "Plan Configuration";
    begin
        // Extension management is not assigned to any plan by default
        PlanConfiguration.GetDefaultPermissions(PermissionSetInPlanBuffer);

        PermissionSetInPlanBuffer.SetRange("Role ID", XO365EXTENSIONMGTTxt);
        PermissionSetInPlanBuffer.SetFilter("Plan ID", '<>%1', '00000000-0000-0000-0000-000000000010'); // D365 Automation, not meant for users but requires permissions by default
        Assert.RecordIsEmpty(PermissionSetInPlanBuffer);

        //  Extension management is not assigned to any user by default
        AccessControl.SetRange("Role ID", XO365EXTENSIONMGTTxt);
        Assert.RecordIsEmpty(AccessControl);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure AllAppTablesAreInPermissionSet()
    var
        TempTableDataAllObj: Record AllObj temporary;
        TempPermission: Record Permission temporary;
        TypeHelper: Codeunit "Type Helper";
        Errors: DotNet ArrayList;
        String: Dotnet String;
    begin
        // If this test fails, it means that you added a Table but forgot to add it to a permission set
        // If the table uses inherent permissions, it is excluded from this check by adding to GetTablesWithInherentEntitlements
        // Temporary Tables are excluded from this check
        Errors := Errors.ArrayList();
        CopyAllAppTableObjectsToTempBuffer(TempTableDataAllObj);
        CopyAllTablePermissionsToTempBuffer(TempPermission);

        // The AllObj table includes system tables which must be excluded from this check
        TempTableDataAllObj.SetFilter("Object ID", '<2000000000');
        TempTableDataAllObj.FindSet();
        repeat
            TempPermission.SetRange("Object Type", TempTableDataAllObj."Object Type");
            TempPermission.SetRange("Object ID", TempTableDataAllObj."Object ID");
            if TempPermission.IsEmpty() then
                Errors.Add(StrSubstNo(TableDataNotInAnyPermissionSetTxt, TempTableDataAllObj."Object ID", TempTableDataAllObj."Object Name"));
        until TempTableDataAllObj.Next() = 0;

        if Errors.Count > 0 then
            Error(String.Join(TypeHelper.NewLine(), Errors.ToArray()));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure AllLocalAppObjectsAreInLocalPermissionSet()
    var
        TempTableDataAllObj: Record AllObj temporary;
        TempAllLocalPermission: Record Permission temporary;
    begin
        // If this test fails, it means that you added a local Table but forgot to add it to the local permission set
        // If the table uses inherent permissions, it is excluded from this check by adding to GetTablesWithInherentEntitlements
        CopyAllAppTableObjectsToTempBuffer(TempTableDataAllObj);
        RemoveNonLocalObjectsFromObjects(TempTableDataAllObj);
        CopyPSToTemp(TempAllLocalPermission, XLOCALTxt);
        if TempTableDataAllObj.FindSet() then
            repeat
                TempAllLocalPermission.SetRange("Object Type", TempTableDataAllObj."Object Type");
                TempAllLocalPermission.SetRange("Object ID", TempTableDataAllObj."Object ID");
                Assert.IsFalse(TempAllLocalPermission.IsEmpty, StrSubstNo(TableDataNotInLocalPermissionSetTxt, TempTableDataAllObj."Object ID", TempTableDataAllObj."Object Name"));
            until TempTableDataAllObj.Next() = 0;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure AllLocalAppObjectsAreInO365FullPermissionSet()
    var
        TempTableDataAllObj: Record AllObj temporary;
        TempAllLocalPermission: Record Permission temporary;
    begin
        // If this test fails, it means that you added a local Table but forgot to add it to the O365 Full Access permission set
        // To do this, open COD101982 and add the Object here.
        // If the table uses inherent permissions, it is excluded from this check by adding to GetTablesWithInherentEntitlements
        CopyAllAppTableObjectsToTempBuffer(TempTableDataAllObj);
        RemoveNonLocalObjectsFromObjects(TempTableDataAllObj);
        CopyPSToTemp(TempAllLocalPermission, XO365FULLTxt);
        if TempTableDataAllObj.FindSet() then
            repeat
                TempAllLocalPermission.SetRange("Object Type", TempTableDataAllObj."Object Type");
                TempAllLocalPermission.SetRange("Object ID", TempTableDataAllObj."Object ID");
                Assert.IsFalse(TempAllLocalPermission.IsEmpty, StrSubstNo(TableDataNotInFullPermissionSetTxt, TempTableDataAllObj."Object ID", TempTableDataAllObj."Object Name"));
            until TempTableDataAllObj.Next() = 0;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure AllLocalAppObjectsAreInO365BusFullPermissionSet()
    var
        TempTableDataAllObj: Record AllObj temporary;
        TempAllLocalPermission: Record Permission temporary;
    begin
        // If this test fails, it means that you added a local Table but forgot to add it to the O365 Bus Full Access permission set
        // To do this, open COD101982 and add the Object here.
        // If the table uses inherent permissions, it is excluded from this check by adding to GetTablesWithInherentEntitlements
        CopyAllAppTableObjectsToTempBuffer(TempTableDataAllObj);
        RemoveNonLocalObjectsFromObjects(TempTableDataAllObj);
        CopyPSToTemp(TempAllLocalPermission, XO365BUSFULLTxt);
        if TempTableDataAllObj.FindSet() then
            repeat
                TempAllLocalPermission.SetRange("Object Type", TempTableDataAllObj."Object Type");
                TempAllLocalPermission.SetRange("Object ID", TempTableDataAllObj."Object ID");
                Assert.IsFalse(TempAllLocalPermission.IsEmpty, StrSubstNo(TableDataNotInFullPermissionSetTxt, TempTableDataAllObj."Object ID", TempTableDataAllObj."Object Name"));
            until TempTableDataAllObj.Next() = 0;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure AllPermissionsAreObjects()
    var
        TempTableDataAllObj: Record AllObj temporary;
        TempPermission: Record Permission temporary;
        TableMetadata: Record "Table Metadata";
        TablesWithInherentEntitlements: Dictionary of [Integer, Boolean];
    begin
        // Get tables that use inherent entitlements
        TablesWithInherentEntitlements := GetTablesWithInherentEntitlements();

        // CopyAllAppTableObjectsToTempBuffer and CopyAllTablePermissionsToTempBuffer to contain correct ranges
        CopyAllAppTableObjectsToTempBuffer(TempTableDataAllObj);
        CopyAllTablePermissionsToTempBuffer(TempPermission);
        TempPermission.SetFilter("Object ID", '<%1', 130000);
        TempPermission.FindSet();
        repeat
            TempTableDataAllObj.SetRange("Object Type", TempPermission."Object Type");
            TempTableDataAllObj.SetRange("Object ID", TempPermission."Object ID");

            // Temporary Tables are not included in TempTableDataAllObj
            if ((TempPermission."Object Type" <> TempPermission."Object Type"::"Table Data") or
                    not TableMetadata.Get(TempPermission."Object ID") or
                    (TableMetadata.TableType <> 6)) and
                    not TablesWithInherentEntitlements.ContainsKey(TempPermission."Object ID") then
                Assert.IsFalse(TempTableDataAllObj.IsEmpty, StrSubstNo(PermissionDoesNotExistsTxt, TempPermission."Object ID", TempPermission."Role ID"));
        until TempPermission.Next() = 0;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure AllAppObjectsAreInAtLeastOneNonO365FullPermissionSet()
    var
        TempTableDataAllObj: Record AllObj temporary;
        TempPermission: Record Permission temporary;
        O365PermissionSetsList: DotNet GenericList1;
        IsO365PermissionSet: Boolean;
    begin
        // If this test fails, it means that Table is added to O365 FULL ACCESS permission
        // but the table is not added to at least one (non-O365 FULL) Permission Set
        // and add the Object to at least one (non-O365 FULL) Permission Set
        // If the table uses inherent permissions, it is excluded from this check by adding to GetTablesWithInherentEntitlements
        O365PermissionSetsList := O365PermissionSetsList.List();
        GetO365PermissionSets(O365PermissionSetsList, false);
        CopyAllAppTableObjectsToTempBuffer(TempTableDataAllObj);
        CopyAllTablePermissionsToTempBuffer(TempPermission);
        if TempTableDataAllObj.FindSet() then
            repeat
                TempPermission.SetRange("Object Type", TempTableDataAllObj."Object Type");
                TempPermission.SetRange("Object ID", TempTableDataAllObj."Object ID");
                TempPermission.SetRange("Role ID", XO365FULLTxt);
                if TempPermission.FindFirst() then begin
                    TempPermission.SetRange("Role ID");
                    IsO365PermissionSet := false;
                    if TempPermission.FindSet() then
                        repeat
                            if O365PermissionSetsList.Contains(TempPermission."Role ID") then
                                IsO365PermissionSet := true;
                        until IsO365PermissionSet or (TempPermission.Next() = 0);
                    Assert.IsTrue(IsO365PermissionSet, StrSubstNo(TableDataOnlyInFullPermissionSetTxt,
                        TempTableDataAllObj."Object ID", TempTableDataAllObj."Object Name"));
                end;
            until TempTableDataAllObj.Next() = 0;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure AllD365PermissionsAreInD365PremiumBus()
    var
        TempAllO365Permission: Record Permission temporary;
        PermissionSet: Record "Permission Set";
    begin
        // This test verifies that all Permissions in the O365 Permission sets are also added to the 'D365 BUS PREMIUM' Permission Set with
        // at least the same amount of permissions (read, modify, insert, delete, execute), excluding security and extension management.
        // If this test fails, it means you added a new permission to one of the permission sets prefixed with D365.
        // Solution: Add the new permission to the O365 Premium Permission set as well (if you just updated a permission, make the same update in 'D365 BUS PREMIUM').

        PermissionSet.SetFilter("Role ID", D365PermissionSetPrefixFilterTok);
        PermissionSet.FindSet();
        repeat
            if not (PermissionSet."Role ID" in [XO365FULLTxt, D365AccountantsTxt, D365CompanyHubTxt, XO365EXTENSIONMGTTxt, XO365BACKUPRESTORETxt, ProfileManagementTok, D365MonitorFieldsTok, XRetentionPolSetupTok, XSnapshotDebugTok, XAttachDebuggingTok, D365AutomationTok, D365DIMCORRECTIONTok, D365CreateFieldsTok]) then
                CopyPSToTemp(TempAllO365Permission, PermissionSet."Role ID");
        until PermissionSet.Next() = 0;

        CopyPSToTemp(TempAllO365Permission, XLOCALTxt);

        VerifyTempPSinPS(TempAllO365Permission, XO365PREMIUMBUSTxt);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure AllO365PermissionsAreInO365BusFull()
    var
        TempAllO365Permission: Record Permission temporary;
        PermissionSet: Record "Permission Set";
    begin
        // This test verifies that all Permissions in the O365 Permission sets are also added to the 'D365 BUS FULL ACCESS' Permission Set with
        // at least the same amount of permissions (read, modify, insert, delete, execute), excluding security and extension management.
        // If this test fails, it means you added a new permission to one of the permission sets prefixed with D365.
        // Solution: Add the new permission to the O365 Full Access Permission set as well (if you just updated a permission, make the same update in 'D365 BUS FULL ACCESS').

        PermissionSet.SetFilter("Role ID", D365EssentialPermissionSetFilterTok);
        PermissionSet.FindSet();
        repeat
            if not (PermissionSet."Role ID" in [XO365FULLTxt, D365AccountantsTxt, D365CompanyHubTxt, XO365EXTENSIONMGTTxt, XO365PREMIUMBUSTxt, ReadTok, XO365BACKUPRESTORETxt, ProfileManagementTok, D365MonitorFieldsTok, XRetentionPolSetupTok, XSnapshotDebugTok, XAttachDebuggingTok, D365AutomationTok, D365DIMCORRECTIONTok, D365CreateFieldsTok]) then
                CopyPSToTemp(TempAllO365Permission, PermissionSet."Role ID");
        until PermissionSet.Next() = 0;

        CopyPSToTemp(TempAllO365Permission, XLOCALTxt);

        VerifyTempPSinPS(TempAllO365Permission, XO365BUSFULLTxt);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure AllO365PermissionsAreInO365Full()
    var
        TempAllO365Permission: Record Permission temporary;
        PermissionSet: Record "Permission Set";
    begin
        // This test verifies that all Permissions in the O365 Permission sets are also added to the 'D365 FULL ACCESS' Permission Set with
        // at least the same amount of permissions (read, modify, insert, delete, execute). This permission set reflects all permissions in O365.
        // If this test fails, it means you added a new permission to one of the permission sets prefixed with D365.
        // Solution: Add the new permission to the O365 Full Access Permission set as well (if you just updated a permission, make the same update in 'D365 FULL ACCESS').

        PermissionSet.SetFilter("Role ID", D365PermissionSetPrefixFilterTok);
        PermissionSet.FindSet();

        repeat
            if not (PermissionSet."Role ID" in [XO365BACKUPRESTORETxt, D365AutomationTok, D365DIMCORRECTIONTok]) then
                CopyPSToTemp(TempAllO365Permission, PermissionSet."Role ID");
        until PermissionSet.Next() = 0;

        CopyPSToTemp(TempAllO365Permission, XSECURITYTxt);
        CopyPSToTemp(TempAllO365Permission, XLOCALTxt);

        VerifyTempPSinPS(TempAllO365Permission, XO365FULLTxt);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure O365PermissionSetHierarchy()
    begin
        // This test verifies the O365 hierarchy. Which is as follows:
        // If this test fails, it means you added a new permission to an O365 permission set.
        // Solution: Update permissions in regard to the permission hierarchy below:
        // "O365 Sales Doc, Edit" (part of) "O365 Sales Doc, Post" (part of) "O365 Acc. Receivable"
        VerifyPSPartOfPS(XSALESDOCCREATETxt, XSALESDOCPOSTTxt);
        VerifyPSPartOfPS(XSALESDOCPOSTTxt, XACCOUNTSRECEIVABLETxt);

        // "O365 Purch Doc, Edit" (part of) "O365 Purch Doc, Post" (part of) "O365 Acc. Payable"
        VerifyPSPartOfPS(XPURCHDOCCREATETxt, XPURCHDOCPOSTTxt);
        VerifyPSPartOfPS(XPURCHDOCPOSTTxt, XACCOUNTSPAYABLETxt);

        // "O365 Vendor, Edit", "O365 Customer, Edit" and "O365 Item" (part of) "O365 Setup"
        VerifyPSPartOfPS(XVENDOREDITTxt, XSETUPTxt);
        VerifyPSPartOfPS(XCUSTOMEREDITTxt, XSETUPTxt);
        VerifyPSPartOfPS(XITEMEDITTxt, XSETUPTxt);

        // "O365 Journals, Edit" (part of) "O365 Journals, Post" (part of) (O365 Acc. Receivable and O365 Acc. Payable)
        VerifyPSPartOfPS(XJOURNALSEDITTxt, XJOURNALSPOSTTxt);
        VerifyPSPartOfPS(XJOURNALSPOSTTxt, XACCOUNTSRECEIVABLETxt);
        VerifyPSPartOfPS(XJOURNALSPOSTTxt, XACCOUNTSPAYABLETxt);

        // "O365 Vendor, View" (part of) "O365 Vendor, Edit"
        VerifyPSPartOfPS(XVENDORVIEWTxt, XVENDOREDITTxt);

        // "O365 Customer, View" (part of) "O365 Customer, Edit"
        VerifyPSPartOfPS(XCUSTOMERVIEWTxt, XCUSTOMEREDITTxt);

        // "O365 Fixed Assets, View" (part of) "O365 Fixed Assets, Edit"
        VerifyPSPartOfPS(XFIXEDASSETSVIEWTxt, XFIXEDASSETSEDITTxt);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestIfDeviceISVPlanExists()
    var
        AzureADPlan: Codeunit "Azure AD Plan";
        PlanIds: Codeunit "Plan Ids";
    begin
        Assert.IsTrue(AzureADPlan.DoesPlanExist(PlanIds.GetDeviceISVPlanId()),
            StrSubstNo('Plan with ID %1 cannot be found', PlanIds.GetDeviceISVPlanId()));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure BackupRestorePermissionSetExists()
    var
        PermissionSet: Record "Permission Set";
        Permission: Record Permission;
    begin
        PermissionSet.Get(BackupRestoreDataTok);
        PermissionSet.TestField(Name, BackupRestoreDataDescription);

        Permission.Get(BackupRestoreDataTok, Permission."Object Type"::System, 5410); // Backup permission
        Assert.AreEqual(Permission."Execute Permission", Permission."Execute Permission"::Yes, 'Wrong value for Execute Permission');

        Permission.Get(BackupRestoreDataTok, Permission."Object Type"::System, 5420); // Restore permission
        Assert.AreEqual(Permission."Execute Permission", Permission."Execute Permission"::Yes, 'Wrong value for Execute Permission');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure BackupRestorePermissionSetIsPartOfAdminPlans()
    var
        PermissionSetInPlanBuffer: Record "Permission Set In Plan Buffer";
        PlanConfiguration: Codeunit "Plan Configuration";
        PlanIds: Codeunit "Plan Ids";
        AzureADPlan: Codeunit "Azure AD Plan";
        PlanId: Guid;
    begin
        // [SCENARIO] Delegated admin and internal admin plan configurations should contain the "D365 BACKUP/RESTORE" permission set.
        // All other configurations should not.
        PlanConfiguration.GetDefaultPermissions(PermissionSetInPlanBuffer);

        foreach PlanId in AzureADPlan.GetAllPlanIds() do begin
            PermissionSetInPlanBuffer.SetRange("Plan ID", PlanId);
            PermissionSetInPlanBuffer.SetRange("Role ID", BackupRestoreDataTok);
            if PlanId in [PlanIds.GetDelegatedAdminPlanId(), PlanIds.GetGlobalAdminPlanId(), PlanIds.GetD365AdminPlanId(), PlanIds.GetDelegatedBCAdminPlanId(), PlanIds.GetBCAdminPlanId()] then
                Assert.RecordIsNotEmpty(PermissionSetInPlanBuffer)
            else
                Assert.RecordIsEmpty(PermissionSetInPlanBuffer)
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestAllPlanConfigurationsContainLocal()
    var
        PermissionSetInPlanBuffer: Record "Permission Set In Plan Buffer";
        PermissionSet: Record "Permission Set";
        PlanConfiguration: Codeunit "Plan Configuration";
        PlanIds: Codeunit "Plan Ids";
        AzureADPlan: Codeunit "Azure AD Plan";
        PlanIDsWithoutM365: List of [Guid];
        PlanId: Guid;
    begin
        // [SCENARIO] All plan configurations should contain LOCAL permission set
        // [GIVEN] Local Permissionset exists (in W1 it doesn't)
        PermissionSet.SetRange("Role ID", XLOCALTxt);
        if PermissionSet.IsEmpty() then
            exit;

        // [THEN] All the default configurations except Teams Users should contain LOCAL permission set
        PlanIDsWithoutM365 := AzureADPlan.GetAllPlanIds();
        PlanIDsWithoutM365.Remove(PlanIds.GetMicrosoft365PlanId());

        PlanConfiguration.GetDefaultPermissions(PermissionSetInPlanBuffer);
        foreach PlanId in PlanIDsWithoutM365 do begin
            PermissionSetInPlanBuffer.SetRange("Plan ID", PlanId);
            PermissionSetInPlanBuffer.SetRange("Role ID", XLOCALTxt);
            Assert.IsFalse(PermissionSetInPlanBuffer.IsEmpty(), StrSubstNo(PlanConfigurationMissingLocalErr,
                PlanId, XLOCALTxt));
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestTeamsUsersContainLoginOnly()
    var
        PermissionSetInPlanBuffer: Record "Permission Set In Plan Buffer";
        PermissionSet: Record "Permission Set";
        PlanConfiguration: Codeunit "Plan Configuration";
        PlanIds: Codeunit "Plan Ids";
    begin
        // [SCENARIO] Teams Users plan configuration contains only LOGIN permission set
        // [GIVEN] Login Permissionset exists
        PermissionSet.SetRange("Role ID", LoginTxt);
        if PermissionSet.IsEmpty() then
            exit;

        // [THEN] Teams Users should contains LOGIN permission set
        PlanConfiguration.GetDefaultPermissions(PermissionSetInPlanBuffer);
        PermissionSetInPlanBuffer.SetRange("Plan ID", PlanIds.GetMicrosoft365PlanId());
        Assert.RecordCount(PermissionSetInPlanBuffer, 1);
        PermissionSetInPlanBuffer.FindFirst();
        Assert.AreEqual(LoginTxt, PermissionSetInPlanBuffer."Role ID", TeamsUsersMissingLoginErr);
    end;

    local procedure CopyAllAppTableObjectsToTempBuffer(var TempTableDataAllObj: Record AllObj temporary)
    var
        AllObj: Record AllObj;
        TableMetadata: Record "Table Metadata";
        TablesWithInherentEntitlements: Dictionary of [Integer, Boolean];
    begin
        // Get tables that use inherent entitlements
        TablesWithInherentEntitlements := GetTablesWithInherentEntitlements();

        // Add all tabledata into the TempTableDataAllObj
        AllObj.SetRange("Object Type", AllObj."Object Type"::TableData);
        AllObj.SetFilter("Object ID", '<>%1', 5105); // Skip table 5105 Customer Template
        AllObj.FindSet();
        repeat
            TableMetadata.Get(AllObj."Object ID");

            if (TableMetadata.ObsoleteState <> TableMetadata.ObsoleteState::Removed) // Do not validate removed tables
                    and (not TablesWithInherentEntitlements.ContainsKey(AllObj."Object ID")) // Do not validate tables with inherent permissions
                    and (TableMetadata.TableType <> 6) then begin // Do not Validate temporary tables
                TempTableDataAllObj := AllObj;
                TempTableDataAllObj.Insert();
            end;
        until AllObj.Next() = 0;

        TempTableDataAllObj.SetRange("Object ID", 101000, 130399);
        TempTableDataAllObj.DeleteAll();
        TempTableDataAllObj.SetRange("Object ID", 130500, 199999);
        TempTableDataAllObj.DeleteAll();
        TempTableDataAllObj.Reset();
    end;

    local procedure CopyAllTablePermissionsToTempBuffer(var TempPermission: Record Permission temporary)
    var
        Permission: Record Permission;
        AllObj: Record AllObj;
    begin
        Permission.SetRange("Object Type", Permission."Object Type"::"Table Data");
        Permission.FindSet();
        repeat
            TempPermission := Permission;
            TempPermission.Insert();
        until Permission.Next() = 0;

        // Do not validate system tables that are not visible to the user
        TempPermission.SetRange("Object ID", 2000000000, 2100000000);
        TempPermission.FindSet();
        repeat
            AllObj.SetRange("Object Type", AllObj."Object Type"::TableData);
            AllObj.SetRange("Object ID", TempPermission."Object ID");
            if AllObj.IsEmpty() then
                TempPermission.Delete();
        until TempPermission.Next() = 0;

        TempPermission.Reset();
        TempPermission.SetRange("Role ID", 'SUPER');
        TempPermission.DeleteAll();
        TempPermission.SetRange("Role ID", 'SUPER (DATA)');
        TempPermission.DeleteAll();
        TempPermission.SetRange("Role ID", 'TEST TABLES');
        TempPermission.DeleteAll();
        TempPermission.SetRange("Role ID", 'ENFORCED SET');
        TempPermission.DeleteAll();

        TempPermission.Reset();
    end;

    local procedure VerifyTempPSinPS(var BasePermissions: Record Permission; ContainingPSRoleIDFilter: Code[255])
    var
        AllObj: Record AllObj;
        ContainingPermission: Record Permission;
    begin
        BasePermissions.FindSet();
        repeat
            ContainingPermission.SetFilter("Role ID", ContainingPSRoleIDFilter);
            ContainingPermission.SetRange("Object Type", BasePermissions."Object Type");
            ContainingPermission.SetRange("Object ID", BasePermissions."Object ID");
            ContainingPermission.SetRange("Read Permission",
              GetMinAllowedPermission(BasePermissions."Read Permission"),
              GetMaxAllowedPermission(BasePermissions."Read Permission"));
            ContainingPermission.SetRange("Insert Permission",
              GetMinAllowedPermission(BasePermissions."Insert Permission"),
              GetMaxAllowedPermission(BasePermissions."Insert Permission"));
            ContainingPermission.SetRange("Modify Permission",
              GetMinAllowedPermission(BasePermissions."Modify Permission"),
              GetMaxAllowedPermission(BasePermissions."Modify Permission"));
            ContainingPermission.SetRange("Delete Permission",
              GetMinAllowedPermission(BasePermissions."Delete Permission"),
              GetMaxAllowedPermission(BasePermissions."Delete Permission"));
            ContainingPermission.SetRange("Execute Permission",
              GetMinAllowedPermission(BasePermissions."Execute Permission"),
              GetMaxAllowedPermission(BasePermissions."Execute Permission"));
            if ContainingPermission.IsEmpty() then begin
                AllObj.Get(BasePermissions."Object Type", BasePermissions."Object ID");
                Error(PermissionNotInPSWithSufficientPermissionsErr,
                  BasePermissions."Object Type",
                  AllObj."Object Name",
                  BasePermissions."Object ID",
                  BasePermissions."Role ID",
                  BasePermissions."Read Permission",
                  BasePermissions."Insert Permission",
                  BasePermissions."Modify Permission",
                  BasePermissions."Delete Permission",
                  BasePermissions."Execute Permission",
                  ContainingPSRoleIDFilter);
            end;
        until BasePermissions.Next() = 0;
    end;

    local procedure VerifyPSPartOfPS(BasePermissionSetRoleID: Code[20]; ContainingPermissionSetRoleID: Code[20])
    var
        TempPermission: Record Permission temporary;
    begin
        CopyPSToTemp(TempPermission, BasePermissionSetRoleID);
        VerifyTempPSinPS(TempPermission, ContainingPermissionSetRoleID);
    end;

    local procedure GetMinAllowedPermission(PermissionOption: Option): Integer
    var
        Permission: Record Permission;
    begin
        if PermissionOption = Permission."Read Permission"::Indirect then
            exit(Permission."Read Permission"::Yes);
        exit(PermissionOption)
    end;

    local procedure GetMaxAllowedPermission(PermissionOption: Option): Integer
    var
        Permission: Record Permission;
    begin
        if PermissionOption = Permission."Read Permission"::Yes then
            exit(Permission."Read Permission"::Yes);
        exit(Permission."Read Permission"::Indirect);
    end;

    local procedure CopyPSToTemp(var TempPermission: Record Permission temporary; FromRoleID: Code[20])
    var
        Permission: Record Permission;
    begin
        Permission.SetRange("Role ID", FromRoleID);
        if Permission.FindSet() then
            repeat
                TempPermission := Permission;
                TempPermission.Insert();
            until Permission.Next() = 0;
        TempPermission.Reset();
    end;

    local procedure RemoveNonLocalObjectsFromObjects(var TempLocalTableDataAllObj: Record AllObj temporary)
    begin
        // Remove W1 app range
        TempLocalTableDataAllObj.SetRange("Object ID", 1, 9999);
        TempLocalTableDataAllObj.DeleteAll();

        TempLocalTableDataAllObj.SetFilter("Object ID", '>%1', 99000000);
        TempLocalTableDataAllObj.DeleteAll();

        // Semi automated tests and shipped test tool are excluded
        TempLocalTableDataAllObj.SetRange("Object ID", 130400, 130499);
        TempLocalTableDataAllObj.DeleteAll();

        TempLocalTableDataAllObj.Reset();
    end;

    local procedure GetO365PermissionSets(var O365PermissionSetsList: DotNet GenericList1; IncludeComposedPermissionSets: Boolean)
    var
        PermissionSet: Record "Permission Set";
    begin
        PermissionSet.SetFilter("Role ID", D365PermissionSetPrefixFilterTok);
        PermissionSet.FindSet();
        repeat
            if IncludeComposedPermissionSets or not IsComposedPermissionSet(PermissionSet."Role ID") or
               (PermissionSet."Role ID" = XO365BUSFULLTxt)
            then
                O365PermissionSetsList.Add(PermissionSet."Role ID");
        until PermissionSet.Next() = 0;

        O365PermissionSetsList.Add(XSECURITYTxt);
        O365PermissionSetsList.Add(XLOCALTxt);
    end;

    local procedure GetTablesWithInherentEntitlements() TablesWithInherentEntitlements: Dictionary of [Integer, Boolean]
    begin
        // Only add a table here if all entitlements for the table is given through inherent entitlements and the table does not need to exist in any permission set.
        // This is a workaround pending bug 464349.

        TablesWithInherentEntitlements.Add(150, true); // Signup Context Values
        TablesWithInherentEntitlements.Add(1470, true); // Product Video Buffer
        TablesWithInherentEntitlements.Add(1480, true); // Edit in Excel Settings
        TablesWithInherentEntitlements.Add(2718, true); // Page Summary Settings
        TablesWithInherentEntitlements.Add(4690, true); // Recurrence Schedule
        TablesWithInherentEntitlements.Add(5490, true); // Onboarding Signal 
        TablesWithInherentEntitlements.Add(7775, true); // Copilot Settings
        TablesWithInherentEntitlements.Add(8703, true); // Feature Uptake
        TablesWithInherentEntitlements.Add(9008, true); // User Login
        TablesWithInherentEntitlements.Add(9011, true); // User Environment Login
        TablesWithInherentEntitlements.Add(9222, true); // Application User Settings
        TablesWithInherentEntitlements.Add(9996, true); // Upgrade Tag Backup
        TablesWithInherentEntitlements.Add(9999, true); // Upgrade Tags
    end;

    local procedure IsComposedPermissionSet(RoleID: Code[20]): Boolean
    begin
        exit(RoleID in [XO365FULLTxt, XO365BUSFULLTxt, XO365PREMIUMBUSTxt, D365AccountantsTxt, D365CompanyHubTxt, ReadTok, XTEAMMEMBERTxt, BasicISVTok, D365AutomationTok, D365DIMCORRECTIONTok]);
    end;
}

