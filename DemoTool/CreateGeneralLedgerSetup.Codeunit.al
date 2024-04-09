codeunit 101098 "Create General Ledger Setup"
{

    trigger OnRun()
    begin
        DemoDataSetup.Get();
        Currency.Get(DemoDataSetup."Currency Code");
        with "General Ledger Setup" do begin
            Get();
            UpdateFromCurrency;

            Validate("Allow Posting From", 0D);
            Validate("Allow Posting To", 0D);
            if DemoDataSetup."Advanced Setup" then begin
                Validate("Unrealized VAT", true);
                if DemoDataSetup."Company Type" = DemoDataSetup."Company Type"::"Sales Tax" then
                    Validate("Summarize G/L Entries", true);
            end;
            Validate("Adjust for Payment Disc.", DemoDataSetup."Adjust for Payment Discount");
            Validate("Global Dimension 1 Code", XDEPARTMENT);
            Validate("Global Dimension 2 Code", XPROJECT);
            Validate("Shortcut Dimension 3 Code", XCUSTOMERGROUP);
            Validate("Shortcut Dimension 4 Code", XAREA);
            Validate("Shortcut Dimension 5 Code", XBUSINESSGROUP);
            Validate("Shortcut Dimension 6 Code", XSALESCAMPAIGN);

            if DemoDataSetup."Additional Currency Code" <> '' then
                "Additional Reporting Currency" := DemoDataSetup."Additional Currency Code";

            "Tax Invoice Renaming Threshold" := 0;
            "Create No. Series".InitBaseSeries("Bank Account Nos.", XBANK, XBANK, XB10, 'B990', '', '', 10, true);
            "EMU Currency" := DemoDataSetup."LCY an EMU Currency";
            "Local Address Format" := "Local Address Format"::"City+County+Post Code";
            "Show Amounts" := "Show Amounts"::"Amount Only";
            "Create No. Series".InitBaseSeries("Deposit Nos.", Text001, Text002, Text003, Text004, '', '', 1);
            "Create No. Series".InitBaseSeries("Bank Rec. Adj. Doc. Nos.", Text005, Text006, Text007, Text008, '', '', 1);
            Modify();
        end;
        VATRegistrationLogMgt.InitServiceSetup;
    end;

    var
        Text000: Label 'B990';
        Text001: Label 'BANKDEP';
        Text002: Label 'Bank Deposit';
        Text003: Label 'BDEP1001';
        Text004: Label 'BDEP10999';
        Text005: Label 'BANKRECADJ';
        Text006: Label 'Bank Rec Adjustment';
        Text007: Label 'BR1001';
        Text008: Label 'BDEP10099';
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

    procedure InsertMiniAppData()
    begin
        DemoDataSetup.Get();
        Currency.Get(DemoDataSetup."Currency Code");
        with "General Ledger Setup" do begin
            Get();
            UpdateFromCurrency;

            Validate("Allow Posting From", 0D);
            Validate("Allow Posting To", 0D);
            Validate("Unrealized VAT", DemoDataSetup."Advanced Setup");
            Validate("Adjust for Payment Disc.", true);
            Validate("Payment Tolerance %", 0.1);
            Validate("Max. Payment Tolerance Amount", 1);
            "Create No. Series".InitBaseSeries("Bank Account Nos.", XBANK, XBANK, XB10, 'B990', '', '', 10, true);
            "EMU Currency" := DemoDataSetup."LCY an EMU Currency";
            "Local Cont. Addr. Format" := "Local Cont. Addr. Format"::"After Company Name";
            "Local Address Format" := "Local Address Format"::"City+County+Post Code";
            "Show Amounts" := "Show Amounts"::"Amount Only";
            Modify();
        end;
        VATRegistrationLogMgt.InitServiceSetup;
    end;

    procedure InsertEvaluationData()
    begin
        with "General Ledger Setup" do begin
            Get();
            Validate("Global Dimension 1 Code", XDEPARTMENT);
            Validate("Global Dimension 2 Code", XCUSTOMERGROUP);
            "Max. VAT Difference Allowed" := 10;
            Modify();
        end;
    end;

    local procedure UpdateFromCurrency()
    begin
        with "General Ledger Setup" do begin
            Validate("Inv. Rounding Precision (LCY)", Currency."Invoice Rounding Precision");
            "Amount Rounding Precision" := Currency."Amount Rounding Precision";
            "Unit-Amount Rounding Precision" := Currency."Unit-Amount Rounding Precision";
            "Amount Decimal Places" := Currency."Amount Decimal Places";
            "Unit-Amount Decimal Places" := Currency."Unit-Amount Decimal Places";
            Validate("LCY Code", Currency.Code);
        end;
    end;
}

