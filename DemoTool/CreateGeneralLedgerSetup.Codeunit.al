﻿codeunit 101098 "Create General Ledger Setup"
{

    trigger OnRun()
    begin
        DemoDataSetup.Get();
        Currency.Get(DemoDataSetup."Currency Code");
        "General Ledger Setup".Get();
        UpdateFromCurrency();

        "General Ledger Setup".Validate("Allow Posting From", 0D);
        "General Ledger Setup".Validate("Allow Posting To", 0D);
        if DemoDataSetup."Advanced Setup" then begin
            "General Ledger Setup".Validate("Unrealized VAT", true);
            if DemoDataSetup."Company Type" = DemoDataSetup."Company Type"::"Sales Tax" then
                "General Ledger Setup".Validate("Summarize G/L Entries", true);
        end;
        if DemoDataSetup."Adjust for Payment Discount" then
            "General Ledger Setup"."Payment Discount Type" := "General Ledger Setup"."Payment Discount Type"::"Adjust for Payment Disc."
        else
            "General Ledger Setup"."Payment Discount Type" := "General Ledger Setup"."Payment Discount Type"::"Calc. Pmt. Disc. on Lines";
        "General Ledger Setup"."Discount Calculation" := "General Ledger Setup"."Discount Calculation"::"Line Disc. * Inv. Disc. * Payment Disc.";
        "General Ledger Setup".Validate("Global Dimension 1 Code", XDEPARTMENT);
        "General Ledger Setup".Validate("Global Dimension 2 Code", XPROJECT);
        "General Ledger Setup".Validate("Shortcut Dimension 3 Code", XCUSTOMERGROUP);
        "General Ledger Setup".Validate("Shortcut Dimension 4 Code", XAREA);
        "General Ledger Setup".Validate("Shortcut Dimension 5 Code", XBUSINESSGROUP);
        "General Ledger Setup".Validate("Shortcut Dimension 6 Code", XSALESCAMPAIGN);

        if DemoDataSetup."Additional Currency Code" <> '' then
            "General Ledger Setup"."Additional Reporting Currency" := DemoDataSetup."Additional Currency Code";

        "General Ledger Setup"."Enable Data Check" := true;
        "General Ledger Setup"."Tax Invoice Renaming Threshold" := 0;
        "Create No. Series".InitBaseSeries("General Ledger Setup"."Bank Account Nos.", XBANK, XBANK, XB10, 'B990', '', '', 10, Enum::"No. Series Implementation"::Sequence);
        "Create No. Series".InitBaseSeries("General Ledger Setup"."Autoinvoice Nos.", XAUTINV, XAutoInvoice, XAUTINV10, XAUTINV990, '', '', 1);
        "Create No. Series".InitBaseSeries("General Ledger Setup"."Autocredit Memo Nos.", XAUTCR, XAutoCreditMemo, XAUTCR10, XAUTCR990, '', '', 1);
        "General Ledger Setup"."EMU Currency" := DemoDataSetup."LCY an EMU Currency";
        "General Ledger Setup"."Local Address Format" := "General Ledger Setup"."Local Address Format"::"Post Code+City";
        "General Ledger Setup"."Show Amounts" := "General Ledger Setup"."Show Amounts"::"Debit/Credit Only";
        "General Ledger Setup".Modify();
        VATRegistrationLogMgt.InitServiceSetup();
    end;

    var
        "General Ledger Setup": Record "General Ledger Setup";
        DemoDataSetup: Record "Demo Data Setup";
        Currency: Record Currency;
        "Create No. Series": Codeunit "Create No. Series";
        VATRegistrationLogMgt: Codeunit "VAT Registration Log Mgt.";
        XDEPARTMENT: Label 'DEPARTMENT';
        XPROJECT: Label 'PROJECT';
        XCUSTOMERGROUP: Label 'CUSTOMERGROUP';
        XAREA: Label 'AREA';
        XBUSINESSGROUP: Label 'BUSINESSGROUP';
        XSALESCAMPAIGN: Label 'SALESCAMPAIGN';
        XBANK: Label 'BANK';
        XB10: Label 'B10';
        XAUTINV: Label 'AUT-INV';
        XAutoInvoice: Label 'AutoInvoice';
        XAUTCR: Label 'AUT-CR';
        XAutoCreditMemo: Label 'AutoCreditMemo';
        XAUTINV10: Label 'AUTINV10';
        XAUTINV990: Label 'AUTINV990';
        XAUTCR10: Label 'AUTCR10';
        XAUTCR990: Label 'AUTCR990';

    procedure InsertMiniAppData()
    begin
        DemoDataSetup.Get();
        Currency.Get(DemoDataSetup."Currency Code");
        "General Ledger Setup".Get();
        UpdateFromCurrency();

        "General Ledger Setup".Validate("Allow Posting From", 0D);
        "General Ledger Setup".Validate("Allow Posting To", 0D);
        "General Ledger Setup".Validate("Unrealized VAT", DemoDataSetup."Advanced Setup");
        "General Ledger Setup".Validate("Adjust for Payment Disc.", false);
        "Create No. Series".InitBaseSeries("General Ledger Setup"."Bank Account Nos.", XBANK, XBANK, XB10, 'B990', '', '', 10, Enum::"No. Series Implementation"::Sequence);
        "Create No. Series".InitBaseSeries("General Ledger Setup"."Autoinvoice Nos.", XAUTINV, XAutoInvoice, XAUTINV10, XAUTINV990, '', '', 1);
        "Create No. Series".InitBaseSeries("General Ledger Setup"."Autocredit Memo Nos.", XAUTCR, XAutoCreditMemo, XAUTCR10, XAUTCR990, '', '', 1);

        "General Ledger Setup"."EMU Currency" := DemoDataSetup."LCY an EMU Currency";
        "General Ledger Setup"."Local Cont. Addr. Format" := "General Ledger Setup"."Local Cont. Addr. Format"::"After Company Name";
        "General Ledger Setup"."Local Address Format" := "General Ledger Setup"."Local Address Format"::"Post Code+City";
        "General Ledger Setup"."Show Amounts" := "General Ledger Setup"."Show Amounts"::"Debit/Credit Only";
        "General Ledger Setup"."Enable Data Check" := true;
        "General Ledger Setup".Modify();
        VATRegistrationLogMgt.InitServiceSetup();
    end;

    procedure InsertEvaluationData()
    begin
        "General Ledger Setup".Get();
        "General Ledger Setup".Validate("Global Dimension 1 Code", XDEPARTMENT);
        "General Ledger Setup".Validate("Global Dimension 2 Code", XCUSTOMERGROUP);
        "General Ledger Setup".Modify();
    end;

    local procedure UpdateFromCurrency()
    begin
        "General Ledger Setup".Validate("Inv. Rounding Precision (LCY)", Currency."Invoice Rounding Precision");
        "General Ledger Setup"."Amount Rounding Precision" := Currency."Amount Rounding Precision";
        "General Ledger Setup"."Unit-Amount Rounding Precision" := Currency."Unit-Amount Rounding Precision";
        "General Ledger Setup"."Amount Decimal Places" := Currency."Amount Decimal Places";
        "General Ledger Setup"."Unit-Amount Decimal Places" := Currency."Unit-Amount Decimal Places";
        "General Ledger Setup".Validate("LCY Code", Currency.Code);
    end;
}

