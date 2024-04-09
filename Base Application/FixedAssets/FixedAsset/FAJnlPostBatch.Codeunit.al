namespace Microsoft.FixedAssets.Posting;

using Microsoft.Finance.Analysis;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Preview;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Journal;
using Microsoft.FixedAssets.Ledger;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.NoSeries;
using Microsoft.Foundation.Period;

codeunit 5633 "FA Jnl.-Post Batch"
{
    Permissions = TableData "FA Journal Batch" = rimd;
    TableNo = "FA Journal Line";

    trigger OnRun()
    begin
        FAJnlLine.Copy(Rec);
        Code();
        Rec := FAJnlLine;
    end;

    var
        FAJnlLine: Record "FA Journal Line";
        FAJnlLine2: Record "FA Journal Line";
        FAJnlLine3: Record "FA Journal Line";
        FAJnlTemplate: Record "FA Journal Template";
        FAJnlBatch: Record "FA Journal Batch";
        FAReg: Record "FA Register";
        FALedgEntry: Record "FA Ledger Entry";
        FAJnlSetup: Record "FA Journal Setup";
        FAJnlCheckLine: Codeunit "FA Jnl.-Check Line";
        FAJnlPostLine: Codeunit "FA Jnl.-Post Line";
        NoSeriesBatch: Codeunit "No. Series - Batch";
        Window: Dialog;
        LineCount: Integer;
        StartLineNo: Integer;
        NoOfRecords: Integer;
        FARegNo: Integer;
        LastDocNo: Code[20];
        LastDocNo2: Code[20];
        LastPostedDocNo: Code[20];
        PreviewMode: Boolean;
        SuppressCommit: Boolean;
        CompressDepr: array[2] of Record "Compress Depreciation" temporary;
        Text12100: Label '%1 compressed entries';
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        Text001: Label 'Journal Batch Name    #1##########\\';
        Text002: Label 'Checking lines        #2######\';
        Text003: Label 'Posting lines         #3###### @4@@@@@@@@@@@@@\';
        Text004: Label 'Updating lines        #5###### @6@@@@@@@@@@@@@';
        Text005: Label 'Posting lines         #3###### @4@@@@@@@@@@@@@';

    local procedure "Code"()
    var
        UpdateAnalysisView: Codeunit "Update Analysis View";
        GenJnlPostPreview: Codeunit "Gen. Jnl.-Post Preview";
        IsHandled: Boolean;
    begin
        FAJnlLine.SetRange("Journal Template Name", FAJnlLine."Journal Template Name");
        FAJnlLine.SetRange("Journal Batch Name", FAJnlLine."Journal Batch Name");
        OnCodeOnBeforeLockTable(FAJnlLine);
        FAJnlLine.LockTable();

        OnCodeOnCheckSuppressCommit(FAJnlLine, SuppressCommit);

        FAJnlTemplate.Get(FAJnlLine."Journal Template Name");
        FAJnlBatch.Get(FAJnlLine."Journal Template Name", FAJnlLine."Journal Batch Name");
        OnCodeOnAfterLockTable(FAJnlBatch);

        if FAJnlTemplate.Recurring then begin
            FAJnlLine.SetRange("FA Posting Date", 0D, WorkDate());
            FAJnlLine.SetFilter("Expiration Date", '%1 | %2..', 0D, WorkDate());
        end;

        if not FAJnlLine.Find('=><') then begin
            if PreviewMode then
                GenJnlPostPreview.ThrowError();
            FAJnlLine."Line No." := 0;
            if not SuppressCommit then
                Commit();
            exit;
        end;

        if GuiAllowed() then begin
            IsHandled := false;
            OnCodeOnBeforeWindowOpen(IsHandled);
            if not IsHandled then begin
                if FAJnlTemplate.Recurring then
                    Window.Open(
                      Text001 +
                      Text002 +
                      Text003 +
                      Text004)
                else
                    Window.Open(
                      Text001 +
                      Text002 +
                      Text005);
                Window.Update(1, FAJnlLine."Journal Batch Name");
            end;
        end;
        Clear(CompressDepr);
        CompressDepr[1].DeleteAll();
        // Check lines
        LineCount := 0;
        StartLineNo := FAJnlLine."Line No.";
        repeat
            LineCount := LineCount + 1;
            if GuiAllowed() then begin
                IsHandled := false;
                OnCodeOnBeforeWindowUpdate(IsHandled);
                if not IsHandled then
                    Window.Update(2, LineCount);
            end;
            CheckRecurringLine(FAJnlLine);
            FAJnlCheckLine.CheckFAJnlLine(FAJnlLine);
            if FAJnlLine.Next() = 0 then
                FAJnlLine.Find('-');
        until FAJnlLine."Line No." = StartLineNo;
        NoOfRecords := LineCount;

        FALedgEntry.LockTable();
        if FALedgEntry.FindLast() then;
        FAReg.LockTable();
        if FAReg.FindLast() then
            FARegNo := FAReg."No." + 1
        else
            FARegNo := 1;
        // Post lines
        PostLines();
        OnCodeOnAfterPostLines(FAJnlLine);

        if FAReg.FindLast() then;
        if FAReg."No." <> FARegNo then
            FARegNo := 0;

        FAJnlLine.Init();
        FAJnlLine."Line No." := FARegNo;
        // Update/delete lines
        IsHandled := false;
        OnCodeOnBeforeUpdateDeleteLines(FAJnlLine, IsHandled);
        if not IsHandled then
            if FARegNo <> 0 then
                if FAJnlTemplate.Recurring then begin
                    LineCount := 0;
                    FAJnlLine2.CopyFilters(FAJnlLine);
                    FAJnlLine2.Find('-');
                    repeat
                        LineCount := LineCount + 1;
                        if GuiAllowed() then begin
                            IsHandled := false;
                            OnCodeOnBeforeWindowUpdate(IsHandled);
                            if not IsHandled then begin
                                Window.Update(5, LineCount);
                                Window.Update(6, Round(LineCount / NoOfRecords * 10000, 1));
                            end;
                        end;
                        if FAJnlLine2."FA Posting Date" <> 0D then
                            FAJnlLine2.Validate("FA Posting Date", CalcDate(FAJnlLine2."Recurring Frequency", FAJnlLine2."FA Posting Date"));
                        if FAJnlLine2."Recurring Method" <> FAJnlLine2."Recurring Method"::"F Fixed" then
                            ZeroAmounts(FAJnlLine2);
                        FAJnlLine2.Modify();
                    until FAJnlLine2.Next() = 0;
                end else begin
                    FAJnlLine2.CopyFilters(FAJnlLine);
                    FAJnlLine2.SetFilter("FA No.", '<>%1', '');
                    if FAJnlLine2.Find('+') then;
                    // Remember the last line
                    FAJnlLine3.Copy(FAJnlLine);
                    OnCodeOnBeforeFAJnlLine3DeleteAll(FAJnlLine3, FAJnlLine);
                    FAJnlLine3.DeleteAll();
                    FAJnlLine3.Reset();
                    FAJnlLine3.SetRange("Journal Template Name", FAJnlLine."Journal Template Name");
                    FAJnlLine3.SetRange("Journal Batch Name", FAJnlLine."Journal Batch Name");
                    if FAJnlTemplate."Increment Batch Name" then
                        if not FAJnlLine3.FindLast() then
                            if IncStr(FAJnlLine."Journal Batch Name") <> '' then begin
                                FAJnlBatch.Get(FAJnlLine."Journal Template Name", FAJnlLine."Journal Batch Name");
                                FAJnlBatch.Delete();
                                FAJnlSetup.IncFAJnlBatchName(FAJnlBatch);
                                FAJnlBatch.Name := IncStr(FAJnlLine."Journal Batch Name");
                                if FAJnlBatch.Insert() then;
                                FAJnlLine."Journal Batch Name" := FAJnlBatch.Name;
                            end;

                    CreateNewFAJnlLine();
                end;
        if FAJnlBatch."No. Series" <> '' then
                NoSeriesBatch.SaveState();

        OnBeforeCommit(FARegNo);

        if PreviewMode then
            GenJnlPostPreview.ThrowError();

        OnRunOnBeforeCommit(FAJnlLine, SuppressCommit);
        if not SuppressCommit then
            Commit();
        Clear(FAJnlCheckLine);
        Clear(FAJnlPostLine);

        IsHandled := false;
        OnRunOnBeforeUpdateAnalysisViewUpdateAll(FAJnlLine, SuppressCommit, IsHandled);
        if not IsHandled then
            UpdateAnalysisView.UpdateAll(0, true);
        if not SuppressCommit then
            Commit();
    end;

    local procedure CreateNewFAJnlLine()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreateNewFAJnlLine(FAJnlLine, FAJnlLine2, FAJnlLine3, IsHandled);
        if IsHandled then
            exit;

        FAJnlLine3.SetRange("Journal Batch Name", FAJnlLine."Journal Batch Name");
        if (FAJnlBatch."No. Series" = '') and not FAJnlLine3.FindLast() then begin
            FAJnlLine3.Init();
            FAJnlLine3."Journal Template Name" := FAJnlLine."Journal Template Name";
            FAJnlLine3."Journal Batch Name" := FAJnlLine."Journal Batch Name";
            FAJnlLine3."Line No." := 10000;
            FAJnlLine3.Insert();
            FAJnlLine3.SetUpNewLine(FAJnlLine2);
            FAJnlLine3.Modify();
        end;
    end;

    local procedure CheckRecurringLine(var FAJnlLine2: Record "FA Journal Line")
    var
        DummyDateFormula: DateFormula;
    begin
        if FAJnlLine2."FA No." <> '' then
            if FAJnlTemplate.Recurring then begin
                FAJnlLine2.TestField("Recurring Method");
                FAJnlLine2.TestField("Recurring Frequency");
                if FAJnlLine2."Recurring Method" = FAJnlLine2."Recurring Method"::"V Variable" then
                    FAJnlLine2.TestField(Amount);
            end else begin
                FAJnlLine2.TestField("Recurring Method", 0);
                FAJnlLine2.TestField("Recurring Frequency", DummyDateFormula);
            end;
    end;

    local procedure MakeRecurringTexts(var FAJnlLine2: Record "FA Journal Line")
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        if (FAJnlLine2."FA No." <> '') and (FAJnlLine2."Recurring Method" <> 0) then
            AccountingPeriod.MakeRecurringTexts(FAJnlLine2."FA Posting Date", FAJnlLine2."Document No.", FAJnlLine2.Description);
    end;

    local procedure ZeroAmounts(var FAJnlLine: Record "FA Journal Line")
    begin
        FAJnlLine.Amount := 0;
        FAJnlLine."Debit Amount" := 0;
        FAJnlLine."Credit Amount" := 0;
        FAJnlLine."Salvage Value" := 0;
    end;

    [Scope('OnPrem')]
    procedure CreateCompressTable(FAJnlLine: Record "FA Journal Line")
    var
        FA: Record "Fixed Asset";
        DeprBook: Record "Depreciation Book";
        FADeprBook: Record "FA Depreciation Book";
    begin
        if (FAJnlLine."FA Posting Type" <> FAJnlLine."FA Posting Type"::Depreciation) and
            (FAJnlLine."FA Posting Type" <> FAJnlLine."FA Posting Type"::"Custom 1") and
            (FAJnlLine."FA Posting Type" <> FAJnlLine."FA Posting Type"::"Custom 2")
        then
            exit;
        if FAJnlLine."FA No." = '' then
            exit;
        DeprBook.Get(FAJnlLine."Depreciation Book Code");
        if not DeprBook."Compress Depreciation" then
            exit;

        FA.Get(FAJnlLine."FA No.");
        if FA."Budgeted Asset" then
            exit;
        FAJnlLine.TestField("Depr. until FA Posting Date", false);
        FAJnlLine.TestField("Depr. Acquisition Cost", false);

        if FAJnlLine."Posting Date" = 0D then
            FAJnlLine."Posting Date" := FAJnlLine."FA Posting Date";

        if FAJnlLine."FA Posting Group" = '' then begin
            FADeprBook.Get(FAJnlLine."FA No.", FAJnlLine."Depreciation Book Code");
            FAJnlLine."FA Posting Group" := FADeprBook."FA Posting Group";
            FADeprBook.TestField("FA Posting Group");
        end;
        CompressDepr[1]."FA Posting Type" := FAJnlLine."FA Posting Type";
        CompressDepr[1]."FA Posting Group" := FAJnlLine."FA Posting Group";
        CompressDepr[1]."Depreciation Book Code" := FAJnlLine."Depreciation Book Code";
        CompressDepr[1]."Document No." := FAJnlLine."Document No.";
        CompressDepr[1]."Reason Code" := FAJnlLine."Reason Code";
        CompressDepr[1]."Posting Date" := FAJnlLine."Posting Date";
        CompressDepr[1]."Line No." := FAJnlLine."Line No.";
        CompressDepr[1].Amount := FAJnlLine.Amount;
        CompressDepr[1]."Global Dimension 1 Code" := FAJnlLine."Shortcut Dimension 1 Code";
        CompressDepr[1]."Global Dimension 2 Code" := FAJnlLine."Shortcut Dimension 2 Code";
        CompressDepr[1]."Dimension Set ID" := FAJnlLine."Dimension Set ID";

        CompressDepr[1].SetRange("FA Posting Type", FAJnlLine."FA Posting Type");
        CompressDepr[1].SetRange("FA Posting Group", FAJnlLine."FA Posting Group");
        CompressDepr[1].SetRange("Depreciation Book Code", FAJnlLine."Depreciation Book Code");
        CompressDepr[1].SetRange("Document No.", FAJnlLine."Document No.");
        CompressDepr[1].SetRange("Reason Code", FAJnlLine."Reason Code");
        CompressDepr[1].SetRange("Posting Date", FAJnlLine."Posting Date");
        OnCreateCompressTableOnAfterCompressDeprSetFilters(CompressDepr, FAJnlLine, FA, DeprBook, FADeprBook);

        CompressDepr[2].Copy(CompressDepr[1]);
        if not CompressDepr[2].Find('-') then
            CompressDepr[1].Insert()
        else begin
            if CompressDepr[2].Find('-') then
                repeat
                    if FAJnlLine."Dimension Set ID" = CompressDepr[2]."Dimension Set ID" then begin
                        CompressDepr[2].Amount := CompressDepr[2].Amount + CompressDepr[1].Amount;
                        CompressDepr[2].Modify();
                        exit;
                    end;
                until (CompressDepr[2].Next() = 0);
            CompressDepr[1].Insert();
        end;
    end;

    [Scope('OnPrem')]
    procedure PostCompressTable(FAJnlLine: Record "FA Journal Line")
    var
        GLAcc: Record "G/L Account";
        GlAcc2: Record "G/L Account";
        GenJnlLine: Record "Gen. Journal Line";
        FAPostingGr: Record "FA Posting Group";
        SourceCodeSetup: Record "Source Code Setup";
    begin
        Clear(GenJnlPostLine);
        SourceCodeSetup.Get();
        SourceCodeSetup.TestField("Fixed Asset Journal");
        CompressDepr[1].SetCurrentKey("Line No.");
        CompressDepr[1].Reset();
        if CompressDepr[1].Find('-') then
            repeat
                Clear(GenJnlLine);
                FAPostingGr.Get(CompressDepr[1]."FA Posting Group");
                GenJnlLine."Posting Date" := CompressDepr[1]."Posting Date";
                GenJnlLine."Document No." := CompressDepr[1]."Document No.";
                GenJnlLine."Reason Code" := CompressDepr[1]."Reason Code";
                GenJnlLine."Dimension Set ID" := CompressDepr[1]."Dimension Set ID";

                GenJnlLine."Source Code" := SourceCodeSetup."Fixed Asset Journal";
                GenJnlLine."System-Created Entry" := true;
                if CompressDepr[1]."FA Posting Type" = CompressDepr[1]."FA Posting Type"::Depreciation then begin
                    FAPostingGr.TestField("Accum. Depreciation Account");
                    FAPostingGr.TestField("Depreciation Expense Acc.");
                    GLAcc.Get(FAPostingGr."Accum. Depreciation Account");
                    TestGLAcc(GLAcc);
                    GlAcc2.Get(FAPostingGr."Depreciation Expense Acc.");
                    TestGLAcc(GlAcc2);
                end;
                if CompressDepr[1]."FA Posting Type" = CompressDepr[1]."FA Posting Type"::"Custom 1" then begin
                    FAPostingGr.TestField("Custom 1 Account");
                    FAPostingGr.TestField("Custom 1 Expense Acc.");
                    GLAcc.Get(FAPostingGr."Custom 1 Account");
                    TestGLAcc(GLAcc);
                    GlAcc2.Get(FAPostingGr."Custom 1 Expense Acc.");
                    TestGLAcc(GlAcc2);
                end;
                if CompressDepr[1]."FA Posting Type" = CompressDepr[1]."FA Posting Type"::"Custom 2" then begin
                    FAPostingGr.TestField("Custom 2 Account");
                    FAPostingGr.TestField("Custom 2 Expense Acc.");
                    GLAcc.Get(FAPostingGr."Custom 2 Account");
                    TestGLAcc(GLAcc);
                    GlAcc2.Get(FAPostingGr."Custom 2 Expense Acc.");
                    TestGLAcc(GlAcc2);
                end;
                GenJnlLine.Validate("Account No.", GLAcc."No.");
                GenJnlLine.Description := StrSubstNo(Text12100, CompressDepr[1]."FA Posting Type");
                GenJnlLine."Shortcut Dimension 1 Code" := CompressDepr[1]."Global Dimension 1 Code";
                GenJnlLine."Shortcut Dimension 2 Code" := CompressDepr[1]."Global Dimension 2 Code";
                GenJnlLine.Validate(Amount, CompressDepr[1].Amount);
                OnPostCompressTableOnBeforePostFirstLine(GenJnlLine, CompressDepr, FAJnlLine, FAPostingGr);
                GenJnlPostLine.RunWithCheck(GenJnlLine);

                GenJnlLine.Validate("Account No.", GlAcc2."No.");
                GenJnlLine.Description := StrSubstNo(Text12100, CompressDepr[1]."FA Posting Type");
                GenJnlLine."Shortcut Dimension 1 Code" := CompressDepr[1]."Global Dimension 1 Code";
                GenJnlLine."Shortcut Dimension 2 Code" := CompressDepr[1]."Global Dimension 2 Code";
                GenJnlLine.Validate(Amount, -CompressDepr[1].Amount);
                OnPostCompressTableOnBeforePostSecondLine(GenJnlLine, CompressDepr, FAJnlLine, FAPostingGr);
                GenJnlPostLine.RunWithCheck(GenJnlLine);
                OnPostCompressTableOnAfterPostSecondLine(GenJnlLine, CompressDepr, FAJnlLine, FAPostingGr, GenJnlPostLine);
            until CompressDepr[1].Next() = 0;
        CompressDepr[1].DeleteAll();
        OnAfterPostCompressTable(FAJnlLine);
    end;

    [Scope('OnPrem')]
    procedure TestGLAcc(var GLAcc: Record "G/L Account")
    begin
        GLAcc.CheckGLAcc();
        GLAcc.TestField("Gen. Posting Type", GLAcc."Gen. Posting Type"::" ");
        GLAcc.TestField("Gen. Bus. Posting Group", '');
        GLAcc.TestField("Gen. Prod. Posting Group", '');
    end;

    procedure SetPreviewMode(NewPreviewMode: Boolean)
    begin
        PreviewMode := NewPreviewMode;
    end;

    procedure SetSuppressCommit(NewSuppressCommit: Boolean)
    begin
        SuppressCommit := NewSuppressCommit;
    end;

    local procedure PostLines()
    var
        IsHandled: Boolean;
    begin
        LineCount := 0;
        LastDocNo := '';
        LastDocNo2 := '';
        LastPostedDocNo := '';
        FAJnlLine.Find('-');
        repeat
            LineCount := LineCount + 1;
            if GuiAllowed() then begin
                IsHandled := false;
                OnPostLinesOnBeforeWindowUpdate(IsHandled);
                if not IsHandled then begin
                    Window.Update(3, LineCount);
                    Window.Update(4, Round(LineCount / NoOfRecords * 10000, 1));
                end;
            end;
            CheckFAJnlLineDocumentNo();
            if not (FAJnlLine."FA No." = '') then
                LastDocNo2 := FAJnlLine."Document No.";
            MakeRecurringTexts(FAJnlLine);
            if FAJnlLine."Posting No. Series" = '' then
                FAJnlLine."Posting No. Series" := FAJnlBatch."No. Series"
            else
                if not (FAJnlLine."FA No." = '') then
                    if FAJnlLine."Document No." = LastDocNo then
                        FAJnlLine."Document No." := LastPostedDocNo
                    else begin
                        LastDocNo := FAJnlLine."Document No.";
                        OnPostLinesOnBeforeGetNextNoSeries(FAJnlLine);
                        FAJnlLine."Document No." := NoSeriesBatch.GetNextNo(FAJnlLine."Posting No. Series", FAJnlLine."FA Posting Date");
                        OnPostLinesOnAfterGetNextNoSeries(FAJnlLine);
                        LastPostedDocNo := FAJnlLine."Document No.";
                    end;
            OnPostLinesOnBeforeFAJnlPostLine(FAJnlLine, FAJnlPostLine);
            FAJnlPostLine.FAJnlPostLine(FAJnlLine, false);
            OnPostLinesOnAfterFAJnlPostLine(FAJnlLine);
            CreateCompressTable(FAJnlLine);
        until FAJnlLine.Next() = 0;
        PostCompressTable(FAJnlLine);
    end;

    local procedure CheckFAJnlLineDocumentNo()
    var
        NoSeries: Record "No. Series";
        IsHandled: Boolean;
        CompareNextNo: Code[20];
    begin
        IsHandled := false;
        OnBeforeCheckFAJnlLineDocumentNo(FAJnlLine, FAJnlBatch, IsHandled);
        if IsHandled then
            exit;

        if not (FAJnlLine."FA No." = '') and (FAJnlBatch."No. Series" <> '') and (FAJnlLine."Document No." <> LastDocNo2) then begin
            CompareNextNo := NoSeriesBatch.GetNextNo(FAJnlBatch."No. Series", FAJnlLine."FA Posting Date");
            NoSeries.Get(FAJnlBatch."No. Series");
            if NoSeries."Manual Nos." then
                if FAJnlLine."Document No." <> CompareNextNo then
                    exit;
            FAJnlLine.TestField(FAJnlLine."Document No.", CompareNextNo);
        end
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostCompressTable(FAJournalLine: Record "FA Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckFAJnlLineDocumentNo(FAJnlLine: Record "FA Journal Line"; FAJnlBatch: Record "FA Journal Batch"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCommit(FARegNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateNewFAJnlLine(var FAJnlLine: Record "FA Journal Line"; var FAJnlLine2: Record "FA Journal Line"; var FAJnlLine3: Record "FA Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnBeforeFAJnlLine3DeleteAll(var FAJnlLine3: Record "FA Journal Line"; var FAJnlLine: Record "FA Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateCompressTableOnAfterCompressDeprSetFilters(var CompressDepreciation: array[2] of Record "Compress Depreciation" temporary; FAJournalLine: Record "FA Journal Line"; FixedAsset: Record "Fixed Asset"; DepreciationBook: Record "Depreciation Book"; FADepreciationBook: Record "FA Depreciation Book")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnBeforeLockTable(var FAJnlLine: Record "FA Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostLinesOnAfterFAJnlPostLine(var FAJnlLine: Record "FA Journal Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnPostCompressTableOnBeforePostFirstLine(var GenJournalLine: Record "Gen. Journal Line"; CompressDepreciation: array[2] of Record "Compress Depreciation" temporary; FAJournalLine: Record "FA Journal Line"; FAPostingGroup: Record "FA Posting Group")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnPostCompressTableOnAfterPostSecondLine(var GenJournalLine: Record "Gen. Journal Line"; CompressDepreciation: array[2] of Record "Compress Depreciation" temporary; FAJournalLine: Record "FA Journal Line"; FAPostingGroup: Record "FA Posting Group"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnPostCompressTableOnBeforePostSecondLine(var GenJournalLine: Record "Gen. Journal Line"; CompressDepreciation: array[2] of Record "Compress Depreciation" temporary; FAJournalLine: Record "FA Journal Line"; FAPostingGroup: Record "FA Posting Group")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnAfterLockTable(var FAJournalBatch: Record "FA Journal Batch")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnBeforeWindowOpen(var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnBeforeUpdateDeleteLines(var FAJournalLine: Record "FA Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnBeforeWindowUpdate(var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostLinesOnBeforeWindowUpdate(var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostLinesOnBeforeGetNextNoSeries(var FAJournalLine: Record "FA Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostLinesOnAfterGetNextNoSeries(var FAJournalLine: Record "FA Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostLinesOnBeforeFAJnlPostLine(var FAJournalLine: Record "FA Journal Line"; var FAJnlPostLine: Codeunit "FA Jnl.-Post Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnCheckSuppressCommit(var FAJournalLine: Record "FA Journal Line"; var SuppressCommit: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunOnBeforeCommit(var FAJournalLine: Record "FA Journal Line"; var SuppressCommit: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunOnBeforeUpdateAnalysisViewUpdateAll(var FAJournalLine: Record "FA Journal Line"; var SuppressCommit: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnAfterPostLines(var FAJournalLine: Record "FA Journal Line")
    begin
    end;
}

