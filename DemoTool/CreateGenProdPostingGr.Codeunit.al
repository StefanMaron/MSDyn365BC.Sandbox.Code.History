codeunit 101251 "Create Gen. Prod. Posting Gr."
{

    trigger OnRun()
    begin
        with DemoDataSetup do begin
            Get();
            InsertData(MiscCode, XMiscellaneouswithTax, '');
            InsertData(NoVATCode, XMiscellaneouswithoutTax, '');
            InsertData(RawMatCode, XRawMaterials, '');
            InsertData(RetailCode, XRetail2, '');
            InsertData(ServicesCode, XResourcesetc, '');
            InsertData(ManufactCode, XCapacities, '');
        end;
    end;

    var
        DemoDataSetup: Record "Demo Data Setup";
        XMiscellaneouswithTax: Label 'Miscellaneous with tax';
        XMiscellaneouswithoutTax: Label 'Miscellaneous without tax';
        XRawMaterials: Label 'Raw Materials';
        XRetail2: Label 'Retail';
        XResourcesetc: Label 'Resources, etc.';
        XCapacities: Label 'Capacities';

    procedure InsertMiniAppData()
    begin
        with DemoDataSetup do begin
            Get();
            InsertData(NoVATCode, XMiscellaneouswithoutTax, '');
            InsertData(RetailCode, XRetail2, '');
            InsertData(ServicesCode, XResourcesetc, '');
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

