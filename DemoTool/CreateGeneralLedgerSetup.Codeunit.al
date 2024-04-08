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
            // NAVCZ
            "Closed Per. Entry Pos.Date CZL" := CA.AdjustDate(19020101D);
            "Create No. Series".InitBaseSeries2("Cash Desk Nos. CZP", XCD, XCashDesk, 'POK01', 'POK99', '', '', 1);
            "Create No. Series".InitBaseSeries2(
                "Acc. Schedule Results Nos. CZL", XASRESULTS, XResultsOfAccountingSchedules, 'USV00001', 'USV99999', '', '', 1);
            "Mark Cr. Memos as Corrections" := true;
            "Mark Neg. Qty as Correct. CZL" := true;
            "Check G/L Account Usage" := true;
            "Check Posting Debit/Credit CZL" := true;
            "Print VAT specification in LCY" := true;
            "Max. VAT Difference Allowed" := 0.5;
            // NAVCZ
            "EMU Currency" := DemoDataSetup."LCY an EMU Currency";
            "Local Address Format" := "Local Address Format"::"Post Code+City";
            "Show Amounts" := "Show Amounts"::"Amount Only";
            Modify();
        end;
        VATRegistrationLogMgt.InitServiceSetup;
        RegistrationLogMgtCZL.InitServiceSetup(); // NAVCZ
    end;

    var
        "General Ledger Setup": Record "General Ledger Setup";
        DemoDataSetup: Record "Demo Data Setup";
        Currency: Record Currency;
        "Create No. Series": Codeunit "Create No. Series";
        RegistrationLogMgtCZL: Codeunit "Registration Log Mgt. CZL";
        VATRegistrationLogMgt: Codeunit "VAT Registration Log Mgt.";
        XDEPARTMENT: Label 'DEPARTMENT';
        XPROJECT: Label 'PROJECT';
        XCUSTOMERGROUP: Label 'CUSTOMERGROUP';
        XAREA: Label 'AREA';
        XBUSINESSGROUP: Label 'BUSINESSGROUP';
        XSALESCAMPAIGN: Label 'SALESCAMPAIGN';
        XBANK: Label 'BANK';
        XB10: Label 'B10';
        XCD: Label 'CD';
        XCashDesk: Label 'Cash Desk';
        XASRESULTS: Label 'AS-RES';
        XResultsOfAccountingSchedules: Label 'Results of Acc. Schedules';
        CA: Codeunit "Make Adjustments";

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
            Validate("Adjust for Payment Disc.", false);
            "Create No. Series".InitBaseSeries("Bank Account Nos.", XBANK, XBANK, XB10, 'B990', '', '', 10, true);
            "EMU Currency" := DemoDataSetup."LCY an EMU Currency";
            "Local Cont. Addr. Format" := "Local Cont. Addr. Format"::"After Company Name";
            "Local Address Format" := "Local Address Format"::"Post Code+City";
            "Show Amounts" := "Show Amounts"::"Amount Only";
            // NAVCZ
            "Mark Cr. Memos as Corrections" := true;
            "Mark Neg. Qty as Correct. CZL" := true;
            "Max. VAT Difference Allowed" := 0.5;
            "Check G/L Account Usage" := true;
            "Print VAT specification in LCY" := true;
            "Create No. Series".InitBaseSeries2("Cash Desk Nos. CZP", XCD, XCashDesk, 'POK01', 'POK99', '', '', 1);
            "Closed Per. Entry Pos.Date CZL" := CA.AdjustDate(19020101D);
            "Create No. Series".InitBaseSeries2(
                "Acc. Schedule Results Nos. CZL", XASRESULTS, XResultsOfAccountingSchedules, 'USV00001', 'USV99999', '', '', 1);
#if not CLEAN22
#pragma warning disable AL0432
            "Use VAT Date CZL" := true;
#pragma warning restore AL0432
#endif
            "VAT Reporting Date Usage" := "VAT Reporting Date Usage"::"Enabled (Prevent modification)";
            "Def. Orig. Doc. VAT Date CZL" := "Def. Orig. Doc. VAT Date CZL"::"Posting Date";
            "Check Posting Debit/Credit CZL" := true;
            "Do Not Check Dimensions CZL" := true;
            // NAVCZ
            Modify();
        end;
        VATRegistrationLogMgt.InitServiceSetup;
        RegistrationLogMgtCZL.InitServiceSetup(); // NAVCZ
    end;

    procedure InsertEvaluationData()
    begin
        with "General Ledger Setup" do begin
            Get();
            Validate("Global Dimension 1 Code", XDEPARTMENT);
            Validate("Global Dimension 2 Code", XCUSTOMERGROUP);
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

