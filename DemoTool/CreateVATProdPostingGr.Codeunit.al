codeunit 101324 "Create VAT Prod. Posting Gr."
{

    trigger OnRun()
    begin
        with DemoDataSetup do begin
            Get();
            if "Company Type" = "Company Type"::VAT then begin
                InsertData(ServicesVATCode, StrSubstNo(XMiscellaneousVAT, ServicesVATCode));
                InsertData(NoVATCode, NoVatTxt);
                InsertData(GoodsVATCode, StrSubstNo(XMiscellaneousVAT, GoodsVATCode));
            end;
        end;
    end;

    var
        DemoDataSetup: Record "Demo Data Setup";
        XMiscellaneousVAT: Label 'Miscellaneous %1 VAT', Comment = '%1 = VAT percentage';
        NoVatTxt: Label 'No VAT';

    procedure InsertData("Code": Code[10]; Description: Text[50])
    var
        VATProductPostingGroup: Record "VAT Product Posting Group";
    begin
        VATProductPostingGroup.Init();
        VATProductPostingGroup.Validate(Code, Code);
        VATProductPostingGroup.Validate(Description, Description);
        VATProductPostingGroup.Insert();
    end;
}

