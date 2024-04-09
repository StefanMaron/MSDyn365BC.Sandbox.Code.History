codeunit 130020 "Test Runner"
{
    Subtype = TestRunner;
    TableNo = "Test Line";
    TestIsolation = Codeunit;

    trigger OnRun()
    begin
        TestLine.Copy(Rec);

        if TestSuite.Get("Test Suite") and TestSuite."Re-run Failing Codeunits" then begin
            BackupMgt.SetEnabled(true);
            BackupMgt.DefaultFixture();
            BackupMgt.SetEnabled(false);
        end;

        RunTests();
    end;

    var
        TestSuite: Record "Test Suite";
        TestLine: Record "Test Line";
        TestLineFunction: Record "Test Line";
        TestMgt: Codeunit "Test Management";
        BackupMgt: Codeunit "Backup Management";
        LibraryRandom: Codeunit "Library - Random";
        PermissionTestCatalog: Codeunit "Permission Test Catalog";
        Window: Dialog;
        MaxLineNo: Integer;
        MinLineNo: Integer;
        "Filter": Text;
        Text000: Label 'Executing Tests...\';
        Text001: Label 'Test Suite    #1###################\';
        Text003: Label 'Test Codeunit #2################### @3@@@@@@@@@@@@@\';
        Text004: Label 'Test Function #4################### @5@@@@@@@@@@@@@\';
        Text005: Label 'No. of Results with:\';
        WindowUpdateDateTime: DateTime;
        WindowIsOpen: Boolean;
        WindowTestSuite: Code[10];
        WindowTestGroup: Text[128];
        WindowTestCodeunit: Text[30];
        WindowTestFunction: Text[128];
        WindowTestSuccess: Integer;
        WindowTestFailure: Integer;
        WindowTestSkip: Integer;
        Text006: Label '    Success   #6######\';
        Text007: Label '    Failure   #7######\';
        Text008: Label '    Skip      #8######\';
        WindowNoOfTestCodeunitTotal: Integer;
        WindowNoOfFunctionTotal: Integer;
        WindowNoOfTestCodeunit: Integer;
        WindowNoOfFunction: Integer;

    local procedure RunTests()
    var
        ChangelistCode: Record "Changelist Code";
        CodeCoverageMgt: Codeunit "Code Coverage Mgt.";
        TestProxy: Codeunit "Test Proxy";
        AzureKeyVaultTestLibrary: Codeunit "Azure Key Vault Test Library";
    begin
        with TestLine do begin
            OpenWindow();
            ModifyAll(Result, Result::" ");
            ModifyAll("First Error", '');
            Commit();
            Filter := GetView();
            WindowNoOfTestCodeunitTotal := CountTestCodeunitsToRun(TestLine);
            if not (ChangelistCode.IsEmpty() or UpdateTCM()) then
                CodeCoverageMgt.Start(true);

            TestProxy.Initialize();

            if Find('-') then
                repeat
                    if "Line Type" = "Line Type"::Codeunit then begin
                        if UpdateTCM() then
                            CodeCoverageMgt.Start(true);

                        MinLineNo := "Line No.";
                        MaxLineNo := GetMaxCodeunitLineNo(WindowNoOfFunctionTotal);
                        if Run then
                            WindowNoOfTestCodeunit += 1;
                        WindowNoOfFunction := 0;

                        if TestMgt.ISPUBLISHMODE() then
                            DeleteChildren();

                        AzureKeyVaultTestLibrary.ClearSecrets(); // Cleanup key vault cache
                        if not Codeunit.Run("Test Codeunit") and
                           TestMgt.ISTESTMODE() and
                           TestSuite."Re-run Failing Codeunits"
                        then begin
                            BackupMgt.SetEnabled(true);
                            Codeunit.Run("Test Codeunit");
                            BackupMgt.SetEnabled(false);
                        end;

                        if UpdateTCM() then begin
                            CodeCoverageMgt.Stop();
                            TestMgt.ExtendTestCoverage("Test Codeunit");
                        end;
                    end;
                until Next() = 0;

            if not (ChangelistCode.IsEmpty() or UpdateTCM()) then begin
                CodeCoverageMgt.Stop();
                Codeunit.Run(Codeunit::"Calculate Changelist Coverage");
            end;

            CloseWindow();
        end;
    end;

    [Scope('OnPrem')]
    procedure RunTestsOnLines(var TestLineNew: Record "Test Line")
    begin
        TestLine.Copy(TestLineNew);

        RunTests();

        TestLineNew.Copy(TestLine);
    end;

    procedure HandleOnOnBeforeTestRun(CodeunitID: Integer; CodeunitName: Text; FunctionName: Text; FunctionTestPermissions: TestPermissions): Boolean
    var
        TestProxy: Codeunit "Test Proxy";
        SnapTestRunner: Codeunit "Snap Test Runner";
    begin
        UpDateWindow(
          TestLine."Test Suite", TestLine.Name, CodeunitName, FunctionName,
          WindowTestSuccess, WindowTestFailure, WindowTestSkip,
          WindowNoOfTestCodeunitTotal, WindowNoOfFunctionTotal,
          WindowNoOfTestCodeunit, WindowNoOfFunction);

        UpdateCodeunit(false, false);

        if FunctionName = '' then begin
            TestLine.Result := TestLine.Result::" ";
            TestLine."Start Time" := CurrentDateTime;
            exit(true);
        end;

        if TestMgt.ISPUBLISHMODE() then
            AddTestMethod(FunctionName)
        else begin
            if not TryFindTestFunctionInGroup(FunctionName) then
                exit(FunctionName = 'OnRun');

            LibraryRandom.SetSeed(1);
            ApplicationArea('');
            SnapTestRunner.BindStopSystemTableChanges();

            UpdateTestFunction(false, false);
            if not TestLineFunction.Run or not TestLine.Run then
                exit(false);

            TestProxy.InvokeOnBeforeTestFunctionRun(CodeunitID, CodeunitName, FunctionName, FunctionTestPermissions);

            Clear(PermissionTestCatalog);
            // todo: move to subscribers
            if FunctionName <> 'OnRun' then
                PermissionTestCatalog.InitializePermissionSetForTest(FunctionTestPermissions);

            UpDateWindow(
              TestLine."Test Suite", TestLine.Name, CodeunitName, FunctionName,
              WindowTestSuccess, WindowTestFailure, WindowTestSkip,
              WindowNoOfTestCodeunitTotal, WindowNoOfFunctionTotal,
              WindowNoOfTestCodeunit, WindowNoOfFunction + 1);
        end;

        if FunctionName = 'OnRun' then
            exit(true);

        exit(TestMgt.ISTESTMODE());
    end;

    trigger OnBeforeTestRun(CodeunitID: Integer; CodeunitName: Text; FunctionName: Text; FunctionTestPermissions: TestPermissions): Boolean
    begin
        exit(HandleOnOnBeforeTestRun(CodeunitID, CodeunitName, FunctionName, FunctionTestPermissions));
    end;

    procedure HandleOnAfterTestRun(CodeunitID: Integer; CodeunitName: Text; FunctionName: Text; FunctionTestPermissions: TestPermissions; IsSuccess: Boolean)
    var
        TestProxy: Codeunit "Test Proxy";
        LibraryNotificationMgt: Codeunit "Library - Notification Mgt.";
        PermissionErrors: Text;
    begin
        if (FunctionName <> '') and (FunctionName <> 'OnRun') then begin
            TestProxy.InvokeOnAfterTestFunctionRun(CodeunitID, CodeunitName, FunctionName, FunctionTestPermissions, IsSuccess);

            // todo: move to subscribers
            PermissionErrors := PermissionTestCatalog.GetPermissionErrors(FunctionTestPermissions);
            if IsSuccess and (PermissionErrors <> '') then begin // Only show permission errors once everything else succeeds
                asserterror Error(PermissionErrors);
                IsSuccess := false;
            end;

            LibraryNotificationMgt.ClearTemporaryNotificationContext();
            if IsSuccess then
                UpDateWindow(
                  WindowTestSuite, WindowTestGroup, WindowTestCodeunit, WindowTestFunction,
                  WindowTestSuccess + 1, WindowTestFailure, WindowTestSkip,
                  WindowNoOfTestCodeunitTotal, WindowNoOfFunctionTotal,
                  WindowNoOfTestCodeunit, WindowNoOfFunction)
            else
                UpDateWindow(
                  WindowTestSuite, WindowTestGroup, WindowTestCodeunit, WindowTestFunction,
                  WindowTestSuccess, WindowTestFailure + 1, WindowTestSkip,
                  WindowNoOfTestCodeunitTotal, WindowNoOfFunctionTotal,
                  WindowNoOfTestCodeunit, WindowNoOfFunction);
        end;
        TestLine.Find();
        UpdateCodeunit(true, IsSuccess);

        if FunctionName = '' then
            exit;

        UpdateTestFunction(true, IsSuccess);

        Commit();
        ApplicationArea('');
        ClearLastError();
    end;

    trigger OnAfterTestRun(CodeunitID: Integer; CodeunitName: Text; FunctionName: Text; FunctionTestPermissions: TestPermissions; IsSuccess: Boolean)
    begin
        HandleOnAfterTestRun(CodeunitID, CodeunitName, FunctionName, FunctionTestPermissions, IsSuccess);
    end;

    [Scope('OnPrem')]
    procedure AddTestMethod(FunctionName: Text[128]): Boolean
    var
        NoOfSteps: Integer;
    begin
        with TestLineFunction do begin
            TestLineFunction := TestLine;
            "Line No." := MaxLineNo + 1;
            "Line Type" := "Line Type"::"Function";
            Validate("Function", FunctionName);
            Run := TestLine.Run;
            "Start Time" := CurrentDateTime;
            "Finish Time" := CurrentDateTime;
            if TestSuite."Show Test Details" then
                NoOfSteps := AddTestSteps();
            if NoOfSteps >= 0 then
                Insert(true);
        end;
        MaxLineNo := MaxLineNo + NoOfSteps + 1;
        exit(NoOfSteps >= 0);
    end;

    [Scope('OnPrem')]
    procedure UpdateCodeunit(IsOnAfterTestRun: Boolean; IsSuccessOnAfterTestRun: Boolean)
    begin
        with TestLine do begin
            if not IsOnAfterTestRun then begin
                if TestMgt.ISTESTMODE() and (Result = Result::" ") then
                    Result := Result::Skipped;
            end else
                if TestMgt.ISPUBLISHMODE() and IsSuccessOnAfterTestRun then
                    Result := Result::" "
                else
                    if Result <> Result::Failure then begin
                        if not IsSuccessOnAfterTestRun then begin
                            "First Error" := CopyStr(GetLastErrorText, 1, MaxStrLen("First Error"));
                            Result := Result::Failure
                        end else
                            Result := Result::Success;
                    end;
            "Finish Time" := CurrentDateTime;
            Modify();
        end;
    end;

    [Scope('OnPrem')]
    procedure UpdateTestFunction(IsOnAfterTestRun: Boolean; IsSuccessOnAfterTestRun: Boolean)
    begin
        with TestLineFunction do begin
            if not Find() then
                exit;

            if not IsOnAfterTestRun then begin
                "Start Time" := CurrentDateTime;
                Result := Result::Skipped;
            end else begin
                if not IsSuccessOnAfterTestRun then begin
                    "First Error" := CopyStr(GetLastErrorText, 1, MaxStrLen("First Error"));
                    Result := Result::Failure
                end else
                    Result := TestLine.Result::Success;
            end;

            "Finish Time" := CurrentDateTime;
            Modify();
        end;
    end;

    [Scope('OnPrem')]
    procedure TryFindTestFunctionInGroup(FunctionName: Text[128]): Boolean
    begin
        with TestLineFunction do begin
            Reset();
            SetView(Filter);
            SetRange("Test Suite", TestLine."Test Suite");
            SetRange("Test Codeunit", TestLine."Test Codeunit");
            SetRange("Function", FunctionName);
            if Find('-') then
                repeat
                    if "Line No." in [MinLineNo .. MaxLineNo] then
                        exit(true);
                until Next() = 0;
            exit(false);
        end;
    end;

    [Scope('OnPrem')]
    procedure CountTestCodeunitsToRun(var TestLine: Record "Test Line") NoOfTestCodeunits: Integer
    begin
        if not TestMgt.ISTESTMODE() then
            exit;

        with TestLine do
            if Find('-') then
                repeat
                    if ("Line Type" = "Line Type"::Codeunit) and Run then
                        NoOfTestCodeunits += 1;
                until Next() = 0;
    end;

    [Scope('OnPrem')]
    procedure UpdateTCM(): Boolean
    var
        TestCoverageMap: Record "Test Coverage Map";
    begin
        exit(TestMgt.ISTESTMODE() and not TestCoverageMap.IsEmpty())
    end;

    local procedure OpenWindow()
    begin
        if not TestMgt.ISTESTMODE() then
            exit;

        Window.Open(
          Text000 +
          Text001 +
          Text003 +
          Text004 +
          Text005 +
          Text006 +
          Text007 +
          Text008);
        WindowIsOpen := true;
    end;

    local procedure UpDateWindow(NewWindowTestSuite: Code[10]; NewWindowTestGroup: Text[128]; NewWindowTestCodeunit: Text[30]; NewWindowTestFunction: Text[128]; NewWindowTestSuccess: Integer; NewWindowTestFailure: Integer; NewWindowTestSkip: Integer; NewWindowNoOfTestCodeunitTotal: Integer; NewWindowNoOfFunctionTotal: Integer; NewWindowNoOfTestCodeunit: Integer; NewWindowNoOfFunction: Integer)
    begin
        if not TestMgt.ISTESTMODE() then
            exit;

        WindowTestSuite := NewWindowTestSuite;
        WindowTestGroup := NewWindowTestGroup;
        WindowTestCodeunit := NewWindowTestCodeunit;
        WindowTestFunction := NewWindowTestFunction;
        WindowTestSuccess := NewWindowTestSuccess;
        WindowTestFailure := NewWindowTestFailure;
        WindowTestSkip := NewWindowTestSkip;

        WindowNoOfTestCodeunitTotal := NewWindowNoOfTestCodeunitTotal;
        WindowNoOfFunctionTotal := NewWindowNoOfFunctionTotal;
        WindowNoOfTestCodeunit := NewWindowNoOfTestCodeunit;
        WindowNoOfFunction := NewWindowNoOfFunction;

        if IsTimeForUpdate() then begin
            if not WindowIsOpen then
                OpenWindow();
            Window.Update(1, WindowTestSuite);
            Window.Update(2, WindowTestCodeunit);
            Window.Update(4, WindowTestFunction);
            Window.Update(6, WindowTestSuccess);
            Window.Update(7, WindowTestFailure);
            Window.Update(8, WindowTestSkip);

            if NewWindowNoOfTestCodeunitTotal <> 0 then
                Window.Update(3, Round(NewWindowNoOfTestCodeunit / NewWindowNoOfTestCodeunitTotal * 10000, 1));
            if NewWindowNoOfFunctionTotal <> 0 then
                Window.Update(5, Round(NewWindowNoOfFunction / NewWindowNoOfFunctionTotal * 10000, 1));
        end;
    end;

    local procedure CloseWindow()
    begin
        if not TestMgt.ISTESTMODE() then
            exit;

        if WindowIsOpen then begin
            Window.Close();
            WindowIsOpen := false;
        end;
    end;

    local procedure IsTimeForUpdate(): Boolean
    begin
        if true in [WindowUpdateDateTime = 0DT, CurrentDateTime - WindowUpdateDateTime >= 1000] then begin
            WindowUpdateDateTime := CurrentDateTime;
            exit(true);
        end;
        exit(false);
    end;
}

