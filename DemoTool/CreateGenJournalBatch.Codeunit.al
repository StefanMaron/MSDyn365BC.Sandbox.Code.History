codeunit 101232 "Create Gen. Journal Batch"
{

    trigger OnRun()
    begin
        InsertData(XSTART, XCUSTOPEN, XCustomers, 0, '', true, false);
        InsertData(XSTART, XGLOPEN, XGLAccounts, 0, '', true, false);
        InsertData(XSTART, XPERIODIC, XPERIODIC, 0, '', true, false);
        InsertData(XSTART, XVENDOPEN, XVendors, 0, '', true, false);
        InsertData(XSTART, XBANKOPEN, XBank, 0, '', true, false);
        InsertData(XSTART, XDEFAULT, XOther, 0, '', true, false);

        InsertData(XSTART, XDEPR, XPeriodicDepr, 0, '', true, false);
        InsertData(XASSETS, XDEFAULT, XDefaultJournalBatch, 0, '', true, false);
        InsertData(XJOB, XDEFAULT, XDefaultJournalBatch, 0, '', true, false);

        InsertData(
          XGENERAL, XDEFAULT, XDefaultJournalBatch,
          0, '', true, false);
        InsertData(
          XGENERAL, XCASH, XCashreceiptsandpayments,
          "Gen. Journal Batch"."Bal. Account Type"::"G/L Account", '992910', true, false);
        InsertData(
          XSALES, XDEFAULT, XDefaultJournalBatch,
          0, '', true, false);
        InsertData(
          XPURCH, XDEFAULT, XDefaultJournalBatch,
          0, '', true, false);

        InsertData(
          XCASHRCPT, XGENERAL, XGENERAL,
          0, '', true, false);
        InsertData(
          XCASHRCPT, XBank, XBankpayments,
          "Gen. Journal Batch"."Bal. Account Type"::"Bank Account", XWWBOPERATING, true, false);
        InsertData(
          XCASHRCPT, XGIRO, XGiropayments,
          "Gen. Journal Batch"."Bal. Account Type"::"Bank Account", XGIRO, true, false);
        InsertData(
          XPAYMENT, XGENERAL, XGENERAL,
          0, '', true, false);
        InsertData(
          XPAYMENT, XBank, XBankpayments,
          "Gen. Journal Batch"."Bal. Account Type"::"Bank Account", XWWBOPERATING, false, false);
        InsertData(
          XPAYMENT, XCASH, XCashreceiptsandpayments,
          "Gen. Journal Batch"."Bal. Account Type"::"G/L Account", '992910', true, false);
        InsertData(
          XPAYMENT, XGIRO, XGiropayments,
          "Gen. Journal Batch"."Bal. Account Type"::"Bank Account", XGIRO, true, false);
        InsertData(XPAYMENT, XPmtRegTxt, XBankReconciliationTxt,
          "Gen. Journal Batch"."Bal. Account Type"::"Bank Account", XWWBOPERATING, true, true);
        InsertData(
          XRECURRING, XDEFAULT, XRecurringJournal, 0, '', true, false);
        InsertData(
          XPAYMENT, XBankConvTxt, XBankConvDescTxt,
          "Gen. Journal Batch"."Bal. Account Type"::"Bank Account", XWWBTRANSFERSTxt, false, true);
    end;

    var
        "Gen. Journal Batch": Record "Gen. Journal Batch";
        CA: Codeunit "Make Adjustments";
        XSTART: Label 'START';
        XCUSTOPEN: Label 'CUST OPEN';
        XCustomers: Label 'Customers';
        XGLOPEN: Label 'G/L OPEN';
        XGLAccounts: Label 'G/L Accounts';
        XPERIODIC: Label 'PERIODIC';
        XVendors: Label 'Vendors';
        XBANKOPEN: Label 'BANK OPEN';
        XVENDOPEN: Label 'VEND OPEN';
        XBank: Label 'Bank';
        XDEFAULT: Label 'DEFAULT';
        XOther: Label 'Other';
        XDEPR: Label 'DEPR';
        XPeriodicDepr: Label 'Periodic Depr.';
        XASSETS: Label 'ASSETS';
        XDefaultJournalBatch: Label 'Default Journal Batch';
        XGENERAL: Label 'GENERAL';
        XCASH: Label 'CASH';
        XCashreceiptsandpayments: Label 'Cash receipts and payments';
        XSALES: Label 'SALES';
        XPURCH: Label 'PURCH';
        XCASHRCPT: Label 'CASHRCPT';
        XBankpayments: Label 'Bank payments';
        XGIRO: Label 'GIRO';
        XGiropayments: Label 'Giro payments';
        XPAYMENT: Label 'PAYMENT';
        XWWBOPERATING: Label 'WWB-OPERATING';
        XJOB: Label 'JOB';
        XRECURRING: Label 'RECURRING', Comment = 'Recurring is a name of Journal Template.';
        XRecurringJournal: Label 'Recurring Journal';
        XPmtRegTxt: Label 'PMT REG', Comment = 'Payment Registration';
        XBankReconciliationTxt: Label 'Bank Reconciliation';
        XBankConvTxt: Label 'BANK CONV', Locked = true;
        XBankConvDescTxt: Label 'Payment Export using Bank Data Conversion Service';
        XWWBTRANSFERSTxt: Label 'WWB-TRANSFERS', Locked = true;
        XMONTHLY: Label 'Monthly';
        XDAILY: Label 'DAILY';
        XMonthlyJournalEntries: Label 'Monthly Journal Entries';
        XDailyJournalEntries: Label 'Daily Journal Entries';

    procedure InsertData("Journal Template Name": Code[10]; Name: Code[10]; Description: Text[50]; "Bal. Account Type": Option; "Bal. Account No.": Code[20]; InsertNoSeries: Boolean; AllowPaymentExport: Boolean)
    begin
        "Gen. Journal Batch".Init();
        "Gen. Journal Batch".Validate("Journal Template Name", "Journal Template Name");
        "Gen. Journal Batch".SetupNewBatch();
        "Gen. Journal Batch".Validate(Name, Name);
        "Gen. Journal Batch".Insert(true);
        "Gen. Journal Batch".Validate(Description, Description);
        "Gen. Journal Batch".Validate("Bal. Account Type", "Bal. Account Type");
        if "Bal. Account Type" = "Gen. Journal Batch"."Bal. Account Type"::"G/L Account" then
            "Bal. Account No." := CA.Convert("Bal. Account No.");
        "Gen. Journal Batch".Validate("Bal. Account No.", "Bal. Account No.");
        if not InsertNoSeries then
            "Gen. Journal Batch"."No. Series" := '';
        "Gen. Journal Batch".Validate("Allow Payment Export", AllowPaymentExport);
        "Gen. Journal Batch".Modify();
    end;

    procedure InsertMiniAppData()
    begin
        InsertData(XGENERAL, XDEFAULT, XDefaultJournalBatch, 0, '', true, false);
        UpdateCopyToPostedGenJnlLines(XGENERAL, XDEFAULT, true);
        InsertData(XGENERAL, XMONTHLY, XMonthlyJournalEntries, "Gen. Journal Batch"."Bal. Account Type"::"G/L Account", '18100', true, false);
        InsertData(XGENERAL, XDAILY, XDailyJournalEntries, 3, '', true, false);
        UpdateCopyToPostedGenJnlLines(XGENERAL, XMONTHLY, true);
        InsertData(XCASHRCPT, XGENERAL, XGENERAL, "Gen. Journal Batch"."Bal. Account Type"::"G/L Account", '18100', true, false);
        InsertData(XPAYMENT, XGENERAL, XGENERAL, "Gen. Journal Batch"."Bal. Account Type"::"G/L Account", '18100', true, false);
        InsertData(XPAYMENT, XPmtRegTxt, XBankReconciliationTxt,
          "Gen. Journal Batch"."Bal. Account Type"::"Bank Account", '', true, true);
        InsertData(
          XPAYMENT, XCASH, XCashreceiptsandpayments,
          "Gen. Journal Batch"."Bal. Account Type"::"G/L Account", '18100', true, false);
        InsertData(XASSETS, XDEFAULT, XDefaultJournalBatch, 0, '', true, false);
    end;

    procedure GetGeneralDefaultBatch(var GenJournalBatch: Record "Gen. Journal Batch")
    begin
        GenJournalBatch."Journal Template Name" := XGENERAL;
        GenJournalBatch.Name := XDEFAULT;
    end;

    internal procedure GetGeneralJournalTemplateName(): Text
    begin
        exit(XGENERAL);
    end;

    internal procedure GetDailyJournalBatchName(): Text
    begin
        exit(XDAILY);
    end;

    local procedure UpdateCopyToPostedGenJnlLines(GenJnlTemplateName: Code[10]; GenJnlBatchName: Code[10]; CopyToPostedGenJnlLines: Boolean)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        GenJournalBatch.Get(GenJnlTemplateName, GenJnlBatchName);
        GenJournalBatch.Validate("Copy to Posted Jnl. Lines", CopyToPostedGenJnlLines);
        GenJournalBatch.Modify(true);
    end;
}

