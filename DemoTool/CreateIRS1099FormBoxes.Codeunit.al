codeunit 122004 "Create IRS 1099 Form Boxes"
{

    trigger OnRun()
    var
        IRS1099FormBox: Record "IRS 1099 Form-Box";
    begin
        IRS1099FormBox.InitIRS1099FormBoxes;
    end;
}

