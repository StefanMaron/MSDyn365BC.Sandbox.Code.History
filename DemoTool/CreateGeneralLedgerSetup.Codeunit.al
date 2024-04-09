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
            "Local Address Format" := "Local Address Format"::"Post Code+City";
            "Show Amounts" := "Show Amounts"::"Amount Only";
            Validate("LCY Code", XLCY);
            Modify();
            UpdateGeneralLedgerSetup(
                XGSTDist, XGSTCreditAdjJnlNos, XGSTSettlementNos, 0);
        end;
        VATRegistrationLogMgt.InitServiceSetup;
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
        XB10: Label 'B10', Locked = true;
        XLCY: Label 'INR', Locked = true;
        XGSTDist: Label 'P-D-INV', Locked = true;
        XGSTCreditAdjJnlNos: Label 'GST-CR-JNL', Locked = true;
        XGSTSettlementNos: Label 'GST-SETTLE', Locked = true;
        XGSTInvRoundingType: Enum "GST Inv Rounding Type";
        XLCYSymbol: Label '₹', Locked = true;
        XLCYCurrencyDescription: Label 'Indian Rupees';
        XTCSIH: Label 'TCS-IH', Locked = true;

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
            Validate("LCY Code", XLCY);
            Modify();
            UpdateGeneralLedgerSetup(
                XGSTDist, XGSTCreditAdjJnlNos, XGSTSettlementNos, 0);
        end;
        VATRegistrationLogMgt.InitServiceSetup;
    end;

    procedure InsertEvaluationData()
    begin
        with "General Ledger Setup" do begin
            Get();
            Validate("Global Dimension 1 Code", XDEPARTMENT);
            Validate("Global Dimension 2 Code", XCUSTOMERGROUP);
            Validate("LCY Code", XLCY);
            "Local Currency Symbol" := XLCYSymbol;
            Modify();
            UpdateGeneralLedgerSetup(
                XGSTDist, XGSTCreditAdjJnlNos, XGSTSettlementNos, 0);
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

    procedure UpdateGeneralLedgerSetup(GSTDistribution: Code[10]; GSTCreditAdj: code[10]; GSTSettlement: Code[10]; GSTReconTol: Decimal);
    var
        GenLedgerSetup: Record "General Ledger Setup";
        "Create No. Series": Codeunit "Create No. Series";
    begin
        if GenLedgerSetup.Get() then begin
            GenLedgerSetup."GST Distribution Nos." := GSTDistribution;
            GenLedgerSetup."GST Credit Adj. Jnl Nos." := GSTCreditAdj;
            GenLedgerSetup."GST Settlement Nos." := GSTSettlement;
            GenLedgerSetup."GST Recon. Tolerance" := GSTReconTol;
            GenLedgerSetup."Local Currency Symbol" := XLCYSymbol;
            GenLedgerSetup."Local Currency Description" := XLCYCurrencyDescription;
            if GenLedgerSetup."TCS Debit Note No." = '' then
                "Create No. Series".InsertSeries(GenLedgerSetup."TCS Debit Note No.", XTCSIH, XTCSIH, 'XTCSI00001', '', '', '', 1, true);
            GenLedgerSetup.Modify();
        end;
    end;
}

