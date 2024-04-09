codeunit 101251 "Create Gen. Prod. Posting Gr."
{

    trigger OnRun()
    begin
        with DemoDataSetup do begin
            Get();
            InsertData(MiscCode, XMiscellaneouswithVAT, XVAT24);
            InsertData(NoVATCode, XMiscellaneouswithoutVAT, XWITHVAT);
            InsertData(RawMatCode, XRawMaterials, XVAT24);
            InsertData(RetailCode, XRetail2, XVAT24);
            InsertData(ServicesCode, XResourcesetc, XVAT12);
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
        XVAT24: Label 'High';
        XVAT12: Label 'Low';
        XWITHVAT: Label 'Without';

    procedure InsertMiniAppData()
    begin
        with DemoDataSetup do begin
            Get();
            InsertData(MiscCode, XMiscellaneouswithVAT, XVAT24);
            InsertData(NoVATCode, XMiscellaneouswithoutVAT, XWITHVAT);
            InsertData(RawMatCode, XRawMaterials, XVAT24);
            InsertData(FreightCode, XFreightDescriptionTxt, XVAT24);
            InsertData(RetailCode, XRetail2, XVAT24);
            InsertData(ServicesCode, XResourcesetc, XVAT12);
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

