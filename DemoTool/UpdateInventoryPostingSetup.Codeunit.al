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
        CreateGLAccount: Codeunit "Create G/L Account";
        XOUTLOG: Label 'OUT. LOG.';
        XOWNLOG: Label 'OWN LOG.';
        CreateInventoryPostingSetup: Codeunit "Create Inventory Posting Setup";

    procedure CreateEvaluationData()
    begin
        with DemoDataSetup do begin
            Get();
            CreateInventoryPostingSetup.InsertData(XOUTLOG, ResaleCode, CreateGLAccount.FinishedGoods(), '');
            CreateInventoryPostingSetup.InsertData(XOWNLOG, ResaleCode, CreateGLAccount.FinishedGoods(), '');
        end;
    end;
}

