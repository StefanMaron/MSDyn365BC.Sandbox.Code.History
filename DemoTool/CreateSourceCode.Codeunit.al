codeunit 101230 "Create Source Code"
{

    trigger OnRun()
    begin
        with "Source Code" do begin
            Init();
            Code := XSTART;
            Description := XOpeningEntries;
            Insert(true);
        end;
        //BEGIN IT
        with "Source Code" do begin
            Code := XxRIBA;
            Description := XBankReceipts;
            Insert(true);
        end;

        with "Source Code" do begin
            Code := XxBANKTRANSF;
            Description := XBankTransfers;
            Insert(true);
        end;
        //END IT
    end;

    var
        XxRIBA: Label 'RIBA';
        XBankReceipts: Label 'Bank Receipts';
        XxBANKTRANSF: Label 'BANKTRANSF';
        XBankTransfers: Label 'Bank Transfers';
        "Source Code": Record "Source Code";
        XSTART: Label 'START';
        XOpeningEntries: Label 'Opening Entries';
}

