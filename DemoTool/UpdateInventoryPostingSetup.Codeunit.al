codeunit 118013 "Update Inventory Posting Setup"
{

    trigger OnRun()
    begin
        with DemoDataSetup do begin
            Get();
            CreateInventoryPostingSetup.InsertData(XOUTLOG, FinishedCode, '1260', '1261');
            CreateInventoryPostingSetup.InsertData(XOUTLOG, RawMatCode, '1210', '1211');
            CreateInventoryPostingSetup.InsertData(XOUTLOG, ResaleCode, '1200', '1201');
            CreateInventoryPostingSetup.InsertData(XOWNLOG, FinishedCode, '1260', '1261');
            CreateInventoryPostingSetup.InsertData(XOWNLOG, RawMatCode, '1210', '1211');
            CreateInventoryPostingSetup.InsertData(XOWNLOG, ResaleCode, '1200', '1201');
        end;
    end;

    var
        DemoDataSetup: Record "Demo Data Setup";
        XOUTLOG: Label 'OUT. LOG.';
        XOWNLOG: Label 'OWN LOG.';
        CreateInventoryPostingSetup: Codeunit "Create Inventory Posting Setup";

    procedure CreateEvaluationData()
    begin
        with DemoDataSetup do begin
            Get();
            CreateInventoryPostingSetup.InsertData(XOUTLOG, ResaleCode, '1200', '1201');
            CreateInventoryPostingSetup.InsertData(XOWNLOG, ResaleCode, '1200', '1201');
        end;
    end;
}

