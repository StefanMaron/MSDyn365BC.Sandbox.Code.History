#if not CLEAN25
codeunit 122004 "Create IRS 1099 Form Boxes"
{
    ObsoleteReason = 'Moved to IRS Forms App.';
    ObsoleteState = Pending;
    ObsoleteTag = '25.0';

    trigger OnRun()
    var
        IRS1099FormBox: Record "IRS 1099 Form-Box";
    begin
        IRS1099FormBox.InitIRS1099FormBoxes();
    end;
}
#endif