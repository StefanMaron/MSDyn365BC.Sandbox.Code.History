codeunit 161551 "Create Demodata GlForeign Curr"
{
    // Changed Date in PrepareGlLine


    trigger OnRun()
    begin
        d.Open(Text11508);

        // Delete old entries Journal
        GenJnlLine.Reset();
        GenJnlLine.SetRange("Journal Template Name", Text11509);
        GenJnlLine.SetRange("Journal Batch Name", Text11510);
        GenJnlLine.DeleteAll();

        // DYN5.00
        DemoDataSetup.Get();
        DDTWorkingDate := DemoDataSetup."Working Date";

        // Start Process
        PrepareChartOfAcc;
        GlAccountIndent.Indent;
        CreateGlJournal;
        PrepareGlLine;

        d.Close();
    end;

    var
        Text11508: Label 'Generate G/L FC demo data';
        Text11509: Label 'General';
        Text11510: Label 'FC';
        Text11512: Label 'Bank EUR';
        Text11513: Label 'EUR';
        Text11514: Label 'Bank USD';
        Text11515: Label 'USD';
        Text11516: Label 'Bank DKK';
        Text11517: Label 'DKK';
        Text11518: Label 'Foreign Currency Postings';
        Text11519: Label 'Transfer Bank CHF -> EUR';
        Text11520: Label 'Transfer Bank EUR -> CHF';
        Text11521: Label 'Transfer Bank USD -> CHF';
        Text11522: Label 'Transfer Bank CHF -> USD';
        Text11523: Label 'Transfer Bank DKK -> CHF';
        Text11524: Label 'Transfer Bank CHF -> DKK';
        Text11525: Label 'FC1';
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        DemoDataSetup: Record "Demo Data Setup";
        GlAccountIndent: Codeunit "G/L Account-Indent";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        d: Dialog;
        LastLineNo: Integer;
        LastDocNo: Code[10];
        DDTWorkingDate: Date;

    procedure PrepareChartOfAcc()
    begin
        WriteChartOfAcc('1026', Text11512, Text11513);
        WriteChartOfAcc('1028', Text11514, Text11515);
        WriteChartOfAcc('1030', Text11516, Text11517);
    end;

    procedure WriteChartOfAcc(_AccNo: Code[10]; _AccName: Text[30]; _Currency: Code[10])
    var
        GLAccount: Record "G/L Account";
        GLAccountExist: Boolean;
    begin
        GLAccountExist := GLAccount.Get(_AccNo);
        GLAccount."No." := _AccNo;
        GLAccount.Validate(Name, _AccName);
        GLAccount."Account Type" := GLAccount."Account Type"::Posting;
        GLAccount."Income/Balance" := GLAccount."Income/Balance"::"Balance Sheet";
        GLAccount."Direct Posting" := true;
        // VALIDATE("Currency Code",_Currency);
        GLAccount."Currency Code" := _Currency;

        if GLAccountExist then
            GLAccount.Modify()
        else
            GLAccount.Insert();
    end;

    procedure CreateGlJournal()
    begin
        with GenJnlBatch do begin
            Init();
            "Journal Template Name" := Text11509;
            Name := Text11510;
            Description := Format(Text11518, -MaxStrLen(Description));
            if not Insert then
                Modify();
        end;
    end;

    procedure PrepareGlLine()
    begin
        //          Date     Acc    Bal       Amt   LCY  Text
        // 5.00 New Dates
        WriteGlLine(DDTWorkingDate + 8, '1020', '1026', 1000, 1620, Text11519);  //  1000 EUR à 1.62
        WriteGlLine(DDTWorkingDate + 12, '1026', '1020', 2000, 3100, Text11520);  //  2000 EUR à 1.55
        WriteGlLine(DDTWorkingDate + 15, '1020', '1026', 500, 750, Text11519);  //   500 EUR à 1.50
        WriteGlLine(DDTWorkingDate + 16, '1028', '1020', 10000, 16000, Text11521);  // 10000 USD à 1.60
        WriteGlLine(DDTWorkingDate + 18, '1028', '1020', 215.4, 350.03, Text11522);  // 215.40 USD à 1.625 = 350.025
        WriteGlLine(DDTWorkingDate + 21, '1020', '1030', -880, -220, Text11523);  //   880 DKK à 20
        PostGlLines;

        WriteGlLine(DDTWorkingDate + 18, '1026', '1020', 1200, 1800, Text11520);  // EUR - CHF: 1200  EUR à 1.50
        WriteGlLine(DDTWorkingDate + 20, '1026', '1020', 500, 760, Text11520);  // EUR - CHF:  500 EUR à 1.52
        WriteGlLine(DDTWorkingDate + 21, '1020', '1030', 1000, 230, Text11524);  // CHF - DKK: 1000 DKK à 23.00
        WriteGlLine(DDTWorkingDate + 23, '1028', '1020', 10000, 10620, Text11521);  // USD - CHF: 10000 USD à 1.62
    end;

    procedure WriteGlLine(_Date: Date; _AccountNo: Code[10]; _BalAccountNo: Code[10]; _Amount: Decimal; _AmountLCY: Decimal; _Desc: Text[50])
    begin
        with GenJnlLine do begin
            Init();

            "Journal Template Name" := Text11509;
            "Journal Batch Name" := Text11510;
            LastLineNo := LastLineNo + 10000;
            "Line No." := LastLineNo;
            if LastDocNo = '' then
                LastDocNo := Text11525
            else
                LastDocNo := IncStr(LastDocNo);
            "Document No." := LastDocNo;
            "Account Type" := "Account Type"::"G/L Account";
            "Bal. Account Type" := "Bal. Account Type"::"G/L Account";

            "Posting Date" := _Date;
            Validate("Account No.", _AccountNo);
            Validate("Bal. Account No.", _BalAccountNo);
            Validate(Amount, _Amount);
            Validate("Amount (LCY)", _AmountLCY);
            Description := _Desc;
            Insert();
        end;
    end;

    procedure PostGlLines()
    begin
        with GenJnlLine do begin
            Reset();
            SetRange("Journal Template Name", Text11509);
            SetRange("Journal Batch Name", Text11510);
            Find('-');
            repeat
                GenJnlPostLine.Run(GenJnlLine);
            until Next = 0;

            DeleteAll();
        end;
    end;
}

