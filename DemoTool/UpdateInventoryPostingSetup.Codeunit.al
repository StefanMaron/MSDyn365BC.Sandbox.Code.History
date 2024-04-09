codeunit 118013 "Update Inventory Posting Setup"
{

    trigger OnRun()
    begin
        DemoDataSetup.Get();
        CreateInventoryPostingSetup.InsertData(XOUTLOG, DemoDataSetup.FinishedCode(), '992120', '992121');
        CreateInventoryPostingSetup.InsertData(XOUTLOG, DemoDataSetup.RawMatCode(), '992130', '992131');
        CreateInventoryPostingSetup.InsertData(XOUTLOG, DemoDataSetup.ResaleCode(), '992110', '992111');
        CreateInventoryPostingSetup.InsertData(XOWNLOG, DemoDataSetup.FinishedCode(), '992120', '992121');
        CreateInventoryPostingSetup.InsertData(XOWNLOG, DemoDataSetup.RawMatCode(), '992130', '992131');
        CreateInventoryPostingSetup.InsertData(XOWNLOG, DemoDataSetup.ResaleCode(), '992110', '992111');
    end;

    var
        DemoDataSetup: Record "Demo Data Setup";
        CreateGLAccount: Codeunit "Create G/L Account";
        XOUTLOG: Label 'OUT. LOG.';
        XOWNLOG: Label 'OWN LOG.';
        CreateInventoryPostingSetup: Codeunit "Create Inventory Posting Setup";

    procedure CreateEvaluationData()
    begin
        DemoDataSetup.Get();
        if DemoDataSetup."Data Type" = DemoDataSetup."Data Type"::Extended then begin
            CreateInventoryPostingSetup.InsertData(XOUTLOG, DemoDataSetup.ResaleCode(), '992110', '992111');
            CreateInventoryPostingSetup.InsertData(XOWNLOG, DemoDataSetup.ResaleCode(), '992110', '992111');
        end else begin
            CreateInventoryPostingSetup.InsertData(XOUTLOG, DemoDataSetup.ResaleCode(), CreateGLAccount.GoodsforResale(), CreateGLAccount.GoodsforResale());
            CreateInventoryPostingSetup.InsertData(XOWNLOG, DemoDataSetup.ResaleCode(), CreateGLAccount.GoodsforResale(), CreateGLAccount.GoodsforResale());
        end;
    end;
}

