codeunit 101620 "Create Human Resources Uom"
{

    trigger OnRun()
    begin
        InsertData(XHOUR, 1 / 8, false);
        InsertData(XDAY, 1, true);
    end;

    var
        HRUoM: Record "Human Resource Unit of Measure";
        HRSetUp: Record "Human Resources Setup";
        XHOUR: Label 'HOUR';
        XDAY: Label 'DAY';

    procedure InsertData(CodeParam: Code[10]; QtyParam: Decimal; BaseUoM: Boolean)
    begin
        with HRUoM do begin
            Init();
            Code := CodeParam;
            "Qty. per Unit of Measure" := QtyParam;
            Insert();
            if BaseUoM then begin
                HRSetUp.Get();
                HRSetUp.Validate("Base Unit of Measure", Code);
                HRSetUp.Modify();
            end;
        end;
    end;
}

