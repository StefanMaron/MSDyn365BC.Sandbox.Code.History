// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Journal;

using Microsoft.Finance.Dimension;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.UOM;
using Microsoft.Inventory.Costing;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using Microsoft.Manufacturing.Capacity;
using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.Journal;
using Microsoft.Manufacturing.MachineCenter;
using Microsoft.Manufacturing.WorkCenter;
using Microsoft.Manufacturing.Setup;
using Microsoft.Pricing.PriceList;
using Microsoft.Purchases.Setup;

codeunit 99000762 "Mfg. Item Journal Mgt."
{
    var
#pragma warning disable AA0470
        CannotChangeFieldErr: Label 'You cannot change %1 when %2 is %3.', Comment = '%1 %2 - field captions, %3 - field value';
        CannotInsertItemErr: Label 'You can not insert item number %1 because it is not produced on released production order %2.';
#pragma warning restore AA0470

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnValidateUnitAmountOnUpdateByEntryType', '', true, true)]
    local procedure OnValidateUnitAmountOnUpdateByEntryType(var ItemJournalLine: Record "Item Journal Line"; CurrentFieldNo: Integer)
    var
        Item: Record Item;
    begin
        case ItemJournalLine."Entry Type" of
            ItemJournalLine."Entry Type"::Consumption:
                begin
                    Item.Get(ItemJournalLine."Item No.");
                    if (CurrentFieldNo = ItemJournalLine.FieldNo("Unit Amount")) and
                        (Item."Costing Method" = Item."Costing Method"::Standard)
                    then
                        Error(
                            CannotChangeFieldErr,
                            ItemJournalLine.FieldCaption("Unit Amount"), Item.FieldCaption("Costing Method"), Item."Costing Method");
                    ItemJournalLine."Unit Cost" := ItemJournalLine."Unit Amount";
                    if (ItemJournalLine."Value Entry Type" = ItemJournalLine."Value Entry Type"::"Direct Cost") and
                        (ItemJournalLine."Item Charge No." = '')
                    then
                        ItemJournalLine.Validate("Unit Cost");
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnValidateUnitCostOnUpdateByEntryType', '', true, true)]
    local procedure OnValidateUnitCostOnUpdateByEntryType(var ItemJournalLine: Record "Item Journal Line"; CurrentFieldNo: Integer)
    var
        Item: Record Item;
    begin
        case ItemJournalLine."Entry Type" of
            ItemJournalLine."Entry Type"::Consumption:
                begin
                    if Item."Costing Method" = Item."Costing Method"::Standard then
                        Error(
                            CannotChangeFieldErr,
                            ItemJournalLine.FieldCaption("Unit Cost"), Item.FieldCaption("Costing Method"), Item."Costing Method");
                    ItemJournalLine."Unit Amount" := ItemJournalLine."Unit Cost";
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnValidateItemNoOnSetCostAndPrice', '', true, true)]
    local procedure OnValidateItemNoOnSetCostAndPrice(var ItemJournalLine: Record "Item Journal Line"; UnitCost: Decimal)
    begin
        case ItemJournalLine."Entry Type" of
            ItemJournalLine."Entry Type"::Output:
                ItemJournalLine.ApplyPrice("Price Type"::Purchase, ItemJournalLine.FieldNo("Item No."));
            ItemJournalLine."Entry Type"::Consumption:
                ItemJournalLine."Unit Amount" := UnitCost;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnValidateItemNoOnAfterValidateUnitofMeasureCode', '', true, true)]
    local procedure OnValidateItemNoOnAfterValidateUnitofMeasureCode(var ItemJournalLine: Record "Item Journal Line"; var xItemJournalLine: Record "Item Journal Line"; var Item: Record Item; CurrentFieldNo: Integer)
    var
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderComp: Record "Prod. Order Component";
        ShouldCopyFromSingleProdOrderLine: Boolean;
        ShouldThrowRevaluationError: Boolean;
    begin
        case ItemJournalLine."Entry Type" of
            ItemJournalLine."Entry Type"::Output:
                begin
                    Item.TestField("Inventory Value Zero", false);
                    ProdOrderLine.SetFilterByReleasedOrderNo(ItemJournalLine."Order No.");
                    ProdOrderLine.SetRange("Item No.", ItemJournalLine."Item No.");
                    ItemJournalLine.RunOnValidateItemNoOnAfterSetProdOrderLineItemNoFilter(ItemJournalLine, xItemJournalLine, ProdOrderLine);
                    if ProdOrderLine.FindFirst() then begin
                        ItemJournalLine."Routing No." := ProdOrderLine."Routing No.";
                        ItemJournalLine."Source Type" := ItemJournalLine."Source Type"::Item;
                        ItemJournalLine."Source No." := ProdOrderLine."Item No.";
                    end else begin
                        ShouldThrowRevaluationError := (ItemJournalLine."Value Entry Type" <> ItemJournalLine."Value Entry Type"::Revaluation) and (CurrentFieldNo <> 0);
                        ItemJournalLine.RunOnValidateItemNoOnAfterCalcShouldThrowRevaluationError(ItemJournalLine, ShouldThrowRevaluationError);
                        if ShouldThrowRevaluationError then
                            Error(CannotInsertItemErr, ItemJournalLine."Item No.", ItemJournalLine."Order No.");
                    end;

                    ShouldCopyFromSingleProdOrderLine := ProdOrderLine.Count = 1;
                    ItemJournalLine.RunOnValidateItemNoOnAfterCalcShouldCopyFromSingleProdOrderLine(ItemJournalLine, xItemJournalLine, ProdOrderLine, ShouldCopyFromSingleProdOrderLine);
                    if ShouldCopyFromSingleProdOrderLine then
                        ItemJournalLine.CopyFromProdOrderLine(ProdOrderLine)
                    else
                        if ItemJournalLine."Order Line No." <> 0 then begin
                            ProdOrderLine.SetRange("Line No.", ItemJournalLine."Order Line No.");
                            if ProdOrderLine.FindFirst() then
                                ItemJournalLine.CopyFromProdOrderLine(ProdOrderLine)
                            else
                                ItemJournalLine."Unit of Measure Code" := Item."Base Unit of Measure";
                        end else
                            ItemJournalLine."Unit of Measure Code" := Item."Base Unit of Measure";
                end;
            ItemJournalLine."Entry Type"::Consumption:
                if ItemJournalLine.FindProdOrderComponent(ProdOrderComp) then
                    ItemJournalLine.CopyFromProdOrderComp(ProdOrderComp)
                else begin
                    ItemJournalLine."Unit of Measure Code" := Item."Base Unit of Measure";
                    ItemJournalLine.Validate("Prod. Order Comp. Line No.", 0);
                    ItemJournalLine.RunOnValidateItemNoOnAfterValidateProdOrderCompLineNo(ItemJournalLine, ProdOrderLine);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnValidateOrderNoOnCaseOrderTypeElse', '', true, true)]
    local procedure OnValidateOrderNoOnCaseOrderTypeElse(var ItemJournalLine: Record "Item Journal Line"; var xItemJournalLine: Record "Item Journal Line")
    var
        ManufacturingSetup: Record "Manufacturing Setup";
        ProdOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
    begin
        case ItemJournalLine."Order Type" of
            ItemJournalLine."Order Type"::Production:
                begin
                    if ItemJournalLine."Order No." = '' then begin
                        ItemJournalLine.CreateProdDim();
                        exit;
                    end;

                    ManufacturingSetup.Get();
                    if ManufacturingSetup."Doc. No. Is Prod. Order No." then
                        ItemJournalLine."Document No." := ItemJournalLine."Order No.";
                    ProdOrder.Get(ProdOrder.Status::Released, ItemJournalLine."Order No.");
                    ProdOrder.TestField(Blocked, false);
                    ItemJournalLine.Description := ProdOrder.Description;
                    ItemJournalLine.RunOnValidateOrderNoOrderTypeProduction(ItemJournalLine, ProdOrder);

                    ItemJournalLine."Gen. Bus. Posting Group" := ProdOrder."Gen. Bus. Posting Group";
                    case true of
                        ItemJournalLine."Entry Type" = ItemJournalLine."Entry Type"::Output:
                            begin
                                ItemJournalLine."Inventory Posting Group" := ProdOrder."Inventory Posting Group";
                                ItemJournalLine."Gen. Prod. Posting Group" := ProdOrder."Gen. Prod. Posting Group";
                            end;
                        ItemJournalLine."Entry Type" = ItemJournalLine."Entry Type"::Consumption:
                            begin
                                ProdOrderLine.SetFilterByReleasedOrderNo(ItemJournalLine."Order No.");
                                if ProdOrderLine.Count = 1 then begin
                                    ProdOrderLine.FindFirst();
                                    ItemJournalLine.Validate("Order Line No.", ProdOrderLine."Line No.");
                                end;
                            end;
                    end;

                    if (ItemJournalLine."Order No." <> xItemJournalLine."Order No.") or (ItemJournalLine."Order Type" <> xItemJournalLine."Order Type") then
                        ItemJournalLine.CreateProdDim();
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnValidateOrderLineNoOnCaseOrderTypeElse', '', true, true)]
    local procedure OnValidateOrderLineNoOnCaseOrderTypeElse(var ItemJournalLine: Record "Item Journal Line"; var xItemJournalLine: Record "Item Journal Line")
    var
        ProdOrderLine: Record "Prod. Order Line";
    begin
        case ItemJournalLine."Order Type" of
            ItemJournalLine."Order Type"::Production:
                begin
                    ProdOrderLine.SetFilterByReleasedOrderNo(ItemJournalLine."Order No.");
                    ProdOrderLine.SetRange("Line No.", ItemJournalLine."Order Line No.");
                    ItemJournalLine.RunOnValidateOrderLineNoOnAfterProdOrderLineSetFilters(ItemJournalLine, ProdOrderLine);
                    if ProdOrderLine.FindFirst() then begin
                        ItemJournalLine."Source Type" := ItemJournalLine."Source Type"::Item;
                        ItemJournalLine."Source No." := ProdOrderLine."Item No.";
                        ItemJournalLine."Order Line No." := ProdOrderLine."Line No.";
                        ItemJournalLine."Routing No." := ProdOrderLine."Routing No.";
                        ItemJournalLine."Routing Reference No." := ProdOrderLine."Routing Reference No.";
                        if ItemJournalLine."Entry Type" = ItemJournalLine."Entry Type"::Output then begin
                            ItemJournalLine."Location Code" := ProdOrderLine."Location Code";
                            ItemJournalLine."Bin Code" := ProdOrderLine."Bin Code";
                        end;
                        ItemJournalLine.RunOnOrderLineNoOnValidateOnAfterAssignProdOrderLineValues(ItemJournalLine, ProdOrderLine);
                    end;

                    if ItemJournalLine."Order Line No." <> xItemJournalLine."Order Line No." then
                        ItemJournalLine.CreateProdDim();
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterSigned', '', true, true)]
    local procedure OnAfterSigned(ItemJournalLine: Record "Item Journal Line"; Value: Decimal; var Result: Decimal)
    begin
        case ItemJournalLine."Entry Type" of
            ItemJournalLine."Entry Type"::Output:
                Result := Value;
            ItemJournalLine."Entry Type"::Consumption:
                Result := -Value;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterCheckEntryType', '', true, true)]
    local procedure OnAfterCheckEntryType(var ItemJournalLine: Record "Item Journal Line")
    begin
        if ItemJournalLine.Type <> ItemJournalLine.Type::Resource then
            ItemJournalLine.TestField("Entry Type", ItemJournalLine."Entry Type"::Output);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterSetDefaultPriceCalculationMethod', '', true, true)]
    local procedure OnAfterSetDefaultPriceCalculationMethod(var ItemJournalLine: Record "Item Journal Line")
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        case ItemJournalLine."Entry Type" of
            ItemJournalLine."Entry Type"::Output:
                begin
                    PurchasesPayablesSetup.Get();
                    ItemJournalLine."Price Calculation Method" := PurchasesPayablesSetup."Price Calculation Method";
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnValidateCapUnitOfMeasureCodeOnSetQtyPerCapUnitOfMeasure', '', true, true)]
    local procedure OnValidateCapUnitOfMeasureCodeOnSetQtyPerCapUnitOfMeasure(var ItemJournalLine: Record "Item Journal Line")
    var
        ShopCalendarMgt: Codeunit "Shop Calendar Management";
        UOMMgt: Codeunit "Unit of Measure Management";
    begin
        ItemJournalLine."Qty. per Cap. Unit of Measure" :=
            Round(
                ShopCalendarMgt.QtyperTimeUnitofMeasure(ItemJournalLine."Work Center No.", ItemJournalLine."Cap. Unit of Measure Code"),
                UOMMgt.QtyRndPrecision());

        ItemJournalLine.Validate("Setup Time");
        ItemJournalLine.Validate("Run Time");
        ItemJournalLine.Validate("Stop Time");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnValidateCapUnitOfMeasureCodeOnCaseOrderTypeElse', '', true, true)]
    local procedure OnValidateCapUnitOfMeasureCodeOnCaseOrderTypeElse(var ItemJournalLine: Record "Item Journal Line")
    var
        ProdOrderRtngLine: Record "Prod. Order Routing Line";
        MfgCostCalculationMgt: Codeunit "Mfg. Cost Calculation Mgt.";
        IsHandled: Boolean;
    begin
        case ItemJournalLine."Order Type" of
            ItemJournalLine."Order Type"::Production:
                begin
                    ItemJournalLine.GetProdOrderRoutingLine(ProdOrderRtngLine);
                    ItemJournalLine."Unit Cost" := ProdOrderRtngLine."Unit Cost per";
                    ItemJournalLine.RunOnValidateCapUnitofMeasureCodeOnBeforeRoutingCostPerUnit(ItemJournalLine, ProdOrderRtngLine, IsHandled);
                    if not IsHandled then
                        MfgCostCalculationMgt.CalcRoutingCostPerUnit(
                            ItemJournalLine.Type, ItemJournalLine."No.", ItemJournalLine."Unit Amount", ItemJournalLine."Indirect Cost %",
                            ItemJournalLine."Overhead Rate", ItemJournalLine."Unit Cost", ItemJournalLine."Unit Cost Calculation");
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnValidateEntryTypeOnUpdateByEntryType', '', true, true)]
    local procedure OnValidateEntryTypeOnUpdateByEntryType(var ItemJournalLine: Record "Item Journal Line")
    begin
        case ItemJournalLine."Entry Type" of
            ItemJournalLine."Entry Type"::Consumption, ItemJournalLine."Entry Type"::Output:
                ItemJournalLine.Validate("Order Type", ItemJournalLine."Order Type"::Production);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnValidateNoOnAfterValidateItemNo', '', true, true)]
    local procedure OnValidateNoOnAfterValidateItemNo(var ItemJournalLine: Record "Item Journal Line")
    begin
        if ItemJournalLine.Type in [ItemJournalLine.Type::"Work Center", ItemJournalLine.Type::"Machine Center"] then
            ItemJournalLine.CreateDimWithProdOrderLine()
        else
            ItemJournalLine.CreateDimFromDefaultDim(ItemJournalLine.FieldNo("Work Center No."));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnValidateNoOnBeforeValidateItemNo', '', true, true)]
    local procedure OnValidateNoOnBeforeValidateItemNo(var ItemJournalLine: Record "Item Journal Line")
    begin
        ItemJournalLine."Work Center No." := '';
        ItemJournalLine."Work Center Group Code" := '';
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnValidateQuantityOnAfterSetCallWhseCheck', '', true, true)]
    local procedure OnValidateQuantityOnAfterSetCallWhseCheck(var ItemJournalLine: Record "Item Journal Line"; var CallWhseCheck: Boolean)
    begin
        CallWhseCheck :=
            CallWhseCheck or (ItemJournalLine."Entry Type" = ItemJournalLine."Entry Type"::Output) and
            ItemJournalLine.LastOutputOperation(ItemJournalLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnSelectItemEntryOnSetFilters', '', true, true)]
    local procedure OnSelectItemEntryOnSetFilters(var ItemJournalLine: Record "Item Journal Line"; var ItemLedgerEntry: Record "Item Ledger Entry"; CurrentFieldNo: Integer; var IsHandled: Boolean)
    begin
        if (ItemJournalLine."Entry Type" = ItemJournalLine."Entry Type"::Output) and
           (ItemJournalLine."Value Entry Type" <> ItemJournalLine."Value Entry Type"::Revaluation) and
           (CurrentFieldNo = ItemJournalLine.FieldNo("Applies-to Entry"))
        then begin
            ItemLedgerEntry.SetCurrentKey(
              "Order Type", "Order No.", "Order Line No.", "Entry Type", "Prod. Order Comp. Line No.");
            ItemLedgerEntry.SetRange("Order Type", ItemLedgerEntry."Order Type"::Production);
            ItemLedgerEntry.SetRange("Order No.", ItemJournalLine."Order No.");
            ItemLedgerEntry.SetRange("Order Line No.", ItemJournalLine."Order Line No.");
            ItemLedgerEntry.SetRange("Entry Type", ItemJournalLine."Entry Type");
            ItemLedgerEntry.SetRange("Prod. Order Comp. Line No.", 0);
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnValidateBinCodeOnCompBinCheck', '', true, true)]
    local procedure OnValidateBinCodeOnCompBinCheck(var ItemJournalLine: Record "Item Journal Line")
    begin
        if (ItemJournalLine."Entry Type" = ItemJournalLine."Entry Type"::Consumption) and
           (ItemJournalLine."Bin Code" <> '') and (ItemJournalLine."Prod. Order Comp. Line No." <> 0)
        then begin
            ItemJournalLine.TestField("Order Type", ItemJournalLine."Order Type"::Production);
            ItemJournalLine.TestField("Order No.");
            ItemJournalLine.CheckProdOrderCompBinCode();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnBeforeLookupItemNo', '', true, true)]
    local procedure OnBeforeLookupItemNo(var ItemJournalLine: Record "Item Journal Line"; var IsHandled: Boolean)
    begin
        case ItemJournalLine."Entry Type" of
            ItemJournalLine."Entry Type"::Consumption:
                begin
                    ItemJournalLine.LookupProdOrderComp();
                    IsHandled := true;
                end;
            ItemJournalLine."Entry Type"::Output:
                begin
                    ItemJournalLine.LookupProdOrderLine();
                    IsHandled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterValidateNo', '', true, true)]
    local procedure OnAfterValidateNo(var ItemJournalLine: Record "Item Journal Line")
    var
        MachineCenter: Record "Machine Center";
        WorkCenter: Record "Work Center";
    begin
        case ItemJournalLine.Type of
            ItemJournalLine.Type::"Work Center":
                begin
                    WorkCenter.Get(ItemJournalLine."No.");
                    WorkCenter.TestField(Blocked, false);
                    ItemJournalLine.CopyFromWorkCenter(WorkCenter);
                end;
            ItemJournalLine.Type::"Machine Center":
                begin
                    MachineCenter.Get(ItemJournalLine."No.");
                    MachineCenter.TestField(Blocked, false);
                    WorkCenter.Get(MachineCenter."Work Center No.");
                    WorkCenter.TestField(Blocked, false);
                    ItemJournalLine.CopyFromMachineCenter(MachineCenter);
                end;
        end;

        if ItemJournalLine.Type in [ItemJournalLine.Type::"Work Center", ItemJournalLine.Type::"Machine Center"] then begin
            ItemJournalLine."Work Center No." := WorkCenter."No.";
            ItemJournalLine."Work Center Group Code" := WorkCenter."Work Center Group Code";
            ItemJournalLine.ErrorIfSubcontractingWorkCenterUsed();
            ItemJournalLine.Validate("Cap. Unit of Measure Code", WorkCenter."Unit of Measure Code");
        end;

        if ItemJournalLine."Work Center No." <> '' then
            ItemJournalLine.CreateDimWithProdOrderLine();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterIsEntryTypeConsumption', '', true, true)]
    local procedure OnAfterIsEntryTypeConsumption(var ItemJournalLine: Record "Item Journal Line"; var Result: Boolean)
    begin
        if ItemJournalLine."Entry Type" = ItemJournalLine."Entry Type"::Consumption then
            Result := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterIsEntryTypeProduction', '', true, true)]
    local procedure OnAfterIsEntryTypeProduction(var ItemJournalLine: Record "Item Journal Line"; var Result: Boolean)
    begin
        if ItemJournalLine."Entry Type" in [ItemJournalLine."Entry Type"::Consumption, ItemJournalLine."Entry Type"::Output] then
            Result := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterIsOrderTypeAsmOrProd', '', true, true)]
    local procedure OnAfterIsOrderTypeAsmOrProd(var ItemJournalLine: Record "Item Journal Line"; var Result: Boolean)
    begin
        if ItemJournalLine."Order Type" = ItemJournalLine."Order Type"::Production then
            Result := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterIsDocNoProdOrderNo', '', true, true)]
    local procedure OnAfterIsDocNoProdOrderNo(var ItemJournalLine: Record "Item Journal Line"; var Result: Boolean)
    var
        ManufacturingSetup: Record "Manufacturing Setup";
    begin
        ManufacturingSetup.Get();
        Result := ManufacturingSetup."Doc. No. Is Prod. Order No.";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnTimeIsEmpty', '', true, true)]
    local procedure OnTimeIsEmpty(var ItemJournalLine: Record "Item Journal Line"; var Result: Boolean)
    begin
        Result := (ItemJournalLine."Setup Time" = 0) and (ItemJournalLine."Run Time" = 0) and (ItemJournalLine."Stop Time" = 0);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterInitDefaultDimensionSources', '', true, true)]
    local procedure OnAfterInitDefaultDimensionSources(var ItemJournalLine: Record "Item Journal Line"; var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]]; FieldNo: Integer)
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimMgt.AddDimSource(DefaultDimSource, Database::"Work Center", ItemJournalLine."Work Center No.", FieldNo = ItemJournalLine.FieldNo("Work Center No."));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterInitTableValuePair', '', true, true)]
    local procedure OnAfterInitTableValuePair(var ItemJournalLine: Record "Item Journal Line"; var TableValuePair: Dictionary of [Integer, Code[20]]; FieldNo: Integer)
    begin
        if FieldNo = ItemJournalLine.FieldNo("Work Center No.") then
            TableValuePair.Add(Database::"Work Center", ItemJournalLine."Work Center No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnValidateUnitOfMeasureCodeOnBeforeValidateQuantity', '', true, true)]
    local procedure OnValidateUnitOfMeasureCodeOnBeforeValidateQuantity(var ItemJournalLine: Record "Item Journal Line"; var IsHandled: Boolean);
    begin
        if ItemJournalLine."Entry Type" = ItemJournalLine."Entry Type"::Output then begin
            ItemJournalLine.Validate("Output Quantity");
            ItemJournalLine.Validate("Scrap Quantity");
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Standard Item Journal Line", 'OnAfterInitDefaultDimensionSources', '', true, true)]
    local procedure StandardItemJournalLineOnAfterInitDefaultDimensionSources(var StandardItemJournalLine: Record "Standard Item Journal Line"; var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]]; FieldNo: Integer)
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimMgt.AddDimSource(DefaultDimSource, Database::"Work Center", StandardItemJournalLine."Work Center No.", FieldNo = StandardItemJournalLine.FieldNo("Work Center No."));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Template", 'OnAfterValidateType', '', true, true)]
    local procedure OnAfterValidateType(var ItemJournalTemplate: Record "Item Journal Template"; SourceCodeSetup: Record "Source Code Setup")
    begin
        case ItemJournalTemplate.Type of
            ItemJournalTemplate.Type::Consumption:
                begin
                    ItemJournalTemplate."Source Code" := SourceCodeSetup."Consumption Journal";
                    ItemJournalTemplate."Page ID" := Page::"Consumption Journal";
                end;
            ItemJournalTemplate.Type::Output:
                begin
                    ItemJournalTemplate."Source Code" := SourceCodeSetup."Output Journal";
                    ItemJournalTemplate."Page ID" := Page::"Output Journal";
                end;
            ItemJournalTemplate.Type::Capacity:
                begin
                    ItemJournalTemplate."Source Code" := SourceCodeSetup."Capacity Journal";
                    ItemJournalTemplate."Page ID" := Page::"Capacity Journal";
                end;
            ItemJournalTemplate.Type::"Prod. Order":
                begin
                    ItemJournalTemplate."Source Code" := SourceCodeSetup."Production Journal";
                    ItemJournalTemplate."Page ID" := Page::"Production Journal";
                end;
        end;
        if ItemJournalTemplate.Recurring then
            case ItemJournalTemplate.Type of
                ItemJournalTemplate.Type::Consumption:
                    ItemJournalTemplate."Page ID" := Page::"Recurring Consumption Journal";
                ItemJournalTemplate.Type::Output:
                    ItemJournalTemplate."Page ID" := Page::"Recurring Output Journal";
                ItemJournalTemplate.Type::Capacity:
                    ItemJournalTemplate."Page ID" := Page::"Recurring Capacity Journal";
            end;
    end;

    // Item Journal Management

    var
        OldCapNo: Code[20];
        OldCapType: Enum "Capacity Type";
        OldProdOrderNo: Code[20];
        OldOperationNo: Code[20];

    procedure GetConsump(var ItemJnlLine: Record "Item Journal Line"; var ProdOrderDescription: Text[100])
    var
        ProdOrder: Record "Production Order";
    begin
        if (ItemJnlLine."Order Type" = ItemJnlLine."Order Type"::Production) and (ItemJnlLine."Order No." <> OldProdOrderNo) then begin
            ProdOrderDescription := '';
            if ProdOrder.Get(ProdOrder.Status::Released, ItemJnlLine."Order No.") then
                ProdOrderDescription := ProdOrder.Description;
            OldProdOrderNo := ProdOrder."No.";
        end;
    end;

    procedure GetOutput(var ItemJnlLine: Record "Item Journal Line"; var ProdOrderDescription: Text[100]; var OperationDescription: Text[100])
    var
        ProdOrder: Record "Production Order";
        ProdOrderRtngLine: Record "Prod. Order Routing Line";
    begin
        if (ItemJnlLine."Operation No." <> OldOperationNo) or
           ((ItemJnlLine."Order Type" = ItemJnlLine."Order Type"::Production) and (ItemJnlLine."Order No." <> OldProdOrderNo))
        then begin
            OperationDescription := '';
            if ProdOrderRtngLine.Get(
                 ProdOrder.Status::Released,
                 ItemJnlLine."Order No.",
                 ItemJnlLine."Routing Reference No.",
                 ItemJnlLine."Routing No.",
                 ItemJnlLine."Operation No.")
            then
                OperationDescription := ProdOrderRtngLine.Description;
            OldOperationNo := ProdOrderRtngLine."Operation No.";
        end;

        if (ItemJnlLine."Order Type" = ItemJnlLine."Order Type"::Production) and (ItemJnlLine."Order No." <> OldProdOrderNo) then begin
            ProdOrderDescription := '';
            if ProdOrder.Get(ProdOrder.Status::Released, ItemJnlLine."Order No.") then
                ProdOrderDescription := ProdOrder.Description;
            OldProdOrderNo := ProdOrder."No.";
        end;
    end;

    procedure GetCapacity(CapType: Enum "Capacity Type"; CapNo: Code[20]; var CapDescription: Text[100])
    var
        WorkCenter: Record "Work Center";
        MachineCenter: Record "Machine Center";
    begin
        if (CapNo <> OldCapNo) or (CapType <> OldCapType) then begin
            CapDescription := '';
            if CapNo <> '' then
                case CapType of
                    CapType::"Work Center":
                        if WorkCenter.Get(CapNo) then
                            CapDescription := WorkCenter.Name;
                    CapType::"Machine Center":
                        if MachineCenter.Get(CapNo) then
                            CapDescription := MachineCenter.Name;
                end;
            OldCapNo := CapNo;
            OldCapType := CapType;
        end;
    end;
}