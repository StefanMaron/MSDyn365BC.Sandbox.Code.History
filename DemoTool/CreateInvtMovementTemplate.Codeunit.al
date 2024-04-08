codeunit 163543 "Create Invt. Mvmt. Templ. CZL"
{
    trigger OnRun()
    begin
        with DemoDataSetup do begin
            InsertData(XSURPLUS, XPhysicalInventorySurplus, 2, ISurplusCode());
            InsertData(XDEFICIENCY, XPhysicalInventoryDeficiency, 3, IDeficiencyCode());
            InsertData(XTRANSFER, XInventoryTransfer, 4, ITransferCode());
        end;
    end;

    var
        DemoDataSetup: Record "Demo Data Setup";
        XSURPLUS: Label 'SURPLUS';
        XDEFICIENCY: Label 'DEFICIENCY';
        XTRANSFER: Label 'TRANSFER';
        XPhysicalInventorySurplus: Label 'Physical Inventory Surplus';
        XPhysicalInventoryDeficiency: Label 'Physical Inventory Deficiency';
        XInventoryTransfer: Label 'Inventory Transfer';

    procedure InsertData(Name: Code[10]; Description: Text[80]; EntryType: Option; GenBusPostingGroup: Code[20])
    var
        InvtMovementTemplateCZL: Record "Invt. Movement Template CZL";
    begin
        InvtMovementTemplateCZL.Init();
        InvtMovementTemplateCZL.Name := Name;
        InvtMovementTemplateCZL.Description := Description;
        InvtMovementTemplateCZL."Entry Type" := EntryType;
        InvtMovementTemplateCZL."Gen. Bus. Posting Group" := GenBusPostingGroup;
        InvtMovementTemplateCZL.Insert();
    end;

    procedure GetSurplusCode(): Code[10]
    begin
        exit(XSURPLUS);
    end;

    procedure GetDeficiencyCode(): Code[10]
    begin
        exit(XDEFICIENCY);
    end;
}