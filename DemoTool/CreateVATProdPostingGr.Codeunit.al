codeunit 101324 "Create VAT Prod. Posting Gr."
{

    trigger OnRun()
    begin
        with DemoDataSetup do begin
            Get();
            if "Company Type" = "Company Type"::VAT then begin
                InsertData(NoVATCode, XMiscellaneousWithoutVAT);
                // NAVCZ
                InsertData(BaseVATItemCode(), StrSubstNo(XVATItem, BaseVATRate()));
                InsertData(BaseVATServiceCode(), StrSubstNo(XVATService, BaseVATRate()));
                InsertData(BaseVATReverseChargeCode(), StrSubstNo(XVATReverseCharge, BaseVATRate()));
                InsertData(FirstReducedVATItemCode(), StrSubstNo(XVATItem, FirstReducedVATRate()));
                InsertData(FirstReducedVATServiceCode(), StrSubstNo(XVATService, FirstReducedVATRate()));
                InsertData(FirstReducedVATReverseChargeCode(), StrSubstNo(XVATReverseCharge, FirstReducedVATRate()));
                InsertData(SecondReducedVATItemCode(), StrSubstNo(XVATItem, SecondReducedVATRate()));
                InsertData(SecondReducedVATServiceCode(), StrSubstNo(XVATService, SecondReducedVATRate()));
                // NAVCZ
            end;
        end;
    end;

    var
        DemoDataSetup: Record "Demo Data Setup";
        XMiscellaneousWithoutVAT: Label 'Miscellaneous without VAT';
        XVATItem: Label 'VAT %1% item';
        XVATService: Label 'VAT %1% service';
        XVATReverseCharge: Label 'VAT %1% reverse charge';
        XNondeductibleVAT: Label 'Non-deductible VAT';

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

