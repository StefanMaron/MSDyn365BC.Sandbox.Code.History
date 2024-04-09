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
        CreateJnlBatch(); // NAVCZ
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

    local procedure CreateJnlBatch() // NAVCZ
    var
        I: Integer;
    begin
        for I := 1 to 12 do begin
            InsertBatch(I);
        end;
    end;

    local procedure InsertBatch(Month: Integer) // NAVCZ
    var
        IntrastatJnlBatch: Record "Intrastat Jnl. Batch";
        Date: Record Date;
        Year: Integer;
        MonthText: Text;
        YearText: Text;
    begin
        MonthText := StrSubstNo('0%1', Month);
        MonthText := CopyStr(MonthText, StrLen(MonthText) - 1);
        Year := Date2DMY(WorkDate(), 3);
        YearText := CopyStr(Format(Year, 4), 3);
        Date.SetRange("Period Type", Date."Period Type"::Month);
        Date.SetRange("Period No.", Month);
        Date.FindFirst();
        IntrastatJnlBatch.Init();
        IntrastatJnlBatch."Journal Template Name" := IntrastatJnlNameTok;
        IntrastatJnlBatch.Name := StrSubstNo('%1%2', YearText, MonthText);
        IntrastatJnlBatch.Description := StrSubstNo('%1 %2', Date."Period Name", Year);
        IntrastatJnlBatch."Statistics Period" := IntrastatJnlBatch.Name;
        IntrastatJnlBatch."Statement Type CZL" := IntrastatJnlBatch."Statement Type CZL"::Null;
        IntrastatJnlBatch.Insert();
    end;
}
#endif