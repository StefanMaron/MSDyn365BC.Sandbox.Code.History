codeunit 101257 "Create VAT Statement Name"
{

    trigger OnRun()
    begin
        InsertData(XVAT, XUSTVA, XVatStatementGermany, true);
    end;

    var
        XVAT: Label 'VAT';
        XUSTVA: Label 'USTVA';
        XVatStatementGermany: Label 'VAT Statement Germany';

    procedure InsertData("Statement Template Name": Code[10]; Name: Code[10]; Description: Text[50]; "Sales VAT Adv. Notification": Boolean)
    var
        "VAT Statement Name": Record "VAT Statement Name";
    begin
        "VAT Statement Name".Init();
        "VAT Statement Name".Validate("Statement Template Name", "Statement Template Name");
        "VAT Statement Name".Validate(Name, Name);
        "VAT Statement Name".Validate(Description, Description);
        "VAT Statement Name".Validate("Sales VAT Adv. Notification", "Sales VAT Adv. Notification");
        "VAT Statement Name".Insert();
    end;
}

