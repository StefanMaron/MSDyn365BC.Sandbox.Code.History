codeunit 101110 "Create Inventory Posting Setup"
{

    trigger OnRun()
    begin
        with DemoDataSetup do begin
            Get();
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
            InsertData('', ResaleCode, CreateGLAccount.FinishedGoods(), '');
        end;
    end;

    procedure CreateEvaluationData()
    begin
        with DemoDataSetup do begin
            Get();
            InsertData(XMAIN, ResaleCode, CreateGLAccount.FinishedGoods(), '');
            InsertData(XEAST, ResaleCode, CreateGLAccount.FinishedGoods(), '');
            InsertData(XWEST, ResaleCode, CreateGLAccount.FinishedGoods(), '');
        end;
    end;
}

