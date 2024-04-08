codeunit 101110 "Create Inventory Posting Setup"
{

    trigger OnRun()
    begin
        with DemoDataSetup do begin
            Get();
            InsertData('', FinishedCode, '1260', '1261');
            InsertData('', RawMatCode, '1210', '1211');
            InsertData('', ResaleCode, '1200', '1201');
            InsertData(XBLUE, FinishedCode, '1260', '1261');
            InsertData(XBLUE, RawMatCode, '1210', '1211');
            InsertData(XBLUE, ResaleCode, '1200', '1201');
            InsertData(XGREEN, FinishedCode, '1260', '1261');
            InsertData(XGREEN, RawMatCode, '1210', '1211');
            InsertData(XGREEN, ResaleCode, '1200', '1201');
            InsertData(XRED, FinishedCode, '1260', '1261');
            InsertData(XRED, RawMatCode, '1210', '1211');
            InsertData(XRED, ResaleCode, '1200', '1201');
            InsertData(XYELLOW, FinishedCode, '1260', '1261');
            InsertData(XYELLOW, RawMatCode, '1210', '1211');
            InsertData(XYELLOW, ResaleCode, '1200', '1201');
            InsertData(XWHITE, FinishedCode, '1260', '1261');
            InsertData(XWHITE, RawMatCode, '1210', '1211');
            InsertData(XWHITE, ResaleCode, '1200', '1201');
            InsertData(XSILVER, FinishedCode, '1260', '1261');
            InsertData(XSILVER, RawMatCode, '1210', '1211');
            InsertData(XSILVER, ResaleCode, '1200', '1201');
        end;
    end;

    var
        DemoDataSetup: Record "Demo Data Setup";
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
            InsertData('', ResaleCode, '1200', '1201');
        end;
    end;

    procedure CreateEvaluationData()
    begin
        with DemoDataSetup do begin
            Get();
            InsertData(XMAIN, ResaleCode, '1200', '1201');
            InsertData(XEAST, ResaleCode, '1200', '1201');
            InsertData(XWEST, ResaleCode, '1200', '1201');
        end;
    end;
}

