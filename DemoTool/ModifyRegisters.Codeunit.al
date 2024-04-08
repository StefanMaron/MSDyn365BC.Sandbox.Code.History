codeunit 101910 "Modify Registers"
{

    trigger OnRun()
    begin
    end;

    procedure ModifyRegisters(Date: Date)
    var
        "G/L Register": Record "G/L Register";
        "Item Register": Record "Item Register";
        "Resource Register": Record "Resource Register";
        "Job Register": Record "Job Register";
        "FA Register": Record "FA Register";
        "Insurance Register": Record "Insurance Register";
    begin
        "G/L Register".SetRange("Creation Date", Today);
        "G/L Register".ModifyAll("Creation Date", Date);

        "Item Register".SetRange("Creation Date", Today);
        "Item Register".ModifyAll("Creation Date", Date);

        "Resource Register".SetRange("Creation Date", Today);
        "Resource Register".ModifyAll("Creation Date", Date);

        "Job Register".SetRange("Creation Date", Today);
        "Job Register".ModifyAll("Creation Date", Date);

        "FA Register".SetRange("Creation Date", Today);
        "FA Register".ModifyAll("Creation Date", Date);

        "Insurance Register".SetRange("Creation Date", Today);
        "Insurance Register".ModifyAll("Creation Date", Date);
    end;
}

