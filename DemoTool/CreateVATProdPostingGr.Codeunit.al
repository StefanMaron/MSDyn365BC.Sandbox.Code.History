codeunit 101324 "Create VAT Prod. Posting Gr."
{

    trigger OnRun()
    begin
        with DemoDataSetup do begin
            Get();
            if "Company Type" = "Company Type"::VAT then begin
                TestField("Goods VAT Rate");
                TestField("Services VAT Rate");
                InsertData(GoodsVATCode, StrSubstNo(XMiscellaneousVAT, "Goods VAT Rate"));
                InsertData(ServicesVATCode, StrSubstNo(XMiscellaneousVAT, "Services VAT Rate"));
                InsertData(NoVATCode, XMiscellaneousWithoutVAT);
                InsertData(XNOTAX, XNotChargeableVAT);
                if "Reduced VAT Rate" > 0 then
                    InsertData(ReducedVATCode, XReducedVAT);
            end;
        end;
    end;

    var
        DemoDataSetup: Record "Demo Data Setup";
        XMiscellaneousVAT: Label 'Miscellaneous %1 VAT';
        XMiscellaneousWithoutVAT: Label 'Miscellaneous without VAT';
        XNOTAX: Label 'NO TAX';
        XNotChargeableVAT: Label 'Not chargeable VAT';
        XReducedVAT: Label 'Reduced VAT';

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

