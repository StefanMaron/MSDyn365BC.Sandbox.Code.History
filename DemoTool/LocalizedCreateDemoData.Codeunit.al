codeunit 101903 "Localized Create Demo Data"
{

    trigger OnRun()
    begin
    end;

    var
        XDEFAULT: Label 'DEFAULT', Comment = 'Template Name';
        XDefaultDomiciliationJournal: Label 'Default Domiciliation Journal';
        XDOMJNL: Label 'DOMJNL', Comment = 'Source Code';
        XDomiciliationJournal: Label 'Domiciliation Journal';

    procedure CreateDataBeforeActions()
    begin
    end;

    procedure CreateDataAfterActions()
    begin
    end;

    procedure CreateEvaluationData()
    begin
    end;

    procedure CreateExtendedData()
    begin
#if not CLEAN22
        StartApplyingGLEntries();
#endif
        CreateDefaultDomiciliationJnl();
    end;

#if not CLEAN22
    local procedure StartApplyingGLEntries()
    var
        TempGLEntryBuf: Record "G/L Entry Application Buffer" temporary;
        TempGLEntryBuf2: Record "G/L Entry Application Buffer" temporary;
        ApplyGLEntries: Page "Apply General Ledger Entries";
        Window: Dialog;
        tmpAmt: Decimal;
        Stop: Boolean;
    begin
        Clear(ApplyGLEntries);

        Window.Open('Applying G/L Ledger Entries');

        ApplyGLEntries.SetAllEntries('452000');
        TempGLEntryBuf.SetRange("Global Dimension 1 Code", '');
        TempGLEntryBuf.SetRange(Open, true);

        if TempGLEntryBuf.FindSet() then
            repeat
                TempGLEntryBuf2 := TempGLEntryBuf;
                TempGLEntryBuf2.Insert();
            until TempGLEntryBuf.Next() = 0;

        if TempGLEntryBuf.FindSet() then
            repeat
                tmpAmt := TempGLEntryBuf.Amount;
                if TempGLEntryBuf2.FindSet() then
                    repeat
                        if TempGLEntryBuf2.Amount = -tmpAmt then
                            Stop := true;
                    until (TempGLEntryBuf2.Next() = 0) or (Stop = true);
            until (TempGLEntryBuf.Next() = 0) or (Stop = true);

        // setApplID
        if Stop = true then begin
            TempGLEntryBuf.SetRange(Amount, tmpAmt);
            ApplyGLEntries.SetApplId(TempGLEntryBuf);
            TempGLEntryBuf.SetRange(Amount);

            TempGLEntryBuf.SetRange(Amount, -tmpAmt);
            ApplyGLEntries.SetApplId(TempGLEntryBuf);
            TempGLEntryBuf.SetRange(Amount);

            // Apply
            ApplyGLEntries.Apply(TempGLEntryBuf);
        end;

        Window.Close();
    end;
#endif

    local procedure CreateDefaultDomiciliationJnl()
    var
        SourceCode: Record "Source Code";
        SourceCodeSetup: Record "Source Code Setup";
        BankAccount: Record "Bank Account";
        DomJnlTemplate: Record "Domiciliation Journal Template";
    begin
        SourceCode.Init();
        SourceCode.Code := XDOMJNL;
        SourceCode.Description := XDomiciliationJournal;
        SourceCode.Insert();

        SourceCodeSetup.Get();
        SourceCodeSetup."Domiciliation Journal" := SourceCode.Code;
        SourceCodeSetup.Modify();

        BankAccount.FindFirst();
        DomJnlTemplate.Init();
        DomJnlTemplate.Name := XDEFAULT;
        DomJnlTemplate.Description := XDefaultDomiciliationJournal;
        DomJnlTemplate."Page ID" := PAGE::"Domiciliation Journal";
        DomJnlTemplate."Test Report ID" := REPORT::"Domiciliation Journal - Test";
        DomJnlTemplate."Bank Account No." := BankAccount."No.";
        DomJnlTemplate."Source Code" := SourceCode.Code;
        DomJnlTemplate.Insert(true);
    end;
}

