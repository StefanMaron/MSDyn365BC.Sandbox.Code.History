codeunit 117561 "Upd. Service Zone in Customer"
{

    trigger OnRun()
    begin
        Clear(Cust);
        if Cust.Find('-') then
            repeat
                case Cust."No." of
                    '10000':
                        begin
                            Cust."Service Zone Code" := XW;
                            Cust.Modify();
                        end;
                    '20000':
                        begin
                            Cust."Service Zone Code" := XN;
                            Cust.Modify();
                        end;
                    '30000':
                        begin
                            Cust."Service Zone Code" := XS;
                            Cust.Modify();
                        end;

                    '40000':
                        begin
                            Cust."Service Zone Code" := XS;
                            Cust.Modify();
                        end;
                    '50000':
                        begin
                            Cust."Service Zone Code" := XN;
                            Cust.Modify();
                        end;
                    else begin
                            if Cust."Currency Code" <> '' then begin
                                Cust."Service Zone Code" := XX;
                                Cust.Modify();
                            end;
                        end;
                end;
            until Cust.Next() = 0;
    end;

    var
        Cust: Record Customer;
        XM: Label 'M';
        XN: Label 'N';
        XW: Label 'W';
        XSE: Label 'SE';
        XX: Label 'X';
        XS: Label 'S';
}

