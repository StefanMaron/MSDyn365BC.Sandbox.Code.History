codeunit 101110 "Create Inventory Posting Setup"
{

    trigger OnRun()
    begin
        DemoDataSetup.Get();
        if DemoDataSetup."Data Type" = DemoDataSetup."Data Type"::Extended then begin
            InsertData('', DemoDataSetup.FinishedCode(), '992120', '992121');
            InsertData('', DemoDataSetup.RawMatCode(), '992130', '992131');
            InsertData('', DemoDataSetup.ResaleCode(), '992110', '992111');
            InsertData(XBLUE, DemoDataSetup.FinishedCode(), '992120', '992121');
            InsertData(XBLUE, DemoDataSetup.RawMatCode(), '992130', '992131');
            InsertData(XBLUE, DemoDataSetup.ResaleCode(), '992110', '992111');
            InsertData(XGREEN, DemoDataSetup.FinishedCode(), '992120', '992121');
            InsertData(XGREEN, DemoDataSetup.RawMatCode(), '992130', '992131');
            InsertData(XGREEN, DemoDataSetup.ResaleCode(), '992110', '992111');
            InsertData(XRED, DemoDataSetup.FinishedCode(), '992120', '992121');
            InsertData(XRED, DemoDataSetup.RawMatCode(), '992130', '992131');
            InsertData(XRED, DemoDataSetup.ResaleCode(), '992110', '992111');
            InsertData(XYELLOW, DemoDataSetup.FinishedCode(), '992120', '992121');
            InsertData(XYELLOW, DemoDataSetup.RawMatCode(), '992130', '992131');
            InsertData(XYELLOW, DemoDataSetup.ResaleCode(), '992110', '992111');
            InsertData(XWHITE, DemoDataSetup.FinishedCode(), '992120', '992121');
            InsertData(XWHITE, DemoDataSetup.RawMatCode(), '992130', '992131');
            InsertData(XWHITE, DemoDataSetup.ResaleCode(), '992110', '992111');
            InsertData(XSILVER, DemoDataSetup.FinishedCode(), '992120', '992121');
            InsertData(XSILVER, DemoDataSetup.RawMatCode(), '992130', '992131');
            InsertData(XSILVER, DemoDataSetup.ResaleCode(), '992110', '992111');
        end else begin
            InsertData('', DemoDataSetup.FinishedCode(), CreateGLAccount.FinishedGoods(), CreateGLAccount.FinishedGoods());
            InsertData('', DemoDataSetup.RawMatCode(), CreateGLAccount.RawMaterials(), CreateGLAccount.RawMaterials());
            InsertData('', DemoDataSetup.ResaleCode(), CreateGLAccount.GoodsforResale(), CreateGLAccount.GoodsforResale());
            InsertData(XBLUE, DemoDataSetup.FinishedCode(), CreateGLAccount.FinishedGoods(), CreateGLAccount.FinishedGoods());
            InsertData(XBLUE, DemoDataSetup.RawMatCode(), CreateGLAccount.RawMaterials(), CreateGLAccount.RawMaterials());
            InsertData(XBLUE, DemoDataSetup.ResaleCode(), CreateGLAccount.GoodsforResale(), CreateGLAccount.GoodsforResale());
            InsertData(XGREEN, DemoDataSetup.FinishedCode(), CreateGLAccount.FinishedGoods(), CreateGLAccount.FinishedGoods());
            InsertData(XGREEN, DemoDataSetup.RawMatCode(), CreateGLAccount.RawMaterials(), CreateGLAccount.RawMaterials());
            InsertData(XGREEN, DemoDataSetup.ResaleCode(), CreateGLAccount.GoodsforResale(), CreateGLAccount.GoodsforResale());
            InsertData(XRED, DemoDataSetup.FinishedCode(), CreateGLAccount.FinishedGoods(), CreateGLAccount.FinishedGoods());
            InsertData(XRED, DemoDataSetup.RawMatCode(), CreateGLAccount.RawMaterials(), CreateGLAccount.RawMaterials());
            InsertData(XRED, DemoDataSetup.ResaleCode(), CreateGLAccount.GoodsforResale(), CreateGLAccount.GoodsforResale());
            InsertData(XYELLOW, DemoDataSetup.FinishedCode(), CreateGLAccount.FinishedGoods(), CreateGLAccount.FinishedGoods());
            InsertData(XYELLOW, DemoDataSetup.RawMatCode(), CreateGLAccount.RawMaterials(), CreateGLAccount.RawMaterials());
            InsertData(XYELLOW, DemoDataSetup.ResaleCode(), CreateGLAccount.GoodsforResale(), CreateGLAccount.GoodsforResale());
            InsertData(XWHITE, DemoDataSetup.FinishedCode(), CreateGLAccount.FinishedGoods(), CreateGLAccount.FinishedGoods());
            InsertData(XWHITE, DemoDataSetup.RawMatCode(), CreateGLAccount.RawMaterials(), CreateGLAccount.RawMaterials());
            InsertData(XWHITE, DemoDataSetup.ResaleCode(), CreateGLAccount.GoodsforResale(), CreateGLAccount.GoodsforResale());
            InsertData(XSILVER, DemoDataSetup.FinishedCode(), CreateGLAccount.FinishedGoods(), CreateGLAccount.FinishedGoods());
            InsertData(XSILVER, DemoDataSetup.RawMatCode(), CreateGLAccount.RawMaterials(), CreateGLAccount.RawMaterials());
            InsertData(XSILVER, DemoDataSetup.ResaleCode(), CreateGLAccount.GoodsforResale(), CreateGLAccount.GoodsforResale());
        end;
    end;

    var
        DemoDataSetup: Record "Demo Data Setup";
        CreateGLAccount: Codeunit "Create G/L Account";
        XMAIN: Label 'MAIN';
        XEAST: Label 'EAST';
        XWEST: Label 'WEST';
        XBLUE: Label 'BLUE';
        XGREEN: Label 'GREEN';
        XRED: Label 'RED';
        XYELLOW: Label 'YELLOW';
        XWHITE: Label 'WHITE';
        XSILVER: Label 'SILVER';

    procedure InsertData("Location Code": Code[10]; "Inventory Posting Group": Code[20]; "Inventory Account": Code[20]; "Inventory Account (Interim)": Code[20])
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
        MakeAdjustments: Codeunit "Make Adjustments";
    begin
        InventoryPostingSetup.Init();
        InventoryPostingSetup.Validate("Location Code", "Location Code");
        InventoryPostingSetup.Validate("Invt. Posting Group Code", "Inventory Posting Group");
        InventoryPostingSetup.Validate("Inventory Account", MakeAdjustments.Convert("Inventory Account"));
        InventoryPostingSetup.Validate("Inventory Account (Interim)", MakeAdjustments.Convert("Inventory Account (Interim)"));
        InventoryPostingSetup.Insert();
    end;

    procedure InsertMiniAppData()
    begin
        DemoDataSetup.Get();
        InsertData('', DemoDataSetup.ResaleCode(), CreateGLAccount.FinishedGoods(), '');
    end;

    procedure CreateEvaluationData()
    begin
        DemoDataSetup.Get();
        if DemoDataSetup."Data Type" = DemoDataSetup."Data Type"::Extended then begin
            InsertData(XMAIN, DemoDataSetup.ResaleCode(), '992110', '992111');
            InsertData(XEAST, DemoDataSetup.ResaleCode(), '992110', '992111');
            InsertData(XWEST, DemoDataSetup.ResaleCode(), '992110', '992111');
        end else begin
            InsertData(XMAIN, DemoDataSetup.ResaleCode(), CreateGLAccount.GoodsforResale(), CreateGLAccount.GoodsforResale());
            InsertData(XEAST, DemoDataSetup.ResaleCode(), CreateGLAccount.GoodsforResale(), CreateGLAccount.GoodsforResale());
            InsertData(XWEST, DemoDataSetup.ResaleCode(), CreateGLAccount.GoodsforResale(), CreateGLAccount.GoodsforResale());
        end;
    end;
}

