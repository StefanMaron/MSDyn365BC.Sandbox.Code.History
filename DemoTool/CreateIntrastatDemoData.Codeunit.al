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
    begin
        IntrastatSetup.Init();
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