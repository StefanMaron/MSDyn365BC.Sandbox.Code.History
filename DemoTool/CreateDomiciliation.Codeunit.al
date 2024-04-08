codeunit 160101 "Create Domiciliation"
{

    trigger OnRun()
    var
        TempDec: Decimal;
    begin
        DomNo := 1450034468;
        TempDec := 100.0;
        with Cust do begin
            if Find('-') then
                repeat
                    "Domiciliation No." := Format(DomNo * TempDec + DomNo mod 97, 12, 1);
                    Modify();
                    DomNo := DomNo + 11
                until Next = 0
        end;
    end;

    var
        Cust: Record Customer;
        DomNo: Integer;
        VarRun: Boolean;
}

