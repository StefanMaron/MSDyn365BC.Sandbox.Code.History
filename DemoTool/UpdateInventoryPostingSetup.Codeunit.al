codeunit 118013 "Update Inventory Posting Setup"
{

    trigger OnRun()
    begin
        with DemoDataSetup do begin
            Get();
            CreateInventoryPostingSetup.InsertData(XOUTLOG, FinishedCode, '992120', '992121');
            CreateInventoryPostingSetup.InsertData(XOUTLOG, RawMatCode, '992130', '992131');
            CreateInventoryPostingSetup.InsertData(XOUTLOG, ResaleCode, '992110', '992111');
            CreateInventoryPostingSetup.InsertData(XOWNLOG, FinishedCode, '992120', '992121');
            CreateInventoryPostingSetup.InsertData(XOWNLOG, RawMatCode, '992130', '992131');
            CreateInventoryPostingSetup.InsertData(XOWNLOG, ResaleCode, '992110', '992111');
        end;
    end;

    var
        DemoDataSetup: Record "Demo Data Setup";
        GetGLAccNo: Codeunit "Get G/L Account No. and Name";
        XOUTLOG: Label 'OUT. LOG.';
        XOWNLOG: Label 'OWN LOG.';
        CreateInventoryPostingSetup: Codeunit "Create Inventory Posting Setup";

    procedure CreateEvaluationData()
    begin
        with DemoDataSetup do begin
            Get();
            CreateInventoryPostingSetup.InsertData(XOUTLOG, ResaleCode, GetGLAccNo.ResaleItems(), GetGLAccNo.ResaleItemsInterim(), '', '', '', '', '', '');
            CreateInventoryPostingSetup.InsertData(XOWNLOG, ResaleCode, GetGLAccNo.ResaleItems(), GetGLAccNo.ResaleItemsInterim(), '', '', '', '', '', '');
            CreateInventoryPostingSetup.InsertData(XOUTLOG, FinishedCode(), GetGLAccNo.FinishedGoods(), GetGLAccNo.FinishedGoodsInterim(), '', '', '', '', '', '');
            CreateInventoryPostingSetup.InsertData(XOWNLOG, FinishedCode(), GetGLAccNo.FinishedGoods(), GetGLAccNo.FinishedGoodsInterim(), '', '', '', '', '', '');
            CreateInventoryPostingSetup.InsertData(XOUTLOG, RawMatCode(), GetGLAccNo.RawMaterials(), GetGLAccNo.RawMaterialsInterim(), '', '', '', '', '', '');
            CreateInventoryPostingSetup.InsertData(XOWNLOG, RawMatCode(), GetGLAccNo.RawMaterials(), GetGLAccNo.RawMaterialsInterim(), '', '', '', '', '', '');
        end;
    end;
}

