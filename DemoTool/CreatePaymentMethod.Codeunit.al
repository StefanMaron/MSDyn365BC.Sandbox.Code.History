codeunit 101289 "Create Payment Method"
{

    trigger OnRun()
    begin
        with "Payment Method" do begin
            // InsertData(XGIRO,XGirotransfer,"Bal. Account Type"::"Bank Account",XGIRO);
            // InsertData(XBANK,XBanktransfer,0,'');
            // InsertData(XCASH,XCashpayment,"Bal. Account Type"::"G/L Account",'992910');
            // InsertData(XCHECK,XCheckpayment,0,'');
            // InsertData(XACCOUNT,XPaymentonaccount,0,'');
            // InsertData(XINTERCOM,XIntercompanypayment,0,'');
            InsertData(XGIRO, XGirotransfer, "Bal. Account Type"::"Bank Account", XGIRO, false, 0, false, 0, false, '');
            InsertData(XBANK, XBanktransfer, 0, '', false, 0, false, 0, false, '');
            InsertData(XBANKDOMTxt, XBankDomTransferTxt, 0, '', false, 0, false, 0, false, XBankDataConvPmtLineDefnTxt);
            InsertData(XBANKINTTxt, XBankIntTransferTxt, 0, '', false, 0, false, 0, false, XBankDataConvPmtLineDefnTxt);
            InsertData(XCASH, XCashpayment, "Bal. Account Type"::"G/L Account", '992910', false, 0, false, 0, false, '');
            InsertData(XCHECK, XCheckpayment, 0, '', false, 0, false, 0, false, '');
            InsertData(XACCOUNT, XPaymentonaccount, 0, '', false, 0, false, 0, false, '');
            InsertData(XINTERCOM, XIntercompanypayment, 0, '', false, 0, false, 0, false, '');
            InsertData(XAGENTE, XCollectionAssistant, 0, '', true, 1, false, 0, false, '');
            InsertData(XEFECTO, XNegotiableBill, 1, '', true, 1, false, 1, false, '');
            InsertData(XLETRA, XAcceptanceBill, 1, '', true, 1, true, 1, false, '');
            InsertData(XPAGARE, XPromissoryNote, 1, '', true, 1, false, 3, false, '');
            InsertData(XReceipt, XReceipt, 1, '', true, 1, false, 2, false, '');
            InsertData(XORDENPAGO, XPaymentOrder, 1, '', false, 1, false, 5, true, '');
            InsertData(XFactoring, XFactoring, 1, '', false, 1, false, 0, true, '');
            InsertData(XCARD, XCardpayment, 0, '', false, 0, false, 0, false, '');
            InsertData(XMultiple, XMultiplepaymentmethods, 0, '', false, 0, false, 0, false, '');
        end;
    end;

    var
        "Payment Method": Record "Payment Method";
        "G/L Account": Record "G/L Account";
        CA: Codeunit "Make Adjustments";
        XGIRO: Label 'GIRO';
        XGirotransfer: Label 'Giro transfer';
        XBANK: Label 'BANK';
        XBanktransfer: Label 'Bank Transfer';
        XBANKDOMTxt: Label 'BNKDOMCONV', Locked = true;
        XBankDomTransferTxt: Label 'Domestic Bank Transfer with Data Conversion';
        XBANKINTTxt: Label 'BNKINTCONV', Locked = true;
        XBankIntTransferTxt: Label 'International Bank Transfer with Data Conversion';
        XCASH: Label 'CASH';
        XCashpayment: Label 'Cash payment';
        XCHECK: Label 'CHECK';
        XCheckpayment: Label 'Check payment';
        XACCOUNT: Label 'ACCOUNT';
        XPaymentonaccount: Label 'Payment on account';
        XINTERCOM: Label 'INTERCOM';
        XIntercompanypayment: Label 'Intercompany payment';
        XAGENTE: Label 'AGENTE';
        XCollectionAssistant: Label 'Collection Assistant';
        XEFECTO: Label 'EFECTO';
        XNegotiableBill: Label 'Negotiable Bill';
        XLETRA: Label 'LETRA';
        XAcceptanceBill: Label 'Acceptance Bill';
        XPAGARE: Label 'PAGARE';
        XPromissoryNote: Label 'Promissory Note';
        XReceipt: Label 'Receipt';
        XORDENPAGO: Label 'ORDENPAGO';
        XPaymentOrder: Label 'Payment Order';
        XFactoring: Label 'Factoring';
        XBankDataConvPmtLineDefnTxt: Label 'BANKDATACONVSERVCT', Locked = true;
        XCARD: Label 'CARD', Comment = 'Card';
        XCardpayment: Label 'Card payment';
        XMultiple: Label 'MULTIPLE', Comment = 'Multiple payment methods';
        XMultiplepaymentmethods: Label 'Multiple payment methods';

    procedure InsertMiniAppData()
    begin
        with "Payment Method" do begin
            InsertData(XGIRO, XGirotransfer, "Bal. Account Type"::"Bank Account", '', false, 0, false, 0, false, '');
            InsertData(XBANK, XBanktransfer, 0, '', false, 0, false, 0, false, '');
            InsertData(XBANKDOMTxt, XBankDomTransferTxt, 0, '', false, 0, false, 0, false, XBankDataConvPmtLineDefnTxt);
            InsertData(XBANKINTTxt, XBankIntTransferTxt, 0, '', false, 0, false, 0, false, XBankDataConvPmtLineDefnTxt);
            InsertData(XCASH, XCashpayment, "Bal. Account Type"::"G/L Account", '992910', false, 0, false, 0, false, '');
            InsertData(XCHECK, XCheckpayment, 0, '', false, 0, false, 0, false, '');
            InsertData(XACCOUNT, XPaymentonaccount, 0, '', false, 0, false, 0, false, '');
            InsertData(XINTERCOM, XIntercompanypayment, 0, '', false, 0, false, 0, false, '');
            InsertData(XEFECTO, XNegotiableBill, 1, '', true, 1, false, 1, false, '');
            InsertData(XPAGARE, XPromissoryNote, 1, '', true, 1, false, 3, false, '');
            InsertData(XCARD, XCardpayment, 0, '', false, 0, false, 0, false, '');
            InsertData(XMultiple, XMultiplepaymentmethods, 0, '', false, 0, false, 0, false, '');
        end;
    end;

    procedure InsertData("Code": Code[10]; Description: Text[50]; "Bal. Account Type": Integer; "Bal. Account No.": Code[20]; "Create Bills": Boolean; "Company Type": Option; "Submit for Aceptance": Boolean; "Bill Type": Option; "Invoices to Cartera": Boolean; PmtExportLineDefn: Code[20])
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
        "Payment Method".Validate("Collection Agent", "Company Type");
        "Payment Method".Validate("Submit for Acceptance", "Submit for Aceptance");
        "Payment Method".Validate("Create Bills", "Create Bills");
        "Payment Method".Validate("Bill Type", "Bill Type");
        "Payment Method".Validate("Invoices to Cartera", "Invoices to Cartera");
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

