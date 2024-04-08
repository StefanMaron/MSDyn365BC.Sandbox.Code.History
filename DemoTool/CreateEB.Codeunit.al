codeunit 160100 "Create EB"
{

    trigger OnRun()
    begin
        InitializeSetup;

        // Assign/Change Bank Acc.
        PrepareVendors;

        // IBLC/BLWI initialization
        InitializeIBLCcodes('090', XTransactionsOfGoods);
        InitializeIBLCcodes('091', XReimbursement);
        InitializeIBLCcodes('092', XEU3PartyTradeTransit);

        AddExportProtocols;
    end;

    var
        Vend: Record Vendor;
        XTransactionsOfGoods: Label 'Transactions of goods crossing national borders';
        XReimbursement: Label 'Reimbursement';
        XEU3PartyTradeTransit: Label 'EU 3 Party Trade - Transit';

    procedure CreateTrialData()
    begin
        InitializeSetup;

        // IBLC/BLWI initialization
        InitializeIBLCcodes('090', XTransactionsOfGoods);
        InitializeIBLCcodes('091', XReimbursement);
        InitializeIBLCcodes('092', XEU3PartyTradeTransit);
        AddExportProtocols;
    end;

    procedure CreateEvaluationData()
    begin
        // Assign/Change Bank Acc.
        PrepareVendors;
    end;

    procedure PrepareVendors()
    var
        VendBankAcc: Record "Vendor Bank Account";
        BankAccNo: Text[30];
        CheckSum: Text[30];
    begin
        with Vend do begin
            Reset();
            ModifyAll("Suggest Payments", true);
            // Initialize bank account for companies with LCY
            BankAccNo := '431-0680106';
            CheckSum := '-09';
            SetRange("Country/Region Code", '');
            if Find('-') then
                repeat
                    VendBankAcc.SetRange("Vendor No.", "No.");
                    if VendBankAcc.FindFirst() then begin
                        VendBankAcc."Bank Account No." := BankAccNo + CheckSum;
                        VendBankAcc.Modify();
                        "Preferred Bank Account Code" := VendBankAcc.Code;
                        Modify();
                    end;
                    BankAccNo := IncStr(BankAccNo);
                    CheckSum := IncStr(CheckSum);
                until Next = 0;
        end;
    end;

    procedure InitializeIBLCcodes(Codes: Code[10]; Desc: Text[250])
    var
        IBLCcode: Record "IBLC/BLWI Transaction Code";
    begin
        with IBLCcode do begin
            Init();
            "Transaction Code" := Codes;
            Description := Desc;
            if not Insert then
                Modify();
        end;
    end;

    procedure InitializeSetup()
    var
        EBSetup: Record "Electronic Banking Setup";
    begin
        EBSetup.Get();
        EBSetup."Summarize Gen. Jnl. Lines" := true;
        EBSetup."Cut off Payment Message Texts" := false;
        EBSetup.Modify();
    end;

    local procedure AddExportProtocols()
    var
        ExportProtocol: Record "Export Protocol";
    begin
        InsertExportProtocol('Domestic', 'Domestic export protocol.', 2000002, 2000001, '',
          ExportProtocol."Export Object Type"::Report, ExportProtocol."Code Expenses"::SHA);
        InsertExportProtocol('International-SHA', 'Parties share transfer fees for an intl. payment.', 2000003, 2000002, '',
          ExportProtocol."Export Object Type"::Report, ExportProtocol."Code Expenses"::SHA);
        InsertExportProtocol('International-BEN', 'Receiver pays the fees for an intl. payment.', 2000003, 2000002, '',
          ExportProtocol."Export Object Type"::Report, ExportProtocol."Code Expenses"::BEN);
        InsertExportProtocol('International-OUR', 'The sender pays the fees for an intl. payment.', 2000003, 2000002, '',
          ExportProtocol."Export Object Type"::Report, ExportProtocol."Code Expenses"::OUR);
        InsertExportProtocol('SEPA', 'Sender pays fees for a Single European Payment.', 2000004, 2000005, '',
          ExportProtocol."Export Object Type"::Report, ExportProtocol."Code Expenses"::SHA);
        InsertExportProtocol('Non-Euro SEPA', 'Parties share fees for a non-euro payment.', 2000005, 2000006, '',
          ExportProtocol."Export Object Type"::Report, ExportProtocol."Code Expenses"::SHA);
        InsertExportProtocol('Zero', 'The sending bank decides who pays the bank fees.', 0, 1000, '',
          ExportProtocol."Export Object Type"::XMLPort, ExportProtocol."Code Expenses"::" ");
    end;

    local procedure InsertExportProtocol(ExpenseCode: Code[20]; ExpenseDescription: Text[50]; CheckObjectID: Integer; ExportObjectID: Integer; ExportNoSeries: Code[20]; ExportObjectType: Option; CodeExpense: Option)
    var
        ExportProtocol: Record "Export Protocol";
    begin
        with ExportProtocol do begin
            Init();
            Code := ExpenseCode;
            Description := ExpenseDescription;
            Validate("Check Object ID", CheckObjectID);
            "Export Object ID" := ExportObjectID;
            "Export No. Series" := ExportNoSeries;
            "Export Object Type" := ExportObjectType;
            "Code Expenses" := CodeExpense;
            Insert();
        end;
    end;
}

