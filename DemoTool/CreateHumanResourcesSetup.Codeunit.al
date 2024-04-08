codeunit 101618 "Create Human Resources Setup"
{

    trigger OnRun()
    begin
        with "Human Resouces Setup" do begin
            Get();
            "Create No. Series".InitBaseSeries("Employee Nos.", XEMP, XEmployee, XE10, XE9990, '', '', 10, true);
            Modify();
        end;
    end;

    var
        "Human Resouces Setup": Record "Human Resources Setup";
        "Create No. Series": Codeunit "Create No. Series";
        XEMP: Label 'EMP';
        XEmployee: Label 'Employee';
        XE10: Label 'E10';
        XE9990: Label 'E9990';
}

