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

        with "Source Code" do begin
            Init();
            Code := XEFFETS;
            Description := XBillsOfExchange;
            Insert(true);
        end;
    end;

    var
        "Source Code": Record "Source Code";
        XSTART: Label 'START';
        XOpeningEntries: Label 'Opening Entries';
        XEFFETS: Label 'EFFETS';
        XBillsOfExchange: Label 'Bills Of Exchange';
}

