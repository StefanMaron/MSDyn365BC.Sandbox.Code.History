codeunit 161558 "Create Demodata LSV"
{

    trigger OnRun()
    begin
        d.Open(Text11509);

        ClearLSVJournal;

        WriteSetup;
        ChangeCustomerBank;
        ModifyPaymentType;
        d.Close();
    end;

    var
        Text11509: Label 'Generate LSV demo data.';
        XGIRO: Label 'GIRO';
        Text11512: Label 'CRON2';
        Text11516: Label 'Dear Sir or Madam';
        Text11517: Label 'Next year we would like to reduce the administrative costs for payments ';
        Text11518: Label 'for you and us.  We ask you to please return this form ';
        Text11519: Label 'with the required information included and signed.';
        Text11520: Label 'Telekurs Payserv AG';
        Text11521: Label 'Computer Bureau';
        Text11522: Label 'Parcel Post Box';
        Text11523: Label 'Zürich 1';
        Text11524: Label 'Credit Suisse';
        Text11525: Label 'Bahnhofstrasse 17';
        Text11526: Label 'Zug';
        Text11529: Label 'Raiffeisenbank Alpnach';
        Text11530: Label 'Alpnach Dorf';
        Text11531: Label 'Obwaldner Kantonalbank';
        Text11532: Label 'Brünigstrasse';
        Text11533: Label 'Migrosbank Luzern';
        Text11534: Label 'Stadthofstrasse';
        Text11535: Label 'Luzern';
        Text11536: Label 'Coop Bank';
        Text11537: Label 'Luzerner Kantonalbank';
        Text11538: Label 'Customer with LSV Collection';
        XNBL: Label 'NBL';
        XSANDRSETUP: Label 'S&R-SETUP';
        XSANDRJOURNAL: Label 'S&R-JOURNAL';
        XSANDRJOURNALPOST: Label 'S&R-JOURNAL, POST';
        LsvSetup: Record "LSV Setup";
        CustomerBankAccount: Record "Customer Bank Account";
        PaymentMethod: Record "Payment Method";
        Customer: Record Customer;
        LsvJournal: Record "LSV Journal";
        LSVJournalLine: Record "LSV Journal Line";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        d: Dialog;
        XWWBEUR: Label 'WWB-EUR';

    procedure WriteSetup()
    begin
        with LsvSetup do begin
            Init();
            "Bank Code" := XGIRO;
            "LSV Customer ID" := Text11512;
            "LSV Sender ID" := Text11512;
            "LSV Sender Clearing" := '4823';
            "LSV Payment Method Code" := 'LSV';
            "ESR Bank Code" := XGIRO;
            "LSV Currency Code" := 'CHF';
            "LSV Sender IBAN" := 'CH9300762011623852957';
            "LSV Customer Bank Code" := 'LSV';
            "DebitDirect Customerno." := '909700';

            "Bal. Account No." := '1020';
            "LSV File Folder" := 'c:\';
            "LSV Filename" := 'DTALSV';
            Text := Text11516;
            "Text 2" :=
              Text11517 +
              Text11518 +
              Text11519;

            "Computer Bureau Name" := Text11520;
            "Computer Bureau Name 2" := Text11521;
            "Computer Bureau Address" := Text11522;
            "Computer Bureau Post Code" := '8021';
            "Computer Bureau City" := Text11523;
            "Computer Bureau E-Mail" := '';
            "Computer Bureau Home Page" := '';
            "LSV Bank Name" := Text11524;
            "LSV Bank Name 2" := '';
            "LSV Bank Address" := Text11525;
            "LSV Bank Post Code" := '6301';
            "LSV Bank City" := Text11526;
            "LSV Bank E-Mail" := '';
            "LSV Bank Home Page" := '';
            "LSV Bank Transfer Hyperlink" := 'https://gate.sic.ch';
            if not Insert(true) then
                Modify();

            Init();
            "Bank Code" := XWWBEUR;
            "LSV Customer ID" := Text11512;
            "LSV Sender ID" := Text11512;
            "LSV Sender Clearing" := '423';
            "LSV Payment Method Code" := 'LSV';
            "ESR Bank Code" := XNBL;
            "LSV Currency Code" := 'EUR';
            "LSV Sender IBAN" := 'CH9300762011623852957';
            "LSV Customer Bank Code" := 'LSV';
            "DebitDirect Customerno." := '909700';

            "Bal. Account No." := '1020';
            "LSV File Folder" := 'c:\';
            "LSV Filename" := 'DTALSV';
            Text := Text11516;
            "Text 2" :=
              Text11517 +
              Text11518 +
              Text11519;

            "Computer Bureau Name" := Text11520;
            "Computer Bureau Name 2" := Text11521;
            "Computer Bureau Address" := Text11522;
            "Computer Bureau Post Code" := '8021';
            "Computer Bureau City" := Text11523;
            "Computer Bureau E-Mail" := '';
            "Computer Bureau Home Page" := '';
            "LSV Bank Name" := Text11524;
            "LSV Bank Name 2" := '';
            "LSV Bank Address" := Text11525;
            "LSV Bank Post Code" := '6301';
            "LSV Bank City" := Text11526;
            "LSV Bank E-Mail" := '';
            "LSV Bank Home Page" := '';
            if not Insert(true) then
                Modify();
        end;
    end;

    procedure ChangeCustomerBank()
    var
        BankDirectory: Record "Bank Directory";
    begin
        if BankDirectory.IsEmpty() then
            CODEUNIT.Run(CODEUNIT::"Bank Directory");
        with CustomerBankAccount do begin
            Init();
            "Customer No." := '10000';
            Code := 'LSV';
            Name := Text11529;
            Address := '';
            "Post Code" := '6055';
            City := Text11530;
            Validate("Bank Branch No.", '81232');
            "Bank Account No." := '34124.24';
            Validate("Giro Account No.", '01-28302-7');
            if not Insert then
                Modify();

            Init();
            "Customer No." := '20000';
            Code := 'LSV';
            Name := Text11531;
            Address := Text11532;
            "Post Code" := '6055';
            City := Text11530;
            Validate("Bank Branch No.", '780');
            "Bank Account No." := '01-30-033237-00';
            Validate("Giro Account No.", '01-17601-2');
            if not Insert then
                Modify();

            Init();
            "Customer No." := '30000';
            Code := 'LSV';
            Name := Text11533;
            Address := Text11534;
            "Post Code" := '6002';
            City := Text11535;
            Validate("Bank Branch No.", '8411');
            "Bank Account No." := '421-740-018.10';
            Validate("Giro Account No.", '01-1760-2');
            if not Insert then
                Modify();

            Init();
            "Customer No." := '40000';
            Code := 'LSV';
            Name := Text11536;
            Address := '';
            "Post Code" := '6002';
            City := Text11535;
            Validate("Bank Branch No.", '8450');
            "Bank Account No." := '4178933000506';
            Validate("Giro Account No.", '10-1010-6');
            if not Insert then
                Modify();

            Init();
            "Customer No." := '50000';
            Code := 'LSV';
            Name := Text11537;
            Address := '';
            "Post Code" := '6002';
            City := Text11535;
            Validate("Bank Branch No.", '778');
            "Bank Account No." := '01-00-036430-00';
            Validate("Giro Account No.", '80-70-2');
            if not Insert then
                Modify();
        end;
    end;

    procedure ModifyPaymentType()
    begin
        PaymentMethod.Init();
        PaymentMethod.Code := 'LSV';
        PaymentMethod.Description := Text11538;
        if not PaymentMethod.Insert() then
            PaymentMethod.Modify();

        Customer.SetRange("No.", '30000', '50000');
        Customer.ModifyAll("Payment Method Code", 'LSV');
    end;

    procedure ClearLSVJournal()
    begin
        LsvJournal.DeleteAll();
        LSVJournalLine.DeleteAll();
        CustLedgerEntry.SetCurrentKey("LSV No.");
        CustLedgerEntry.SetFilter("LSV No.", '>%1', 0);
        CustLedgerEntry.ModifyAll("On Hold", '');
        CustLedgerEntry.ModifyAll("LSV No.", 0);
    end;

    procedure FillJournal()
    begin
        LsvJournal.Init();
        LsvJournal.Validate("LSV Bank Code", XGIRO);
        LsvJournal.Insert(true);

        LsvJournal.Init();
        LsvJournal.Validate("LSV Bank Code", XGIRO + 'EUR');
        LsvJournal.Insert(true);
    end;
}

