codeunit 101270 "Create Bank Account"
{

    trigger OnRun()
    begin
        DemoDataSetup.Get();
        if DemoDataSetup."Data Type" = DemoDataSetup."Data Type"::Extended then begin
            InsertData(
              XNBL, XNewBankofLondon, X4BakerStreet, CreatePostCode.Convert('GB-W1 3AL'),
              //XHollyDickson,'',XLCY,'78-66-345','NB54366','');
              XHollyDickson, '', XLCY, '12345678907', '12345', '', '00352', 85);
            InsertData(
              XWWBEUR, XWorldWideBank, X1HighHolborn, CreatePostCode.Convert('GB-WC1 3DG'),
              //XGrantCulbertson,XEUR,XCURRENCIES,'99-33-456','BG99999',XGB80RBOS16173241116737);
              XGrantCulbertson, XEUR, XCURRENCIES, '98765432105', '00987', XGB80RBOS16173241116737, '12356', 72);
            SetSEPAExport();
            InsertData(
              XWWBOPERATING, XWorldWideBank, X1HighHolborn, CreatePostCode.Convert('GB-WC1 3DG'),
              //XGrantCulbertson,'',XOPERATING,'99-99-888','BG99999','');
              XGrantCulbertson, '', XOPERATING, '98765432105', '00987', '', '12356', 72);
            InsertData(
              XWWBUSD, XWorldWideBank, X1HighHolborn, CreatePostCode.Convert('GB-WC1 3DG'),
              //XGrantCulbertson,XUSD,XCURRENCIES,'99-44-567','BG99999','');
              XGrantCulbertson, XUSD, XCURRENCIES, '98765432105', '00987', '', '12356', 72);
            InsertData(
              XWWBTRANSFERSTxt, XWorldWideBank, X1HighHolborn, CreatePostCode.Convert('GB-WC1 3DG'),
              XGrantCulbertson, XGBPTok, XCURRENCIES, '99-44-567', 'BG99999', '', '12356', 72);
            InsertData(
              XGIRO, XGiroBank, X2BridgeStreet, CreatePostCode.Convert('GB-W1 3AL'),
              //XPaulaNartker,'',XLCY2,'14-55-678','GO284033',XGB80RBOS16173241116737);
              XPaulaNartker, '', XLCY2, '12345678908', '30345', XGB80RBOS16173241116737, '00752', 51);

            // Modif Demo Finance (CM) : ajout du code compte bancaire par d¾faut de la soci¾t¾
            "Company Information".Get();
            "Company Information".Validate("Default Bank Account No.", XNBL);
            "Company Information".Modify();
        end else begin
            InsertData(
              XCHECKING, XWorldWideBank, X1HighHolborn, CreatePostCode.Convert('GB-WC1 3DG'),
              XGrantCulbertson, '', XCHECKING, '98765432105', '00987', '', '12356', 72);
            SetAsBalAccOnGenJnlBatch(XCHECKING);
            InsertData(
              XSAVINGS, XWorldWideBank, X1HighHolborn, CreatePostCode.Convert('GB-WC1 3DG'),
              XGrantCulbertson, '', XSAVINGS, '98765432105', '00987', '', '12356', 72);
        end;
    end;

    var
        BankAcc: Record "Bank Account";
        DemoDataSetup: Record "Demo Data Setup";
        CA: Codeunit "Make Adjustments";
        CreatePostCode: Codeunit "Create Post Code";
        XSEPACTMSGTxt: Label 'SEPACT-MSG', Comment = 'SEPA Credit Transfer Message';
        XSEPACTMessageIDTxt: Label 'SEPA Credit Transfer Msg. ID', Comment = 'Msg. = Message';
        XSEPADDMSGTxt: Label 'SEPADD-MSG', Comment = 'SEPA Direct Debit Message';
        XSEPADDMessageIDTxt: Label 'SEPA Direct Debit Msg. ID', Comment = 'Msg. = Message';
        XNBL: Label 'NBL';
        XNewBankofLondon: Label 'New Bank of London';
        X4BakerStreet: Label '4 Baker Street';
        XHollyDickson: Label 'Holly Dickson';
        XLCY: Label 'LCY';
        XWWBEUR: Label 'WWB-EUR';
        XWorldWideBank: Label 'World Wide Bank';
        X1HighHolborn: Label '1 High Holborn';
        XGrantCulbertson: Label 'Grant Culbertson';
        XEUR: Label 'EUR';
        XCURRENCIES: Label 'CURRENCIES';
        XWWBOPERATING: Label 'WWB-OPERATING';
        XOPERATING: Label 'OPERATING';
        XWWBUSD: Label 'WWB-USD';
        XUSD: Label 'USD';
        XGBPTok: Label 'GBP', Locked = true;
        XGIRO: Label 'GIRO';
        XGiroBank: Label 'Giro Bank';
        X2BridgeStreet: Label '2 Bridge Street';
        XPaulaNartker: Label 'Paula Nartker';
        XLCY2: Label 'LCY2';
        XOF: Label 'OF';
        XGB80RBOS16173241116737: Label 'GB 80 RBOS 161732 41116737';
        "Company Information": Record "Company Information";
        XWWBTRANSFERSTxt: Label 'WWB-TRANSFERS', Locked = true;
        XSEPACAMTImpFmtTxt: Label 'SEPA CAMT', Locked = true;
        XCHECKING: Label 'CHECKING', Comment = 'To be translated.', MaxLength = 20;
        XSAVINGS: Label 'SAVINGS', Comment = 'To be translated.', MaxLength = 20;
        PmtRecNoSeriesTok: Label 'PREC', Locked = true;
        PmtRecNoSeriesDescriptionTxt: Label 'Payment Reconciliation Journals';
        PmtRecNoSeriesStartNoTok: Label 'PREC001', Locked = true;
        PmtRecNoSeriesEndNoTok: Label 'PREC999', Locked = true;

    procedure InsertData("No.": Code[20]; Name: Text[30]; Address: Text[30]; "Post Code": Text[30]; Contact: Text[30]; "Currency Code": Code[10]; "Posting Group": Code[20]; "Bank Account No.": Text[30]; "Bank Branch No.": Text[20]; IBAN: Code[50]; "Agency Code": Text[20]; "RIB Key": Integer)
    var
        "Create No. Series": Codeunit "Create No. Series";
    begin
        BankAcc.Init();
        BankAcc.Validate("No.", "No.");
        BankAcc.Validate(Name, Name);
        BankAcc.Validate(Address, Address);
        BankAcc."Post Code" := CreatePostCode.FindPostCode("Post Code");
        BankAcc.City := CreatePostCode.FindCity("Post Code");
        BankAcc.Validate(Contact, Contact);
        DemoDataSetup.Get();
        if "Currency Code" = DemoDataSetup."Currency Code" then
            "Currency Code" := '';
        BankAcc.Validate("Currency Code", "Currency Code");
        BankAcc.Validate("Bank Acc. Posting Group", "Posting Group");
        BankAcc.Validate("Bank Branch No.", "Bank Branch No.");
        BankAcc.Validate("Bank Account No.", "Bank Account No.");
        BankAcc.Validate(IBAN, IBAN);
        BankAcc.Validate("Statistics Group", 0);
        BankAcc.Validate("Last Date Modified", CA.AdjustDate(19030118D));
        // Modif Demo Finance (CM) : ajout du code guichet et de la cl¦ rib
        BankAcc.Validate("Agency Code", "Agency Code");
        BankAcc.Validate("RIB Key", "RIB Key");
        case BankAcc."No." of
            XWWBOPERATING,
            XCHECKING:
                begin
                    BankAcc.Validate(
                      "Min. Balance",
                      Round(
                        -8000000 * DemoDataSetup."Local Currency Factor",
                        1000 * DemoDataSetup."Local Precision Factor"));
                    BankAcc.Validate("Bank Statement Import Format", XSEPACAMTImpFmtTxt);
                    "Create No. Series".InitBaseSeries(BankAcc."Pmt. Rec. No. Series", PmtRecNoSeriesTok, PmtRecNoSeriesDescriptionTxt, PmtRecNoSeriesStartNoTok, PmtRecNoSeriesEndNoTok, PmtRecNoSeriesStartNoTok, '', 1, Enum::"No. Series Implementation"::Sequence);
                    BankAcc."Last Check No." := '199';
                    BankAcc."Last Statement No." := '23';
                end;
            XNBL:
                BankAcc."Last Statement No." := '4';
        end;

        BankAcc.Validate("Our Contact Code", XOF);

        BankAcc.Insert(true);
    end;

    internal procedure GetSavingsBankAccountCode(): Code[20]
    begin
        exit(XSAVINGS);
    end;

    internal procedure GetCheckingBankAccountCode(): Code[20]
    begin
        exit(XCHECKING);
    end;

    local procedure SetSEPAExport()
    var
        CreateNoSeries: Codeunit "Create No. Series";
        CompanyInitialize: Codeunit "Company-Initialize";
    begin
        BankAcc."Payment Export Format" := CompanyInitialize.GetSEPACT09Code();
        CreateNoSeries.InitTempSeries(BankAcc."Credit Transfer Msg. Nos.", XSEPACTMSGTxt, XSEPACTMessageIDTxt);
        BankAcc."SEPA Direct Debit Exp. Format" := CompanyInitialize.GetSEPADD08Code();
        CreateNoSeries.InitTempSeries(BankAcc."Direct Debit Msg. Nos.", XSEPADDMSGTxt, XSEPADDMessageIDTxt);
        BankAcc.Modify();
    end;

    local procedure SetAsBalAccOnGenJnlBatch(BankAccountNo: Code[20])
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        GenJournalBatch.SetRange("Bal. Account Type", GenJournalBatch."Bal. Account Type"::"Bank Account");
        GenJournalBatch.SetRange("Bal. Account No.", '');
        GenJournalBatch.ModifyAll("Bal. Account No.", BankAccountNo, true);
    end;
}
