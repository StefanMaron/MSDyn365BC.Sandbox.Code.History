codeunit 161006 "Create Payment Order"
{

    trigger OnRun()
    begin
        DemoDataSetup.Get();
        // Settle payable document
        SettlePayableDoc;
        Commit();
        // Create payment order
        InsertData(XNBL, CalcDate('<CY-2Y+2M+1D>'));

        // Insert documents in new payment order
        with Doc do begin
            Reset();
            SetRange(Type, Type::Payable);
            SetRange("Document Type", "Document Type"::Bill);
            SetRange("Collection Agent", "Collection Agent"::Bank);
            SetRange("Bill Gr./Pmt. Order No.", '');
            Find('-');
            FinanceCoType := "Collection Agent"::Bank;
            PmtOrdNo := PmtOrd."No.";
            for i := 1 to 2 do begin
                TestField("Collection Agent", FinanceCoType);
                TestField("Bill Gr./Pmt. Order No.", '');
                TestField("Currency Code", '');
                TestField(Type, Type::Payable);
                if Accepted = Accepted::No then
                    FieldError(Accepted);
                OldDoc := Doc;
                "Collection Agent" := FinanceCoType;
                "Bill Gr./Pmt. Order No." := PmtOrdNo;
                Modify();
                Doc := OldDoc;
                Doc.Next();
            end;
            Reset();
            SetRange(Type, Type::Payable);
            SetRange("Document Type", "Document Type"::Invoice);
            SetRange("Collection Agent", "Collection Agent"::Bank);
            SetRange("Bill Gr./Pmt. Order No.", '');
            Find('-');
            FinanceCoType := "Collection Agent"::Bank;
            PmtOrdNo := PmtOrd."No.";
            for i := 1 to 1 do begin
                TestField("Collection Agent", FinanceCoType);
                TestField("Bill Gr./Pmt. Order No.", '');
                TestField("Currency Code", '');
                TestField(Type, Type::Payable);
                if Accepted = Accepted::No then
                    FieldError(Accepted);
                OldDoc := Doc;
                "Collection Agent" := FinanceCoType;
                "Bill Gr./Pmt. Order No." := PmtOrdNo;
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

        // Post group
        PmtOrd.SetRecFilter();
        PostPmtOrd.SetHidePrintDialog(true);
        PostPmtOrd.SetTableView(PmtOrd);
        PostPmtOrd.UseRequestPage(false);
        PostPmtOrd.InitReqForm(XCARTERA, XDEFAULT);
        PostPmtOrd.RunModal();

        Clear(PostPmtOrd);

        // Create one more group
        InsertData(XWWBEUR, CalcDate('<CY-2Y+2M+1D>'));

        // Insert Docs. in new payment order
        with Doc do begin
            Reset();
            SetRange(Type, Type::Payable);
            SetRange("Document Type", "Document Type"::Bill);
            SetRange("Collection Agent", "Collection Agent"::Bank);
            SetRange("Bill Gr./Pmt. Order No.", '');
            Find('-');
            FinanceCoType := "Collection Agent"::Bank;
            PmtOrdNo := PmtOrd."No.";
            for i := 1 to 2 do begin
                TestField("Collection Agent", FinanceCoType);
                TestField("Bill Gr./Pmt. Order No.", '');
                TestField("Currency Code", '');
                TestField(Type, Type::Payable);
                if Accepted = Accepted::No then
                    FieldError(Accepted);
                OldDoc := Doc;
                "Collection Agent" := FinanceCoType;
                "Bill Gr./Pmt. Order No." := PmtOrdNo;
                Modify();
                Doc := OldDoc;
                Doc.Next();
            end;
        end;

        // Post group
        PmtOrd.SetRecFilter();
        PostPmtOrd.SetHidePrintDialog(true);
        PostPmtOrd.SetTableView(PmtOrd);
        PostPmtOrd.UseRequestPage(false);
        PostPmtOrd.InitReqForm(XCARTERA, XDEFAULT);
        PostPmtOrd.RunModal();

        // Create one more group
        InsertData(XNBL, CalcDate('<CY-2Y+2M+1D>'));

        // Insert Docs. in new payment order
        with Doc do begin
            Reset();
            SetRange(Type, Type::Payable);
            SetRange("Document Type", "Document Type"::Bill);
            SetRange("Collection Agent", "Collection Agent"::Bank);
            SetRange("Bill Gr./Pmt. Order No.", '');
            Find('-');
            FinanceCoType := "Collection Agent"::Bank;
            PmtOrdNo := PmtOrd."No.";
            for i := 1 to 2 do begin
                TestField("Collection Agent", FinanceCoType);
                TestField("Bill Gr./Pmt. Order No.", '');
                TestField("Currency Code", '');
                TestField(Type, Type::Payable);
                if Accepted = Accepted::No then
                    FieldError(Accepted);
                OldDoc := Doc;
                "Collection Agent" := FinanceCoType;
                "Bill Gr./Pmt. Order No." := PmtOrdNo;
                Modify();
                Doc := OldDoc;
                Doc.Next();
            end;
        end;

        // Post settlement
        WorkDate(20080124D);
        PostedDoc.SetRange("Bill Gr./Pmt. Order No.", '109001');
        PostedDoc.Find('-');
        SettleDocsInPostedPO.SetHidePrintDialog(true);
        SettleDocsInPostedPO.SetTableView(PostedDoc);
        SettleDocsInPostedPO.UseRequestPage(false);
        SettleDocsInPostedPO.RunModal();

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
        PmtOrdNo: Code[20];
        i: Integer;
        PmtOrd: Record "Payment Order";
        PostPmtOrd: Report "Post Payment Order";
        SettleDocsInPostedPO: Report "Settle Docs. in Posted PO";
        PostedDoc: Record "Posted Cartera Doc.";
        GenJnlLine: Record "Gen. Journal Line";
        CGCta: Record "G/L Account";
        DemoDataSetup: Record "Demo Data Setup";
        XNBL: Label 'NBL';
        XCARTERA: Label 'CARTERA';
        XDEFAULT: Label 'DEFAULT';
        XWWBEUR: Label 'WWB-EUR';
        XPAYMENT: Label 'PAYMENT';
        XLewisHomeFurniture: Label 'Lewis Home Furniture';
        XEH: Label 'EH';
        XBANK: Label 'BANK';
        XPAYMENTJNL: Label 'PAYMENTJNL';
        XBANKBILLGROUP: Label 'Bank Bill Group %1';

    procedure InsertData("Company No.": Code[20]; "Posting Date": Date)
    begin
        Clear(PmtOrd);
        PmtOrd.Validate("No.", '');
        PmtOrd."Posting Date" := "Posting Date";
        PmtOrd.Insert(true);
        // PmtOrd."Posting Description" := 'Bank Bill Group ' + PmtOrd."No.";
        PmtOrd."Posting Description" := StrSubstNo(XBANKBILLGROUP, PmtOrd."No.");
        PmtOrd."Bank Account No." := "Company No.";
        PmtOrd.Validate("Bank Account No.", "Company No.");
        PmtOrd.Validate("Posting Date", "Posting Date");
        PmtOrd.Modify();
    end;

    procedure SettlePayableDoc()
    var
        Doc2: Record "Cartera Doc.";
        GenJnlLine2: Record "Gen. Journal Line";
    begin
        with Doc2 do begin
            Reset();
            SetRange(Type, Type::Payable);
            SetRange("Document Type", "Document Type"::Bill);
            SetRange("Collection Agent", "Collection Agent"::Bank);
            SetRange("Bill Gr./Pmt. Order No.", '');
            Find('-');
        end;
        with GenJnlLine2 do begin
            Init();
            Validate("Journal Template Name", XPAYMENT);
            Validate("Line No.", 10000);
            Validate("Account Type", "Account Type"::Vendor);
            Validate("Account No.", Doc2."Account No.");
            Validate("Posting Date", Doc2."Posting Date");
            Validate("Document Type", "Document Type"::Payment);
            Validate("Document No.", 'G04001');
            Validate(Description, XLewisHomeFurniture);
            Validate(Amount, Doc2."Remaining Amount");
            Validate("Posting Group", DemoDataSetup.DomesticCode);
            Validate("Salespers./Purch. Code", XEH);
            Validate("Source Code", XPAYMENTJNL);
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
        end;

        GJPostLine.SetFromSettlement(true);
        GJPostLine.Run(GenJnlLine2);

        // GJPostLine.RUN(GenJnlLine2);
        Clear(GJPostLine);
    end;
}

