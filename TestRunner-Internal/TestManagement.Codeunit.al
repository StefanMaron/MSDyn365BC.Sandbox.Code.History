codeunit 130022 "Test Management"
{
    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        TempCodeCoverage: Record "Code Coverage" temporary;
        Window: Dialog;
        Mode: Option Test,Publish;
        AddingTestCodeunitsMsg: Label 'Adding Test Codeunits @1@@@@@@@', Locked = true;
        SelectTestsToRunQst: Label 'Active &Line,Active &Codeunit,&All', Locked = true;
        SelectTestsToImportQst: Label '&Select Test Codeunits,&All Test Codeunits', Locked = true;
        SelectTestsToImportFromTCMQst: Label '&Select Test Codeunits,&All Test Codeunits,Get Test Codeunits based on Selected &Objects', Locked = true;
        SelectCodeunitsToRunQst: Label ',Active &Codeunit,&All', Locked = true;
        DefaultTxt: Label 'DEFAULT', Locked = true;
        DefaultSuiteTxt: Label 'Default Suite - Autogenerated', Locked = true;
        ObjectNotCompiledErr: Label 'Object not compiled.', Locked = true;
        WindowUpdateDateTime: DateTime;
        NoOfRecords: Integer;
        i: Integer;
        AddingTestsBasedOnChurnMsg: Label 'Adding %1 test codeunits based on churn @1@@@@@@@', Locked = true;
        NoModifiedObjectsFoundMsg: Label 'No modified objects found.', Locked = true;
        SelectFailedTestsToRunQst: Label 'All failed tests,All Codeunits with failed tests';
        NoTestsToRunMsg: Label 'There are no tests to run under the current filters.';
        CustomTestRunnerId: Integer;

    [Scope('OnPrem')]
    procedure SETPUBLISHMODE()
    begin
        Mode := Mode::Publish;
    end;

    [Scope('OnPrem')]
    procedure SETTESTMODE()
    begin
        Mode := Mode::Test;
    end;

    [Scope('OnPrem')]
    procedure ISPUBLISHMODE(): Boolean
    begin
        exit(Mode = Mode::Publish);
    end;

    [Scope('OnPrem')]
    procedure ISTESTMODE(): Boolean
    begin
        exit(Mode = Mode::Test);
    end;

    local procedure DoesTestCodeunitExist(ID: Integer): Boolean
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        AllObjWithCaption.Reset();
        AllObjWithCaption.SetRange("Object ID", ID);
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Codeunit);
        AllObjWithCaption.SetRange("Object Subtype", 'Test');
        exit(not AllObjWithCaption.IsEmpty);
    end;

    [Scope('OnPrem')]
    procedure GetTestCodeunitsSelection(TestSuite: Record "Test Suite")
    var
        TestLine: Record "Test Line";
        AllObjWithCaption: Record AllObjWithCaption;
        TempAllObjWithCaption: Record AllObjWithCaption temporary;
        TestCoverageMap: Record "Test Coverage Map";
        GetTestCodeunitsPage: Page "Get Test Codeunits";
        SelectTestCodeunitsPage: Page "Select Test Codeunits";
        Selection: Integer;
    begin
        if TestCoverageMap.IsEmpty() then
            Selection := StrMenu(SelectTestsToImportQst, 1)
        else
            Selection := StrMenu(SelectTestsToImportFromTCMQst, 1);

        if Selection = 0 then
            exit;

        case Selection of
            1:
                if TestSuite."Show Test Details" then begin
                    GetTestCodeunitsPage.LookupMode := true;
                    GetTestCodeunitsPage.SetTestSuite(TestSuite);
                    if GetTestCodeunitsPage.RunModal() = ACTION::LookupOK then begin
                        GetTestCodeunitsPage.SetSelectionFilter(AllObjWithCaption);
                        AddTestCodeunits(TestSuite, AllObjWithCaption);
                    end
                end else begin
                    SelectTestCodeunitsPage.LookupMode := true;
                    if SelectTestCodeunitsPage.RunModal() = ACTION::LookupOK then begin
                        SelectTestCodeunitsPage.SetSelectionFilter(AllObjWithCaption);
                        AddTestCodeunits(TestSuite, AllObjWithCaption);
                    end;
                end;
            2:
                begin
                    TestLine.SetRange("Test Suite", TestSuite.Name);
                    TestLine.DeleteAll(true);
                    if GetTestCodeunits(TempAllObjWithCaption, false) then
                        RefreshSuite(TestSuite, TempAllObjWithCaption);
                end;
            3:
                GetTestCodeunitsForSelectedObjects(TestSuite.Name);
        end;
    end;

    [Scope('OnPrem')]
    procedure GetTestCodeunits(var ToAllObjWithCaption: Record AllObjWithCaption; OnlyThoseNotInAnySuite: Boolean): Boolean
    var
        FromAllObjWithCaption: Record AllObjWithCaption;
        TestLine: Record "Test Line";
    begin
        FromAllObjWithCaption.SetRange("Object Type", ToAllObjWithCaption."Object Type"::Codeunit);
        FromAllObjWithCaption.SetRange("Object Subtype", 'Test');
        FromAllObjWithCaption.SetFilter("Object ID", '132500..149999');
        if FromAllObjWithCaption.Find('-') then
            repeat
                TestLine.SetRange("Test Codeunit", FromAllObjWithCaption."Object ID");
                if not OnlyThoseNotInAnySuite or not TestLine.FindFirst() then begin
                    ToAllObjWithCaption := FromAllObjWithCaption;
                    ToAllObjWithCaption.Insert();
                end;
            until FromAllObjWithCaption.Next() = 0;

        exit(ToAllObjWithCaption.Find('-'));
    end;

    local procedure GetTestCodeunitsForObjects(var AllObj: Record AllObj; TestSuiteName: Code[10])
    var
        TempMissingCUId: Record "Integer" temporary;
        TempTestCodeunitID: Record "Integer" temporary;
        MissingCodeunitsList: Page "Missing Codeunits List";
        TestLineNo: Integer;
        TestCodeunitsNumber: Integer;
    begin
        AllObj.SetFilter("Object Type", '<>%1', AllObj."Object Type"::TableData);
        if AllObj.FindSet() then begin
            TestCodeunitsNumber := GetTotalTestCodeunitIDs(AllObj, TempTestCodeunitID);
            OpenWindow(StrSubstNo(AddingTestsBasedOnChurnMsg, TestCodeunitsNumber), TestCodeunitsNumber);
            TestLineNo := GetLastTestLineNo(TestSuiteName);
            if TempTestCodeunitID.FindSet() then
                repeat
                    if DoesTestCodeunitExist(TempTestCodeunitID.Number) then begin
                        if not TestLineExists(TestSuiteName, TempTestCodeunitID.Number) then begin
                            TestLineNo := TestLineNo + 10000;
                            AddTestLine(TestSuiteName, TempTestCodeunitID.Number, TestLineNo);
                            UpdateWindow();
                        end
                    end else begin
                        TempMissingCUId.Number := TempTestCodeunitID.Number;
                        TempMissingCUId.Insert();
                    end;
                until TempTestCodeunitID.Next() = 0;
            Window.Close();
        end else
            Message(NoModifiedObjectsFoundMsg);

        if not TempMissingCUId.IsEmpty() then begin
            Commit();
            MissingCodeunitsList.Initialize(TempMissingCUId, TestSuiteName);
            MissingCodeunitsList.RunModal();
        end;
    end;

    local procedure GetTestCodeunitsForSelectedObjects(TestSuiteName: Code[10])
    var
        AllObj: Record AllObj;
        ALTestObjectsToSelect: Page "AL Test Objects To Select";
    begin
        ALTestObjectsToSelect.LookupMode := true;
        ALTestObjectsToSelect.SetTableView(AllObj);
        if ALTestObjectsToSelect.RunModal() = ACTION::LookupOK then begin
            ALTestObjectsToSelect.SetSelectionFilter(AllObj);
            GetTestCodeunitsForObjects(AllObj, TestSuiteName);
        end;
    end;

    local procedure GetTotalTestCodeunitIDs(var AllObj: Record AllObj; var TestCodeunitID: Record "Integer"): Integer
    var
        TestCoverageMap: Record "Test Coverage Map";
    begin
        repeat
            TestCoverageMap.Reset();
            TestCoverageMap.SetRange("Object ID", AllObj."Object ID");
            TestCoverageMap.SetRange("Object Type", AllObj."Object Type");
            if TestCoverageMap.FindSet() then
                repeat
                    if not TestCodeunitID.Get(TestCoverageMap."Test Codeunit ID") then begin
                        TestCodeunitID.Number := TestCoverageMap."Test Codeunit ID";
                        TestCodeunitID.Insert();
                    end;
                until TestCoverageMap.Next() = 0;
        until AllObj.Next() = 0;
        exit(TestCodeunitID.Count);
    end;

    local procedure GetLastTestLineNo(TestSuiteName: Code[10]) LineNo: Integer
    var
        TestLine: Record "Test Line";
    begin
        TestLine.SetRange("Test Suite", TestSuiteName);
        if TestLine.FindLast() then
            LineNo := TestLine."Line No.";
    end;

    [Scope('OnPrem')]
    procedure CreateNewSuite(var NewSuiteName: Code[10])
    var
        TestSuite: Record "Test Suite";
    begin
        NewSuiteName := DefaultTxt;
        TestSuite.Init();
        TestSuite.Validate(Name, NewSuiteName);
        TestSuite.Validate(Description, DefaultSuiteTxt);
        TestSuite.Validate(Export, false);
        TestSuite.Insert(true);
    end;

    local procedure RefreshSuite(TestSuite: Record "Test Suite"; var AllObjWithCaption: Record AllObjWithCaption)
    var
        TestLine: Record "Test Line";
        LineNo: Integer;
    begin
        LineNo := LineNo + 10000;

        TestLine.Init();
        TestLine.Validate("Test Suite", TestSuite.Name);
        TestLine.Validate("Line No.", LineNo);
        TestLine.Validate("Line Type", TestLine."Line Type"::Group);
        TestLine.Validate(Name, DefaultSuiteTxt);
        TestLine.Validate(Run, true);
        TestLine.Insert(true);

        AddTestCodeunits(TestSuite, AllObjWithCaption);
    end;

    [Scope('OnPrem')]
    procedure AddTestCodeunits(TestSuite: Record "Test Suite"; var AllObjWithCaption: Record AllObjWithCaption)
    var
        TestLineNo: Integer;
    begin
        if AllObjWithCaption.Find('-') then begin
            TestLineNo := GetLastTestLineNo(TestSuite.Name);
            OpenWindow(AddingTestCodeunitsMsg, AllObjWithCaption.Count);
            repeat
                TestLineNo := TestLineNo + 10000;
                AddTestLine(TestSuite.Name, AllObjWithCaption."Object ID", TestLineNo);
                UpdateWindow();
            until AllObjWithCaption.Next() = 0;
            Window.Close();
        end;
    end;

    [Scope('OnPrem')]
    procedure AddMissingTestCodeunits(var TestCodeunitIds: Record "Integer"; TestSuiteName: Code[10])
    var
        AllObj: Record AllObj;
        TestLineNo: Integer;
    begin
        TestLineNo := GetLastTestLineNo(TestSuiteName);
        OpenWindow(StrSubstNo(AddingTestsBasedOnChurnMsg, TestCodeunitIds.Count), TestCodeunitIds.Count);

        repeat
            AllObj.SetRange("Object Type", AllObj."Object Type"::Codeunit);
            AllObj.SetRange("Object ID", TestCodeunitIds.Number);
            if AllObj.FindFirst() then begin
                TestLineNo := TestLineNo + 10000;
                AddTestLine(TestSuiteName, AllObj."Object ID", TestLineNo);
                UpdateWindow();
                TestCodeunitIds.Delete();
            end;
        until TestCodeunitIds.Next() = 0;

        Window.Close();
    end;

    local procedure AddTestLine(TestSuiteName: Code[10]; TestCodeunitId: Integer; LineNo: Integer)
    var
        TestLine: Record "Test Line";
        AllObj: Record AllObj;
        CodeunitIsValid: Boolean;
    begin
        if TestLineExists(TestSuiteName, TestCodeunitId) then
            exit;

        TestLine.Init();
        TestLine.Validate("Test Suite", TestSuiteName);
        TestLine.Validate("Line No.", LineNo);
        TestLine.Validate("Line Type", TestLine."Line Type"::Codeunit);
        TestLine.Validate("Test Codeunit", TestCodeunitId);
        TestLine.Validate(Run, true);

        TestLine.Insert(true);

        AllObj.SetRange("Object Type", AllObj."Object Type"::Codeunit);
        AllObj.SetRange("Object ID", TestCodeunitId);
        if not IsNullGuid(AllObj."App Package ID") then
            CodeunitIsValid := true;

        if not CodeunitIsValid then
            CodeunitIsValid := AllObj.FindFirst();

        if CodeunitIsValid then begin
            SETPUBLISHMODE();
            TestLine.SetRecFilter();
            CODEUNIT.Run(CODEUNIT::"Test Runner", TestLine);
        end else begin
            TestLine.Validate(Result, TestLine.Result::Failure);
            TestLine.Validate("First Error", ObjectNotCompiledErr);
            TestLine.Modify(true);
        end;
    end;

    local procedure TestLineExists(TestSuiteName: Code[10]; TestCodeunitId: Integer): Boolean
    var
        TestLine: Record "Test Line";
    begin
        TestLine.SetRange("Test Suite", TestSuiteName);
        TestLine.SetRange("Test Codeunit", TestCodeunitId);
        if TestLine.FindFirst() then
            exit(true);

        exit(false);
    end;

    [Scope('OnPrem')]
    procedure ExtendTestCoverage(TestCodeunitId: Integer)
    var
        CodeCoverage: Record "Code Coverage";
        TestCoverageMap: Record "Test Coverage Map";
    begin
        CodeCoverage.SetRange("Line Type", CodeCoverage."Line Type"::Object);
        if CodeCoverage.FindSet() then
            repeat
                if not TestCoverageMap.Get(TestCodeunitId, CodeCoverage."Object Type", CodeCoverage."Object ID") then begin
                    TestCoverageMap.Init();
                    TestCoverageMap."Test Codeunit ID" := TestCodeunitId;
                    TestCoverageMap."Object Type" := CodeCoverage."Object Type";
                    TestCoverageMap."Object ID" := CodeCoverage."Object ID";
                    TestCoverageMap.Insert();
                end;
            until CodeCoverage.Next() = 0;
    end;

    local procedure GetLineNoFilter(TestLine: Record "Test Line"; Selection: Option ,"Function","Codeunit") LineNoFilter: Text
    var
        NoOfFunctions: Integer;
    begin
        LineNoFilter := '';
        case Selection of
            Selection::"Function":
                begin
                    TestLine.TestField("Line Type", TestLine."Line Type"::"Function");
                    LineNoFilter := Format(TestLine."Line No.");
                    TestLine.Reset();
                    TestLine.SetRange("Test Suite", TestLine."Test Suite");
                    TestLine.SetRange("Test Codeunit", TestLine."Test Codeunit");
                    TestLine.SetFilter("Function", 'OnRun|%1', '');
                    TestLine.FindSet();
                    repeat
                        LineNoFilter := LineNoFilter + '|' + Format(TestLine."Line No.");
                    until TestLine.Next() = 0;
                end;
            Selection::Codeunit:
                LineNoFilter :=
                  StrSubstNo('%1..%2', TestLine.GetMinCodeunitLineNo(), TestLine.GetMaxCodeunitLineNo(NoOfFunctions));
        end;
    end;

    local procedure FilterCALCode(TestCodeunitID: Integer)
    begin
        TempCodeCoverage.Reset();
        TempCodeCoverage.SetRange("Object Type", TempCodeCoverage."Object Type"::Codeunit);
        TempCodeCoverage.SetRange("Object ID", TestCodeunitID);
    end;

    [Scope('OnPrem')]
    procedure IsCALCodeRead(TestCodeunitID: Integer): Boolean
    begin
        FilterCALCode(TestCodeunitID);
        exit(TempCodeCoverage.FindLast() and (TempCodeCoverage."No. of Hits" > 1));
    end;

    [Scope('OnPrem')]
    procedure IsOnRunTriggerRead(TestCodeunitID: Integer): Boolean
    begin
        FilterCALCode(TestCodeunitID);
        exit(not TempCodeCoverage.IsEmpty);
    end;

    [Scope('OnPrem')]
    procedure RemoveCALCode(TestCodeunitID: Integer)
    begin
        FilterCALCode(TestCodeunitID);
        TempCodeCoverage.DeleteAll();
        TempCodeCoverage.Reset();
    end;

    [Scope('OnPrem')]
    procedure ReadCALCode(TestCodeunitID: Integer; OnRunTriggerOnly: Boolean): Boolean
    var
        AppObjectMetadata: Record "Application Object Metadata";
        InStr: InStream;
        Line: Text;
        FunctionKey: Integer;
        NAVAppCode: Boolean;
        IsLineToInsert: Boolean;
        Flag: array[3] of Boolean;
    begin
        FilterCALCode(TestCodeunitID);
        TempCodeCoverage.DeleteAll();
        TempCodeCoverage."Object Type" := TempCodeCoverage."Object Type"::Codeunit;
        TempCodeCoverage."Object ID" := TestCodeunitID;
        TempCodeCoverage."Line No." := 0;
        FunctionKey := 0;

        AppObjectMetadata.SetRange("Object Type", AppObjectMetadata."Object Type"::Codeunit);
        AppObjectMetadata.SetRange("Object ID", TestCodeunitID);
        if AppObjectMetadata.FindFirst() then begin
            NAVAppCode := true;
            AppObjectMetadata.CalcFields("User AL Code");
            AppObjectMetadata."User AL Code".CreateInStream(InStr);
        end else
            exit(false);

        while not InStr.EOS do begin
            InStr.ReadText(Line);
            IsLineToInsert := true;
            if NAVAppCode then
                IsLineToInsert := IsValidALCodeLine(Line, Flag);
            if IsLineToInsert then begin
                TempCodeCoverage.Init();
                TempCodeCoverage."Line Type" := GetCALLineType(Line);
                if TempCodeCoverage."Line Type" in [TempCodeCoverage."Line Type"::"Trigger/Function", 4, 5] then begin
                    TempCodeCoverage."Line No." += 1;
                    TempCodeCoverage.Line := CopyStr(Line, 1, 250);
                    if TempCodeCoverage."Line Type" = TempCodeCoverage."Line Type"::"Trigger/Function" then begin
                        FunctionKey += 1;
                        if OnRunTriggerOnly and (FunctionKey > 1) then
                            exit(true);
                    end;
                    TempCodeCoverage."No. of Hits" := FunctionKey; // mark all lines within function
                    TempCodeCoverage.Insert();
                end;
            end;
        end;
        exit(true);
    end;

    local procedure IsValidALCodeLine(var Line: Text; var Flag: array[3] of Boolean): Boolean
    var
        String: DotNet String;
        LowerString: DotNet String;
        FunctionDefinition: Boolean;
        OnRunDefinition: Boolean;
    begin
        String := Line;
        Line := '';
        String := String.Trim();
        LowerString := String.ToLower();
        FunctionDefinition := LowerString.StartsWith('procedure ') or LowerString.StartsWith('local ');
        if not FunctionDefinition then
            OnRunDefinition := LowerString.StartsWith('trigger ') and LowerString.Contains(' onrun()');
        case true of
            LowerString.StartsWith('//'):
                if not IsGWTTag(LowerString) then
                    exit(false);
            FunctionDefinition:
                begin
                    Flag[3] := false;
                    if Flag[1] then begin
                        Flag[2] := true;
                        Flag[1] := false;
                        String := String.Replace('procedure', '');
                        String := String.Replace(';', '');
                        String := String.Trim();
                    end else begin
                        Flag[2] := false;
                        exit(false);
                    end;
                end;
            LowerString.Equals('[test]'):
                begin
                    Flag[1] := true;
                    exit(false);
                end;
            OnRunDefinition:
                begin
                    Flag[3] := true;
                    String := 'OnRun()';
                end;
            else
                exit(false);
        end;
        Line := String;
        exit(true);
    end;

    local procedure IsGWTTag(LowerString: DotNet String): Boolean
    begin
        exit(
          LowerString.Contains('[feature]') or LowerString.Contains('[scenario') or
          LowerString.Contains('[given]') or LowerString.Contains('[when]') or LowerString.Contains('[then]'));
    end;

    local procedure GetCALLineType(Line: Text): Integer
    begin
        case true of
            not (Line[1] in [' ', '/']):
                exit(TempCodeCoverage."Line Type"::"Trigger/Function");
            Line = '  ':
                exit(TempCodeCoverage."Line Type"::Empty);
            Line = ' ':
                exit(6); // end of function
            StrPos(UpperCase(Line), '// [FEATURE]') <> 0:
                exit(4); // a feature tag line
            StrPos(Line, '// [') <> 0:
                exit(5); // a tag line
        end;
        exit(TempCodeCoverage."Line Type"::Code);
    end;

    [Scope('OnPrem')]
    procedure FindCALCodeLine(TestCodeunitID: Integer; FunctionName: Text; var TagCodeCoverage: Record "Code Coverage" temporary): Boolean
    var
        FunctionKey: Integer;
    begin
        FilterCALCode(TestCodeunitID);
        FunctionKey := GetFunctionKey(FunctionName);
        if FunctionKey > 0 then begin
            TempCodeCoverage.SetRange("No. of Hits", FunctionKey);
            TempCodeCoverage.SetRange("Line Type", 4, 5); // just tag lines
            TagCodeCoverage.Copy(TempCodeCoverage, true);
            exit(true);
        end;
        exit(false);
    end;

    local procedure GetFunctionKey(FunctionName: Text) FunctionKey: Integer
    begin
        TempCodeCoverage.SetRange(Line, FunctionName + '()');
        if TempCodeCoverage.FindFirst() then
            FunctionKey := TempCodeCoverage."No. of Hits"
        else
            FunctionKey := 0;
        TempCodeCoverage.SetRange(Line);
    end;

    local procedure GetLinesFilter(var TestLine: Record "Test Line") LineNoFilter: Text
    var
        Separator: Text[1];
    begin
        TestLine.FindSet();
        repeat
            if StrPos(LineNoFilter, Format(TestLine."Line No.")) = 0 then begin
                LineNoFilter += Separator + Format(TestLine."Line No.");
                Separator := '|';
            end;
        until TestLine.Next() = 0;
    end;

    local procedure GetCodeunitsFilter(var TestLine: Record "Test Line") LineNoFilter: Text
    var
        Separator: Text[1];
    begin
        TestLine.FindSet();
        repeat
            if StrPos(LineNoFilter, Format(TestLine."Test Codeunit")) = 0 then begin
                LineNoFilter += Separator + Format(TestLine."Test Codeunit");
                Separator := '|';
            end;
        until TestLine.Next() = 0;
    end;

    local procedure GetLinesSelection(var TestLine: Record "Test Line"; TestSuite: Code[10]): Boolean
    var
        Selection: Integer;
        LineNoFilter: Text;
        CodeunitNoFilter: Text;
    begin
        Selection := StrMenu(SelectFailedTestsToRunQst, 1);

        if Selection = 0 then
            exit(false);

        TestLine.SetRange(Result, TestLine.Result::Failure);
        TestLine.SetRange("Test Suite", TestSuite);
        if TestLine.IsEmpty() then begin
            Message(NoTestsToRunMsg);
            exit(false);
        end;

        if Selection = 2 then begin
            TestLine.SetRange("Line Type", TestLine."Line Type"::"Function");

            CodeunitNoFilter := GetCodeunitsFilter(TestLine);

            TestLine.Reset();
            TestLine.SetFilter("Test Codeunit", CodeunitNoFilter);
            TestLine.SetRange("Test Suite", TestSuite);
        end;

        LineNoFilter := GetLinesFilter(TestLine);

        TestLine.Reset();
        TestLine.SetRange("Test Suite", TestSuite);
        TestLine.SetFilter("Line No.", LineNoFilter);
        TestLine.FindSet();
        exit(true);
    end;

    [Scope('OnPrem')]
    procedure RunSelected(var CurrTestLine: Record "Test Line")
    var
        TestLine: Record "Test Line";
        CodeunitIsMarked: Boolean;
        LastCodeunitID: Integer;
        LineNoFilter: Text;
        Selection: Option ,"Function","Codeunit";
        Separator: Text[1];
    begin
        TestLine.Copy(CurrTestLine);
        Separator := '';
        LineNoFilter := '';
        TestLine.FindSet();
        repeat
            if TestLine."Line Type" = TestLine."Line Type"::Codeunit then begin
                LineNoFilter := LineNoFilter + Separator + GetLineNoFilter(TestLine, Selection::Codeunit);
                LastCodeunitID := TestLine."Test Codeunit";
                CodeunitIsMarked := true;
            end else
                if LastCodeunitID <> TestLine."Test Codeunit" then begin
                    LastCodeunitID := TestLine."Test Codeunit";
                    LineNoFilter := LineNoFilter + Separator + GetLineNoFilter(TestLine, Selection::"Function");
                    CodeunitIsMarked := false;
                end else
                    if not CodeunitIsMarked then
                        LineNoFilter := LineNoFilter + Separator + Format(TestLine."Line No.");
            Separator := '|';
        until TestLine.Next() = 0;

        TestLine.Reset();
        TestLine.SetRange("Test Suite", CurrTestLine."Test Suite");
        TestLine.SetFilter("Line No.", LineNoFilter);
        RunSuite(TestLine, true);
    end;

    [Scope('OnPrem')]
    procedure RunFailed(var CurrTestLine: Record "Test Line")
    begin
        if GetLinesSelection(CurrTestLine, CurrTestLine."Test Suite") then
            RunSuite(CurrTestLine, true);
    end;

    [Scope('OnPrem')]
    procedure RunSuiteYesNo(var CurrTestLine: Record "Test Line")
    var
        TestLine: Record "Test Line";
        Selection: Option ,"Function","Codeunit";
        LineNoFilter: Text;
    begin
        TestLine.Copy(CurrTestLine);
        if TestLine."Line Type" = TestLine."Line Type"::Codeunit then
            Selection := StrMenu(SelectCodeunitsToRunQst, 2)
        else
            Selection := StrMenu(SelectTestsToRunQst, 1);

        if Selection = 0 then
            exit;

        LineNoFilter := GetLineNoFilter(TestLine, Selection);
        if LineNoFilter <> '' then
            TestLine.SetFilter("Line No.", LineNoFilter);
        RunSuite(TestLine, true);
    end;

    [Scope('OnPrem')]
    procedure RunSuite(var TestLine: Record "Test Line"; TestMode: Boolean)
    var
        TestLine2: Record "Test Line";
        CurrentTestRunnerId: Integer;
    begin
        CurrentTestRunnerId := CODEUNIT::"Test Runner";
        if CustomTestRunnerId <> 0 then
            CurrentTestRunnerId := CustomTestRunnerId;

        if TestMode then begin
            SETTESTMODE();
            CODEUNIT.Run(CurrentTestRunnerId, TestLine);
        end else begin
            SETPUBLISHMODE();
            TestLine.TestField("Test Codeunit");
            TestLine2.SetRange("Test Suite", TestLine."Test Suite");
            TestLine2.SetRange("Test Codeunit", TestLine."Test Codeunit");
            TestLine2.SetRange("Function", '');
            if TestLine2.FindFirst() then
                TestLine2.DeleteChildren();

            CODEUNIT.Run(CurrentTestRunnerId, TestLine2);
        end;
    end;

    local procedure OpenWindow(DisplayText: Text; NoOfRecords2: Integer)
    begin
        i := 0;
        NoOfRecords := NoOfRecords2;
        WindowUpdateDateTime := CurrentDateTime;
        Window.Open(DisplayText);
    end;

    local procedure UpdateWindow()
    begin
        i := i + 1;
        if CurrentDateTime - WindowUpdateDateTime >= 1000 then begin
            WindowUpdateDateTime := CurrentDateTime;
            Window.Update(1, Round(i / NoOfRecords * 10000, 1));
        end;
    end;

    [Scope('OnPrem')]
    procedure SetCustomTestRunner(NewCustomTestRunnerId: Integer)
    begin
        CustomTestRunnerId := NewCustomTestRunnerId;
    end;
}

