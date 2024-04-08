codeunit 101094 "Create Item Posting Group"
{

    trigger OnRun()
    begin
        with DemoDataSetup do begin
            Get();
            InsertData(ResaleCode, XResaleItemsTxt);
            InsertData(FinishedCode, XFinishedItemsTxt);
            InsertData(RawMatCode, XRawMaterialsTxt);
        end;
    end;

    var
        DemoDataSetup: Record "Demo Data Setup";
        InventoryPostingGroup: Record "Inventory Posting Group";
        XResaleItemsTxt: Label 'Resale items';
        XFinishedItemsTxt: Label 'Finished items';
        XRawMaterialsTxt: Label 'Raw materials';

    procedure InsertData("Code": Code[20]; PostingGroupDescription: Text[50])
    begin
        InventoryPostingGroup.Init();
        InventoryPostingGroup.Validate(Code, Code);
        InventoryPostingGroup.Validate(Description, PostingGroupDescription);
        InventoryPostingGroup.Insert();
    end;

    procedure InsertMiniAppData()
    begin
        with DemoDataSetup do begin
            Get();
            InsertData(ResaleCode, XResaleItemsTxt);
        end;
    end;
}

