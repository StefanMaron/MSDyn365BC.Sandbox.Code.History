codeunit 101251 "Create Gen. Prod. Posting Gr."
{

    trigger OnRun()
    begin
        with DemoDataSetup do begin
            Get();
            InsertData(MiscCode, XMiscellaneouswithVAT, GoodsVATCode);
            InsertData(NoVATCode, XMiscellaneouswithoutVAT, NoVATCode);
            InsertData(RawMatCode, XRawMaterials, GoodsVATCode);
            InsertData(RetailCode, XRetail2, GoodsVATCode);
            InsertData(ServicesCode, XResourcesetc, ServicesVATCode);
            InsertData(ManufactCode, XCapacities, '');
        end;
    end;

    var
        DemoDataSetup: Record "Demo Data Setup";
        XMiscellaneouswithVAT: Label 'Miscellaneous with VAT';
        XMiscellaneouswithoutVAT: Label 'Miscellaneous without VAT';
        XRawMaterials: Label 'Raw Materials';
        XRetail2: Label 'Retail';
        XResourcesetc: Label 'Resources, etc.';
        XFreightDescriptionTxt: Label 'Freight, etc.';
        XCapacities: Label 'Capacities';

    procedure InsertMiniAppData()
    begin
        with DemoDataSetup do begin
            Get();
            InsertData(MiscCode, XMiscellaneouswithVAT, GoodsVATCode);
            InsertData(NoVATCode, XMiscellaneouswithoutVAT, NoVATCode);
            InsertData(RawMatCode, XRawMaterials, GoodsVATCode);
            InsertData(FreightCode, XFreightDescriptionTxt, GoodsVATCode);
            InsertData(RetailCode, XRetail2, GoodsVATCode);
            InsertData(ServicesCode, XResourcesetc, ServicesVATCode);
        end;
    end;

    procedure InsertData(NewCode: Code[20]; NewDescription: Text[50]; DefVATProdPostingGroup: Code[20])
    var
        GenProductPostingGroup: Record "Gen. Product Posting Group";
    begin
        with GenProductPostingGroup do begin
            Init();
            Validate(Code, NewCode);
            Validate(Description, NewDescription);
            if DemoDataSetup."Company Type" = DemoDataSetup."Company Type"::VAT then
                "Def. VAT Prod. Posting Group" := DefVATProdPostingGroup;
            Insert();
        end;
    end;
}

