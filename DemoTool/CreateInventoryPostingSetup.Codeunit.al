codeunit 101110 "Create Inventory Posting Setup"
{

    trigger OnRun()
    begin
        with DemoDataSetup do begin
            Get();
            if DemoDataSetup."Data Type" = DemoDataSetup."Data Type"::Extended then begin
                InsertData('', FinishedCode, '992120', '992121');
                InsertData('', RawMatCode, '992130', '992131');
                InsertData('', ResaleCode, '992110', '992111');
                InsertData(XBLUE, FinishedCode, '992120', '992121');
                InsertData(XBLUE, RawMatCode, '992130', '992131');
                InsertData(XBLUE, ResaleCode, '992110', '992111');
                InsertData(XGREEN, FinishedCode, '992120', '992121');
                InsertData(XGREEN, RawMatCode, '992130', '992131');
                InsertData(XGREEN, ResaleCode, '992110', '992111');
                InsertData(XRED, FinishedCode, '992120', '992121');
                InsertData(XRED, RawMatCode, '992130', '992131');
                InsertData(XRED, ResaleCode, '992110', '992111');
                InsertData(XYELLOW, FinishedCode, '992120', '992121');
                InsertData(XYELLOW, RawMatCode, '992130', '992131');
                InsertData(XYELLOW, ResaleCode, '992110', '992111');
                InsertData(XWHITE, FinishedCode, '992120', '992121');
                InsertData(XWHITE, RawMatCode, '992130', '992131');
                InsertData(XWHITE, ResaleCode, '992110', '992111');
                InsertData(XSILVER, FinishedCode, '992120', '992121');
                InsertData(XSILVER, RawMatCode, '992130', '992131');
                InsertData(XSILVER, ResaleCode, '992110', '992111');
            end else begin
                InsertData('', FinishedCode, CreateGLAccount.FinishedGoods(), CreateGLAccount.FinishedGoods());
                InsertData('', RawMatCode, CreateGLAccount.RawMaterials(), CreateGLAccount.RawMaterials());
                InsertData('', ResaleCode, CreateGLAccount.GoodsforResale(), CreateGLAccount.GoodsforResale());
                InsertData(XBLUE, FinishedCode, CreateGLAccount.FinishedGoods(), CreateGLAccount.FinishedGoods());
                InsertData(XBLUE, RawMatCode, CreateGLAccount.RawMaterials(), CreateGLAccount.RawMaterials());
                InsertData(XBLUE, ResaleCode, CreateGLAccount.GoodsforResale(), CreateGLAccount.GoodsforResale());
                InsertData(XGREEN, FinishedCode, CreateGLAccount.FinishedGoods(), CreateGLAccount.FinishedGoods());
                InsertData(XGREEN, RawMatCode, CreateGLAccount.RawMaterials(), CreateGLAccount.RawMaterials());
                InsertData(XGREEN, ResaleCode, CreateGLAccount.GoodsforResale(), CreateGLAccount.GoodsforResale());
                InsertData(XRED, FinishedCode, CreateGLAccount.FinishedGoods(), CreateGLAccount.FinishedGoods());
                InsertData(XRED, RawMatCode, CreateGLAccount.RawMaterials(), CreateGLAccount.RawMaterials());
                InsertData(XRED, ResaleCode, CreateGLAccount.GoodsforResale(), CreateGLAccount.GoodsforResale());
                InsertData(XYELLOW, FinishedCode, CreateGLAccount.FinishedGoods(), CreateGLAccount.FinishedGoods());
                InsertData(XYELLOW, RawMatCode, CreateGLAccount.RawMaterials(), CreateGLAccount.RawMaterials());
                InsertData(XYELLOW, ResaleCode, CreateGLAccount.GoodsforResale(), CreateGLAccount.GoodsforResale());
                InsertData(XWHITE, FinishedCode, CreateGLAccount.FinishedGoods(), CreateGLAccount.FinishedGoods());
                InsertData(XWHITE, RawMatCode, CreateGLAccount.RawMaterials(), CreateGLAccount.RawMaterials());
                InsertData(XWHITE, ResaleCode, CreateGLAccount.GoodsforResale(), CreateGLAccount.GoodsforResale());
                InsertData(XSILVER, FinishedCode, CreateGLAccount.FinishedGoods(), CreateGLAccount.FinishedGoods());
                InsertData(XSILVER, RawMatCode, CreateGLAccount.RawMaterials(), CreateGLAccount.RawMaterials());
                InsertData(XSILVER, ResaleCode, CreateGLAccount.GoodsforResale(), CreateGLAccount.GoodsforResale());
            end;
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
        with DemoDataSetup do begin
            Get();
            InsertData('', ResaleCode, CreateGLAccount.GoodsforResale(), '');
        end;
    end;

    procedure CreateEvaluationData()
    begin
        with DemoDataSetup do begin
            Get();
            if DemoDataSetup."Data Type" = DemoDataSetup."Data Type"::Extended then begin
                InsertData(XMAIN, ResaleCode, '992110', '992111');
                InsertData(XEAST, ResaleCode, '992110', '992111');
                InsertData(XWEST, ResaleCode, '992110', '992111');
            end else begin
                InsertData(XMAIN, ResaleCode, CreateGLAccount.GoodsforResale(), CreateGLAccount.GoodsforResale());
                InsertData(XEAST, ResaleCode, CreateGLAccount.GoodsforResale(), CreateGLAccount.GoodsforResale());
                InsertData(XWEST, ResaleCode, CreateGLAccount.GoodsforResale(), CreateGLAccount.GoodsforResale());
            end;
        end;
    end;
}

