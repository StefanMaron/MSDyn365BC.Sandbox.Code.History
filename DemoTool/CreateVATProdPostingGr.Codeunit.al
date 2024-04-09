codeunit 101324 "Create VAT Prod. Posting Gr."
{

    trigger OnRun()
    begin
        with DemoDataSetup do begin
            Get();
            if "Company Type" = "Company Type"::VAT then begin
                TestField("Goods VAT Rate");
                TestField("Services VAT Rate");
                InsertData(GoodsVATCode, StrSubstNo(NormalVatTxt, "Goods VAT Rate")); // NORMAL
                InsertData(ServicesVATCode, StrSubstNo(ReducedVatTxt, "Services VAT Rate")); // REDUCED
                if "Data Type" <> "Data Type"::Extended then begin
                    InsertData(GoodsVATCodeSRV, StrSubstNo(XMiscellaneousVAT, "Goods VAT Rate")); // SERV NORM
                    InsertData(ServicesVATCodeSRV, StrSubstNo(XMiscellaneousVAT, "Services VAT Rate")); // SERV RED
                    InsertData(FullServicesVATCode, XVATOnlyInvoices + ' ' + Format("Services VAT Rate") + '%'); // FULL RED
                    InsertData(FullGoodsVATCode, XVATOnlyInvoices + ' ' + Format("Goods VAT Rate") + '%'); // FULL NORM
                end;
                InsertData(NoVATCode, NoVatTxt);
                if "Reduced VAT Rate" > 0 then
                    InsertData(ReducedVATCode, StrSubstNo(XMiscellaneousVAT, "Reduced VAT Rate"));
            end;
        end;
    end;

    var
        DemoDataSetup: Record "Demo Data Setup";
        XMiscellaneousVAT: Label 'Miscellaneous %1 VAT';
        XVATOnlyInvoices: Label 'VAT Only Invoices';
        NormalVatTxt: Label 'Standard VAT (%1%)', Comment = '%1=a number specifying the VAT percentage';
        ReducedVatTxt: Label 'Reduced VAT (%1%)', Comment = '%1=a number specifying the VAT percentage';
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

