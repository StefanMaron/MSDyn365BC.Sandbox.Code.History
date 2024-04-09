codeunit 119091 "Create Cost Budget Name"
{

    trigger OnRun()
    var
        CostBudgetName: Record "Cost Budget Name";
    begin
        with CostBudgetName do begin
            Init();
            Name := XDEFAULT;
            Description := XSTANDARD;

            if not Insert then
                Modify();
        end;
    end;

    var
        XDEFAULT: Label 'DEFAULT', Comment = 'Default is a name of Cost Budget.';
        XSTANDARD: Label 'STANDARD', Comment = 'Standard is a description of Cost Budget Name.';
}

