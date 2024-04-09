#if not CLEAN22
codeunit 101247 "Create Intrastat Demo Data"
{
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';
    ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';

    trigger OnRun()
    var
        IntraJnlManagement: Codeunit IntraJnlManagement;
    begin
        CreateSetup();
        CreateJnlTemplate();
        IntraJnlManagement.CreateDefaultAdvancedIntrastatSetup();
    end;

    var
        IntrastatJnlNameTok: Label 'INTRASTAT', Comment = 'Code value';
        IntrastatJnlDescTok: Label 'Intrastat Journal';

    local procedure CreateSetup()
    var
        IntrastatSetup: Record "Intrastat Setup";
        TransactionType: Record "Transaction Type";
    begin
        IntrastatSetup.Init();

        if TransactionType.Get('20') then
            IntrastatSetup."Default Trans. - Purchase" := '20';

        if TransactionType.Get('10') then
            IntrastatSetup."Default Trans. - Return" := '10';

        IntrastatSetup."Company VAT No. on File" := IntrastatSetup."Company VAT No. on File"::"VAT Reg. No. Without EU Country Code";
        IntrastatSetup.Insert();
    end;

    local procedure CreateJnlTemplate()
    var
        IntrastatJnlTemplate: Record "Intrastat Jnl. Template";
    begin
        IntrastatJnlTemplate.Init();
        IntrastatJnlTemplate.Name := IntrastatJnlNameTok;
        IntrastatJnlTemplate.Description := IntrastatJnlDescTok;
        IntrastatJnlTemplate.Validate("Page ID");
        IntrastatJnlTemplate.Insert();
    end;
}
#endif