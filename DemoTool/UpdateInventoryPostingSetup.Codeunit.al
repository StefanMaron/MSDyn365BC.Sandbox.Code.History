codeunit 118013 "Update Inventory Posting Setup"
{

    trigger OnRun()
    begin
        with DemoDataSetup do begin
            Get();
            CreateInventoryPostingSetup.InsertData(XOUTLOG, FinishedCode, '992120', '992111');
            CreateInventoryPostingSetup.InsertData(XOUTLOG, RawMatCode, '992130', '992131');
            CreateInventoryPostingSetup.InsertData(XOUTLOG, ResaleCode, '992110', '992121');
            CreateInventoryPostingSetup.InsertData(XOWNLOG, FinishedCode, '992120', '992111');
            CreateInventoryPostingSetup.InsertData(XOWNLOG, RawMatCode, '992130', '992131');
            CreateInventoryPostingSetup.InsertData(XOWNLOG, ResaleCode, '992110', '992121');
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
            CreateInventoryPostingSetup.InsertData(XOUTLOG, ResaleCode, '992110', '992121');
            CreateInventoryPostingSetup.InsertData(XOWNLOG, ResaleCode, '992110', '992121');
        end;
    end;
}

