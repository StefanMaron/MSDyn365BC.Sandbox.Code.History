codeunit 101323 "Create VAT Bus. Posting Gr."
{

    trigger OnRun()
    begin
        with DemoDataSetup do begin
            Get();
            if "Company Type" = "Company Type"::VAT then begin
                InsertData(DomesticCode, DomesticText);
                InsertData(EUCode, EUText);
                InsertData(ExportCode, ForeignText);
            end;
        end;
    end;

    var
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        DemoDataSetup: Record "Demo Data Setup";

    procedure InsertData("Code": Code[10]; Description: Text[50])
    begin
        VATBusinessPostingGroup.Init();
        VATBusinessPostingGroup.Validate(Code, Code);
        VATBusinessPostingGroup.Validate(Description, Description);
        VATBusinessPostingGroup.Insert();
    end;

    procedure GetDomesticVATGroup(): Code[10]
    begin
        DemoDataSetup.Get();
        exit(DemoDataSetup.DomesticCode);
    end;
}

