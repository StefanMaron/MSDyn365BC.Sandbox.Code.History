codeunit 161550 "Create Demodata ESR"
{

    trigger OnRun()
    var
        DemoDataSetup: Record "Demo Data Setup";
    begin
        d.Open(Text11504);
        if PaymentMethod.Get(Text11506) then begin
            PaymentMethod.Code := Text11506;
            PaymentMethod.Description := Text11507;
            PaymentMethod.Modify();
        end else begin
            PaymentMethod.Code := Text11506;
            PaymentMethod.Description := Text11507;
            PaymentMethod.Insert();
        end;

        Clear(PaymentMethod);
        if PaymentMethod.Get(Text11508) then begin
            PaymentMethod.Code := Text11508;
            PaymentMethod.Description := Text11509;
            PaymentMethod.Modify();
        end else begin
            PaymentMethod.Code := Text11508;
            PaymentMethod.Description := Text11509;
            PaymentMethod.Insert();
        end;

        CompanyInfo.Get();
        with ESRSetup do begin
            Init();
            "Bank Code" := Text11510;
            "ESR System" := "ESR System"::ESR;
            "Bal. Account Type" := "Bal. Account Type"::"G/L Account";
            Validate("Bal. Account No.", '1020');
            "ESR Filename" := 'c:\cronus.v11';
            Validate("BESR Customer ID", '68705010000');
            Validate("ESR Account No.", '01-13980-3');
            "ESR Currency Code" := 'EUR';
            "ESR Member Name 1" := Format(Text11512, -MaxStrLen("ESR Member Name 1"));
            "ESR Member Name 2" := Format(Text11513, -MaxStrLen("ESR Member Name 2"));
            "ESR Member Name 3" := Format(Text11514, -MaxStrLen("ESR Member Name 3"));
            "Beneficiary Text" := Format(Text11515, -MaxStrLen("Beneficiary Text"));

            Beneficiary := Format(CompanyInfo.Name, -MaxStrLen(Beneficiary));
            "Beneficiary 2" := Format(CompanyInfo.Address, -MaxStrLen("Beneficiary 2"));
            "Beneficiary 3" := Format(CompanyInfo."Post Code" + ' ' + CompanyInfo.City, -MaxStrLen("Beneficiary 3"));
            "Beneficiary 4" := '';
            "Backup Copy" := false;

            "ESR Payment Method Code" := Format(Text11506, -MaxStrLen("ESR Payment Method Code"));
            "ESR Main Bank" := true;

            if not Insert then
                Modify();

            Init();
            "Bank Code" := Text11521;
            "ESR System" := "ESR System"::ESR;
            "Bal. Account Type" := "Bal. Account Type"::"G/L Account";
            Validate("Bal. Account No.", '1010');
            "ESR Filename" := 'c:\cronus.v11';
            Validate("BESR Customer ID", '00000000000');
            Validate("ESR Account No.", '60-9-9');
            "ESR Member Name 1" := Format(CompanyInfo.Name, -MaxStrLen("ESR Member Name 1"));
            "ESR Member Name 2" := Format(CompanyInfo.Address, -MaxStrLen("ESR Member Name 2"));
            "ESR Member Name 3" := Format(CompanyInfo."Post Code" + ' ' + CompanyInfo.City, -MaxStrLen("ESR Member Name 3"));
            "Beneficiary Text" := '';
            Beneficiary := '';
            "Beneficiary 2" := '';
            "Beneficiary 3" := '';
            "Beneficiary 4" := '';
            "Backup Copy" := false;

            "ESR Payment Method Code" := Format(Text11508, -MaxStrLen("ESR Payment Method Code"));
            "ESR Main Bank" := false;

            if not Insert then
                Modify();
        end;
        DemoDataSetup.Get();
        d.Close();
    end;

    var
        Text11504: Label 'Generate ESR demo data';
        Text11506: Label 'ESR';
        Text11507: Label 'ESR with CS';
        Text11508: Label 'ESR POST';
        Text11509: Label 'ESR with POST';
        Text11510: Label 'NBL';
        Text11512: Label 'Zuger Kantonalbank';
        Text11513: Label 'Bahnhofstrasse 1';
        Text11514: Label '6301 Zug';
        Text11515: Label 'In favor:';
        Text11521: Label 'GIRO';
        XPANDPSETUP: Label 'P&P-SETUP';
        XSANDRJOURNAL: Label 'S&R-JOURNAL';
        XSANDRJOURNALPOST: Label 'S&R-JOURNAL, POST';
        XSANDRQOIRC: Label 'S&R-Q/O/I/R/C';
        ESRSetup: Record "ESR Setup";
        PaymentMethod: Record "Payment Method";
        CompanyInfo: Record "Company Information";
        d: Dialog;
}

