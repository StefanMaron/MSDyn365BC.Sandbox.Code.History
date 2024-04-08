codeunit 161005 "Create Bill Group"
{

    trigger OnRun()
    begin
        DemoDataSetup.Get();
        // Settle receivable document ( a bill)
        SettleReceivableDoc;
        Commit();
        // Create bill group
        InsertData(XNBL, 1, CalcDate('<CY-2Y+2M+1D>'), 0);

        // Insert bills in new bill group
        with Doc do begin
            Reset();
            SetRange(Type, Type::Receivable);
            SetRange("Document Type", "Document Type"::Bill);
            SetRange("Collection Agent", "Collection Agent"::Bank);
            SetRange("Bill Gr./Pmt. Order No.", '');
            Find('-');
            FinanceCoType := "Collection Agent"::Bank;
            GroupNo := BillGr."No.";
            for i := 1 to 3 do begin
                TestField("Collection Agent", FinanceCoType);
                TestField("Bill Gr./Pmt. Order No.", '');
                TestField("Currency Code", '');
                TestField(Type, Type::Receivable);
                if Accepted = Accepted::No then
                    FieldError(Accepted);
                OldDoc := Doc;
                "Collection Agent" := FinanceCoType;
                "Bill Gr./Pmt. Order No." := GroupNo;
                Modify();
                Doc := OldDoc;
                Doc.Next();
            end;
        end;

        // Create factoring bill group
        InsertData(XNBL, 0, CalcDate('<CY-2Y+2M+1D>'), 1);

        // Insert invoices in new bill group
        with Doc do begin
            Reset();
            SetRange(Type, Type::Receivable);
            SetRange("Document Type", "Document Type"::Invoice);
            SetRange("Collection Agent", "Collection Agent"::Bank);
            SetRange("Bill Gr./Pmt. Order No.", '');
            Find('-');
            FinanceCoType := "Collection Agent"::Bank;
            GroupNo := BillGr."No.";
            for i := 1 to 2 do begin
                TestField("Collection Agent", FinanceCoType);
                TestField("Bill Gr./Pmt. Order No.", '');
                TestField("Currency Code", '');
                TestField(Type, Type::Receivable);
                if Accepted = Accepted::No then
                    FieldError(Accepted);
                OldDoc := Doc;
                "Collection Agent" := FinanceCoType;
                "Bill Gr./Pmt. Order No." := GroupNo;
                Modify();
                Doc := OldDoc;
                Doc.Next();
            end;
        end;

        // Modify Acc. 6260001 to post journal
        if CGCta.Get('6260001') then begin
            CGCta."Gen. Posting Type" := 0;
            CGCta."Gen. Bus. Posting Group" := '';
            CGCta."Gen. Prod. Posting Group" := '';
            CGCta.Modify();
        end;

        //Post group
        BillGr.SetRecFilter();
        PostBillGr.SetHidePrintDialog(true);
        PostBillGr.SetTableView(BillGr);
        PostBillGr.UseRequestPage(false);
        PostBillGr.InitReqForm(XCARTERA, XDEFAULT);
        PostBillGr.RunModal();

        Clear(PostBillGr);

        // Create one more group
        InsertData(XWWBEUR, 0, CalcDate('<CY-2Y+2M+1D>'), 0);

        // Insert Docs. in new bill group
        with Doc do begin
            Reset();
            SetRange(Type, Type::Receivable);
            SetRange("Document Type", "Document Type"::Bill);
            SetRange("Collection Agent", "Collection Agent"::Bank);
            SetRange("Bill Gr./Pmt. Order No.", '');
            Find('-');
            FinanceCoType := "Collection Agent"::Bank;
            GroupNo := BillGr."No.";
            for i := 1 to 3 do begin
                TestField("Collection Agent", FinanceCoType);
                TestField("Bill Gr./Pmt. Order No.", '');
                TestField("Currency Code", '');
                TestField(Type, Type::Receivable);
                if Accepted = Accepted::No then
                    FieldError(Accepted);
                OldDoc := Doc;
                "Collection Agent" := FinanceCoType;
                "Bill Gr./Pmt. Order No." := GroupNo;
                Modify();
                Doc := OldDoc;
                Doc.Next();
            end;
        end;

        // Post group
        BillGr.SetRecFilter();
        PostBillGr.SetHidePrintDialog(true);
        PostBillGr.SetTableView(BillGr);
        PostBillGr.UseRequestPage(false);
        PostBillGr.InitReqForm(XCARTERA, XDEFAULT);
        PostBillGr.RunModal();

        // Post settlement
        WorkDate(20080124D);
        PostedDoc.SetRange("Bill Gr./Pmt. Order No.", '106003');
        SettleDocsInPostedBillGr.SetHidePrintDialog(true);
        SettleDocsInPostedBillGr.SetTableView(PostedDoc);
        SettleDocsInPostedBillGr.UseRequestPage(false);
        SettleDocsInPostedBillGr.RunModal();

        GenJnlLine.SetRange("Journal Template Name", XCARTERA);
        GenJnlLine.SetRange("Journal Batch Name", XDEFAULT);
        if GenJnlLine.Find('-') then
            repeat
                GJPostLine.Run(GenJnlLine);
            until GenJnlLine.Next() = 0;
        GenJnlLine.DeleteAll();

        if CGCta.Get('6260001') then begin
            CGCta."Gen. Posting Type" := 1;
            CGCta."Gen. Bus. Posting Group" := DemoDataSetup.DomesticCode;
            CGCta."Gen. Prod. Posting Group" := DemoDataSetup.MiscCode;
            CGCta.Modify();
        end;
    end;

    var
        Doc: Record "Cartera Doc.";
        OldDoc: Record "Cartera Doc.";
        AccountingSetup: Record "General Ledger Setup";
        CarteraManagement: Codeunit CarteraManagement;
        GJPostLine: Codeunit "Gen. Jnl.-Post Line";
        FinanceCoType: Integer;
        GroupNo: Code[20];
        i: Integer;
        BillGr: Record "Bill Group";
        PostBillGr: Report "Post Bill Group";
        SettleDocsInPostedBillGr: Report "Settle Docs. in Post. Bill Gr.";
        PostedDoc: Record "Posted Cartera Doc.";
        GenJnlLine: Record "Gen. Journal Line";
        CGCta: Record "G/L Account";
        DemoDataSetup: Record "Demo Data Setup";
        XNBL: Label 'NBL';
        XCARTERA: Label 'CARTERA';
        XDEFAULT: Label 'DEFAULT';
        XWWBEUR: Label 'WWB-EUR';
        XCASHRCPT: Label 'CASHRCPT';
        XDeerfieldGraphicsCompany: Label 'Deerfield Graphics Company';
        XJO: Label 'JO';
        XCASHRECJNL: Label 'CASHRECJNL';
        XBANK: Label 'BANK';
        XBANKBILLGROUP: Label 'Bank Bill Group %1';

    procedure InsertData("Company No.": Code[20]; "Dealing Type": Option Collection,Discount; "Posting Date": Date; Factoring: Option)
    begin
        Clear(BillGr);
        BillGr.Validate("No.", '');
        BillGr."Posting Date" := "Posting Date";
        BillGr.Insert(true);
        // BillGr."Posting Description" := 'Bank Bill Group ' + BillGr."No.";
        BillGr."Posting Description" := StrSubstNo(XBANKBILLGROUP, BillGr."No.");
        BillGr."Bank Account No." := "Company No.";
        BillGr."Dealing Type" := "Dealing Type";
        BillGr.Factoring := Factoring;
        BillGr.Validate("Bank Account No.", "Company No.");
        BillGr.Validate("Dealing Type", "Dealing Type");
        BillGr.Validate("Posting Date", "Posting Date");
        BillGr.Validate(Factoring, Factoring);
        BillGr.Modify();
    end;

    procedure SettleReceivableDoc()
    var
        Doc2: Record "Cartera Doc.";
        GenJnlLine2: Record "Gen. Journal Line";
    begin
        with Doc2 do begin
            Reset();
            SetRange(Type, Type::Receivable);
            SetRange("Document Type", "Document Type"::Bill);
            SetRange("Collection Agent", "Collection Agent"::Bank);
            SetRange("Bill Gr./Pmt. Order No.", '');
            Find('-');
        end;
        with GenJnlLine2 do begin
            Validate("Journal Template Name", XCASHRCPT);
            Validate("Line No.", 10000);
            Validate("Account Type", "Account Type"::Customer);
            Validate("Account No.", Doc2."Account No.");
            Validate("Posting Date", Doc2."Posting Date");
            Validate("Document Type", "Document Type"::Payment);
            Validate("Document No.", 'G02001');
            Validate(Description, XDeerfieldGraphicsCompany);
            Validate(Amount, -Doc2."Remaining Amount");
            Validate("Posting Group", DemoDataSetup.DomesticCode);
            Validate("Salespers./Purch. Code", XJO);
            Validate("Source Code", XCASHRECJNL);
            Validate("System-Created Entry", false);
            Validate("Applies-to Doc. Type", "Applies-to Doc. Type"::Bill);
            Validate("Applies-to Doc. No.", Doc2."Document No.");
            Validate("Due Date", Doc2."Due Date");
            Validate("Journal Batch Name", XBANK);
            Validate("VAT Calculation Type", "VAT Calculation Type"::"Normal VAT");
            Validate("Bal. Account Type", "Bal. Account Type"::"Bank Account");
            Validate("Bal. Account No.", XNBL);
            Validate("Applies-to Bill No.", '1');
            Validate("Recipient Bank Account", Doc2."Cust./Vendor Bank Acc. Code");
            Validate("Payment Method Code", Doc2."Payment Method Code");
            Insert();
        end;
        GJPostLine.SetFromSettlement(true);
        GJPostLine.Run(GenJnlLine2);

        // GJPostLine.RUN(GenJnlLine2);
        Clear(GJPostLine);
    end;
}

