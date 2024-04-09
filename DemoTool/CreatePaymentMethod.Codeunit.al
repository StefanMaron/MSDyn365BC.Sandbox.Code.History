codeunit 101289 "Create Payment Method"
{

    trigger OnRun()
    begin
        with "Payment Method" do begin
            InsertData(XGIRO, XGirotransfer, "Bal. Account Type"::"Bank Account", XGIRO, '');
            InsertData(XBANK, XBanktransfer, 0, '', '');
            InsertData(XBANKDOMTxt, XBankDomTransferTxt, 0, '', XBankDataConvPmtLineDefnTxt);
            InsertData(XBANKINTTxt, XBankIntTransferTxt, 0, '', XBankDataConvPmtLineDefnTxt);
            InsertData(XCASH, XCashpayment, "Bal. Account Type"::"G/L Account", '992910', '');
            InsertData(XCHECK, XCheckpayment, 0, '', '');
            InsertData(XACCOUNT, XPaymentonaccount, 0, '', '');
            InsertData(XINTERCOM, XIntercompanypayment, 0, '', '');
            InsertData(XCARD, XCardpayment, 0, '', '');
            InsertData(XMultiple, XMultiplepaymentmethods, 0, '', '');
        end;
    end;

    var
        "Payment Method": Record "Payment Method";
        "G/L Account": Record "G/L Account";
        CreateGLAccount: Codeunit "Create G/L Account";
        CA: Codeunit "Make Adjustments";
        XGIRO: Label 'GIRO';
        XGirotransfer: Label 'Giro transfer';
        XBANK: Label 'BANK';
        XBanktransfer: Label 'Bank Transfer';
        XBANKDOMTxt: Label 'BNKCONVDOM', Locked = true;
        XBankDomTransferTxt: Label 'Bank Data Conversion for Domestic Banks';
        XBANKINTTxt: Label 'BNKCONVINT', Locked = true;
        XBankIntTransferTxt: Label 'Bank Data Conversion for International Banks';
        XCASH: Label 'CASH';
        XCashpayment: Label 'Cash payment';
        XCHECK: Label 'CHECK';
        XCheckpayment: Label 'Check payment';
        XACCOUNT: Label 'ACCOUNT';
        XPaymentonaccount: Label 'Payment on account';
        XINTERCOM: Label 'INTERCOM';
        XIntercompanypayment: Label 'Intercompany payment';
        XBankDataConvPmtLineDefnTxt: Label 'BANKDATACONVSERVCT', Locked = true;
        XCARD: Label 'CARD', Comment = 'Card';
        XCardpayment: Label 'Card payment';
        XMultiple: Label 'MULTIPLE', Comment = 'Multiple payment methods';
        XMultiplepaymentmethods: Label 'Multiple payment methods';

    procedure InsertMiniAppData()
    begin
        with "Payment Method" do begin
            InsertData(XGIRO, XGirotransfer, "Bal. Account Type"::"Bank Account", '', '');
            InsertData(XBANK, XBanktransfer, 0, '', '');
            InsertData(XBANKDOMTxt, XBankDomTransferTxt, 0, '', XBankDataConvPmtLineDefnTxt);
            InsertData(XBANKINTTxt, XBankIntTransferTxt, 0, '', XBankDataConvPmtLineDefnTxt);
            InsertData(XCASH, XCashpayment, "Bal. Account Type"::"G/L Account", CreateGLAccount.PettyCash(), '');
            InsertData(XCHECK, XCheckpayment, 0, '', '');
            InsertData(XACCOUNT, XPaymentonaccount, 0, '', '');
            InsertData(XINTERCOM, XIntercompanypayment, 0, '', '');
            InsertData(XCARD, XCardpayment, 0, '', '');
            InsertData(XMultiple, XMultiplepaymentmethods, 0, '', '');
        end;
    end;

    procedure InsertData("Code": Code[10]; Description: Text[50]; "Bal. Account Type": Integer; "Bal. Account No.": Code[20]; PmtExportLineDefn: Code[20])
    begin
        "Payment Method".Init();
        "Payment Method".Validate(Code, Code);
        "Payment Method".Validate(Description, Description);
        "Payment Method".Validate("Pmt. Export Line Definition", PmtExportLineDefn);
        if "Bal. Account No." <> '' then begin
            "Payment Method".Validate("Bal. Account Type", "Bal. Account Type");
            if "Payment Method"."Bal. Account Type" = "Payment Method"."Bal. Account Type"::"G/L Account" then
                "Bal. Account No." := CA.Convert("Bal. Account No.");
            "Payment Method".Validate("Bal. Account No.", "Bal. Account No.");

            if "Payment Method"."Bal. Account Type" = "Payment Method"."Bal. Account Type"::"G/L Account" then begin
                "G/L Account".Get("Payment Method"."Bal. Account No.");
                "G/L Account".TestField("Reconciliation Account");
            end;
        end;
        "Payment Method"."Use for Invoicing" := "Payment Method".Code in [XBANK, XCASH, XCHECK, XCARD, XMultiple];
        "Payment Method".Insert(true);
    end;

    procedure GetCashCode(): Code[10]
    begin
        exit(XCASH);
    end;

    procedure GetBankCode(): Code[10]
    begin
        exit(XBANK);
    end;
}

