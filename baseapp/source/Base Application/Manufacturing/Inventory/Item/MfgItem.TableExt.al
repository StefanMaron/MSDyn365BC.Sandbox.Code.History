// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Item;

using Microsoft.Inventory.Costing;
using Microsoft.Inventory.Planning;
using Microsoft.Inventory.Setup;
using Microsoft.Inventory.Tracking;
using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.Forecast;
using Microsoft.Manufacturing.ProductionBOM;
using Microsoft.Manufacturing.Routing;
using Microsoft.Manufacturing.Setup;

tableextension 99000750 "Mfg. Item" extends Item
{
    fields
    {
        field(200; "Cost of Open Production Orders"; Decimal)
        {
            CalcFormula = sum("Prod. Order Line"."Cost Amount" where(Status = filter(Planned | "Firm Planned" | Released),
                                                                      "Item No." = field("No.")));
            Caption = 'Cost of Open Production Orders';
            FieldClass = FlowField;
        }
        field(5417; "Flushing Method"; Enum "Flushing Method")
        {
            Caption = 'Flushing Method';
            DataClassification = CustomerContent;
        }
        field(5420; "Scheduled Receipt (Qty.)"; Decimal)
        {
            CalcFormula = sum("Prod. Order Line"."Remaining Qty. (Base)" where(Status = filter("Firm Planned" | Released),
                                                                                "Item No." = field("No."),
                                                                                "Variant Code" = field("Variant Filter"),
                                                                                "Shortcut Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                                                "Shortcut Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                                                "Location Code" = field("Location Filter"),
                                                                                "Due Date" = field("Date Filter"),
                                                                                "Unit of Measure Code" = field("Unit of Measure Filter")));
            Caption = 'Scheduled Receipt (Qty.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
#if not CLEANSCHEMA28
        field(5421; "Scheduled Need (Qty.)"; Decimal)
        {
            ObsoleteReason = 'Use the field ''Qty. on Component Lines'' instead';
#if CLEAN25
            ObsoleteState = Removed;
            ObsoleteTag = '28.0';
#else
            ObsoleteState = Pending;
            ObsoleteTag = '18.0';
#endif
            CalcFormula = sum("Prod. Order Component"."Remaining Qty. (Base)" where(Status = filter(Planned .. Released),
                                                                                     "Item No." = field("No."),
                                                                                     "Variant Code" = field("Variant Filter"),
                                                                                     "Shortcut Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                                                     "Shortcut Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                                                     "Location Code" = field("Location Filter"),
                                                                                     "Due Date" = field("Date Filter"),
                                                                                     "Unit of Measure Code" = field("Unit of Measure Filter")));
            Caption = 'Scheduled Need (Qty.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
#endif
        field(5429; "Reserved Qty. on Prod. Order"; Decimal)
        {
            AccessByPermission = TableData "Production Order" = R;
            CalcFormula = sum("Reservation Entry"."Quantity (Base)" where("Item No." = field("No."),
                                                                           "Source Type" = const(5406),
                                                                           "Source Subtype" = filter("1" .. "3"),
                                                                           "Reservation Status" = const(Reservation),
                                                                           "Location Code" = field("Location Filter"),
                                                                           "Variant Code" = field("Variant Filter"),
                                                                           "Expected Receipt Date" = field("Date Filter")));
            Caption = 'Reserved Qty. on Prod. Order';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5430; "Res. Qty. on Prod. Order Comp."; Decimal)
        {
            AccessByPermission = TableData "Production Order" = R;
            CalcFormula = - sum("Reservation Entry"."Quantity (Base)" where("Item No." = field("No."),
                                                                            "Source Type" = const(5407),
                                                                            "Source Subtype" = filter("1" .. "3"),
                                                                            "Reservation Status" = const(Reservation),
                                                                            "Location Code" = field("Location Filter"),
                                                                            "Variant Code" = field("Variant Filter"),
                                                                            "Shipment Date" = field("Date Filter")));
            Caption = 'Res. Qty. on Prod. Order Comp.';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(8011; "Production Blocked"; Enum "Item Production Blocked")
        {
            Caption = 'Production Blocked';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies which transactions with the item cannot be processed on production documents, except requisition worksheet, planning worksheet and journals.';
        }
        field(99000750; "Routing No."; Code[20])
        {
            Caption = 'Routing No.';
            DataClassification = CustomerContent;
            TableRelation = "Routing Header";

            trigger OnValidate()
            var
                PlanningAssignment: Record "Planning Assignment";
                ItemCostManagement: Codeunit ItemCostManagement;
            begin
                if "Routing No." <> '' then
                    TestField(Type, Type::Inventory);

                PlanningAssignment.RoutingReplace(Rec, xRec."Routing No.");

                if "Routing No." <> xRec."Routing No." then
                    ItemCostManagement.UpdateUnitCost(Rec, '', '', 0, 0, false, false, true, FieldNo("Routing No."));
            end;
        }
        field(99000751; "Production BOM No."; Code[20])
        {
            Caption = 'Production BOM No.';
            DataClassification = CustomerContent;
            TableRelation = "Production BOM Header";

            trigger OnValidate()
            var
                MfgSetup: Record "Manufacturing Setup";
                ProdBOMHeader: Record "Production BOM Header";
                ItemUnitOfMeasure: Record "Item Unit of Measure";
                PlanningAssignment: Record "Planning Assignment";
                ItemCostManagement: Codeunit ItemCostManagement;
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateProductionBOMNo(Rec, xRec, IsHandled);
                if not IsHandled then begin
                    if "Production BOM No." <> '' then
                        TestField(Type, Type::Inventory);

                    PlanningAssignment.BomReplace(Rec, xRec."Production BOM No.");

                    if "Production BOM No." <> xRec."Production BOM No." then
                        ItemCostManagement.UpdateUnitCost(Rec, '', '', 0, 0, false, false, true, FieldNo("Production BOM No."));

                    if ("Production BOM No." <> '') and ("Production BOM No." <> xRec."Production BOM No.") then begin
                        ProdBOMHeader.Get("Production BOM No.");
                        ItemUnitOfMeasure.Get("No.", ProdBOMHeader."Unit of Measure Code");
                        if ProdBOMHeader.Status = ProdBOMHeader.Status::Certified then begin
                            MfgSetup.Get();
                            if MfgSetup."Dynamic Low-Level Code" then
                                if NeedUpdateLowLevelCode() then begin
                                    CODEUNIT.Run(CODEUNIT::"Calculate Low-Level Code", Rec);
                                    OnValidateProductionBOMNoOnAfterCodeunitRun(ProdBOMHeader, Rec);
                                end;
                            OnValidateProductionBOMNoOnAfterProcessStatusCertified(ProdBOMHeader, Rec);
                        end;
                    end;
                end;
            end;
        }
        field(99000752; "Single-Level Material Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Single-Level Material Cost';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(99000753; "Single-Level Capacity Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Single-Level Capacity Cost';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(99000754; "Single-Level Subcontrd. Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Single-Level Subcontrd. Cost';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(99000755; "Single-Level Cap. Ovhd Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Single-Level Cap. Ovhd Cost';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(99000756; "Single-Level Mfg. Ovhd Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Single-Level Mfg. Ovhd Cost';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(99000758; "Rolled-up Subcontracted Cost"; Decimal)
        {
            AccessByPermission = TableData "Production Order" = R;
            AutoFormatType = 2;
            Caption = 'Rolled-up Subcontracted Cost';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(99000759; "Rolled-up Mfg. Ovhd Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Rolled-up Mfg. Ovhd Cost';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(99000760; "Rolled-up Cap. Overhead Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Rolled-up Cap. Overhead Cost';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(99000765; "Planned Order Receipt (Qty.)"; Decimal)
        {
            CalcFormula = sum("Prod. Order Line"."Remaining Qty. (Base)" where(Status = const(Planned),
                                                                                "Item No." = field("No."),
                                                                                "Variant Code" = field("Variant Filter"),
                                                                                "Shortcut Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                                                "Shortcut Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                                                "Location Code" = field("Location Filter"),
                                                                                "Due Date" = field("Date Filter"),
                                                                                "Unit of Measure Code" = field("Unit of Measure Filter")));
            Caption = 'Planned Order Receipt (Qty.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(99000766; "FP Order Receipt (Qty.)"; Decimal)
        {
            CalcFormula = sum("Prod. Order Line"."Remaining Qty. (Base)" where(Status = const("Firm Planned"),
                                                                                "Item No." = field("No."),
                                                                                "Variant Code" = field("Variant Filter"),
                                                                                "Shortcut Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                                                "Shortcut Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                                                "Location Code" = field("Location Filter"),
                                                                                "Due Date" = field("Date Filter"),
                                                                                "Unit of Measure Code" = field("Unit of Measure Filter")));
            Caption = 'FP Order Receipt (Qty.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(99000767; "Rel. Order Receipt (Qty.)"; Decimal)
        {
            CalcFormula = sum("Prod. Order Line"."Remaining Qty. (Base)" where(Status = const(Released),
                                                                                "Item No." = field("No."),
                                                                                "Variant Code" = field("Variant Filter"),
                                                                                "Shortcut Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                                                "Shortcut Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                                                "Location Code" = field("Location Filter"),
                                                                                "Due Date" = field("Date Filter"),
                                                                                "Unit of Measure Code" = field("Unit of Measure Filter")));
            Caption = 'Rel. Order Receipt (Qty.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(99000769; "Planned Order Release (Qty.)"; Decimal)
        {
            CalcFormula = sum("Prod. Order Line"."Remaining Qty. (Base)" where(Status = const(Planned),
                                                                                "Item No." = field("No."),
                                                                                "Variant Code" = field("Variant Filter"),
                                                                                "Shortcut Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                                                "Shortcut Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                                                "Location Code" = field("Location Filter"),
                                                                                "Starting Date" = field("Date Filter"),
                                                                                "Unit of Measure Code" = field("Unit of Measure Filter")));
            Caption = 'Planned Order Release (Qty.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(99000774; "Prod. Forecast Quantity (Base)"; Decimal)
        {
            CalcFormula = sum("Production Forecast Entry"."Forecast Quantity (Base)" where("Item No." = field("No."),
                                                                                            "Production Forecast Name" = field("Production Forecast Name"),
                                                                                            "Forecast Date" = field("Date Filter"),
                                                                                            "Location Code" = field("Location Filter"),
                                                                                            "Component Forecast" = field("Component Forecast"),
                                                                                            "Variant Code" = field("Variant Filter")));
            Caption = 'Prod. Forecast Quantity (Base)';
            DecimalPlaces = 0 : 5;
            FieldClass = FlowField;
        }
        field(99000775; "Production Forecast Name"; Code[10])
        {
            Caption = 'Production Forecast Name';
            FieldClass = FlowFilter;
            TableRelation = "Production Forecast Name";
        }
        field(99000776; "Component Forecast"; Boolean)
        {
            Caption = 'Component Forecast';
            FieldClass = FlowFilter;
        }
        field(99000777; "Qty. on Prod. Order"; Decimal)
        {
            CalcFormula = sum("Prod. Order Line"."Remaining Qty. (Base)" where(Status = filter(Planned .. Released),
                                                                                "Item No." = field("No."),
                                                                                "Shortcut Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                                                "Shortcut Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                                                "Location Code" = field("Location Filter"),
                                                                                "Variant Code" = field("Variant Filter"),
                                                                                "Due Date" = field("Date Filter"),
                                                                                "Unit of Measure Code" = field("Unit of Measure Filter")));
            Caption = 'Qty. on Prod. Order';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(99000778; "Qty. on Component Lines"; Decimal)
        {
            CalcFormula = sum("Prod. Order Component"."Remaining Qty. (Base)" where(Status = filter(Planned .. Released),
                                                                                     "Item No." = field("No."),
                                                                                     "Shortcut Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                                                     "Shortcut Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                                                     "Location Code" = field("Location Filter"),
                                                                                     "Variant Code" = field("Variant Filter"),
                                                                                     "Due Date" = field("Date Filter"),
                                                                                     "Unit of Measure Code" = field("Unit of Measure Filter")));
            Caption = 'Qty. on Component Lines';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(99000779; "Single-Lvl Mat. Non-Invt. Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Single-Level Material Non-Inventory Cost';
            ToolTip = 'Specifies the total Non-inventory material cost of all components on the parent item''s BOM';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(99000780; "Allow Whse. Overpick"; Boolean)
        {
            AutoFormatType = 2;
            Caption = 'Allow Whse. Overpick';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies that the record is allowed to be created in the Warehouse Pick list against the Released Production Order more than the quantity defined in the component Line. For example, system will allow to create Pick for 10 units even if the component in the BOM is defined for 3 units.';
        }
    }

    keys
    {
        key(Key8; "Production BOM No.")
        {
        }
        key(Key9; "Routing No.")
        {
        }
    }

    var
        InventorySetup: Record "Inventory Setup";
        ManufacturingSetup: Record "Manufacturing Setup";
        HideNonInventoryValidateOnStdCost: Boolean;
        NoActiveBOMVersionFoundErr: Label 'There is no active Production BOM for the item %1.', Comment = '%1 - Item No.';
        ProductionBlockedOutputItemErr: Label 'You cannot produce %1 %2 because the %3 is %4 on the %1 card.', Comment = '%1 - Table Caption (Item), %2 - Item No., %3 - Field Caption, %4 - Field Value';
        ProductionBlockedOutputItemVariantErr: Label 'You cannot produce variant %1 for %2 %3 because it is blocked for production output.', Comment = '%1 - Item Variant Code, %2 - Table Caption (Item), %3 - Item No.';

#if not CLEAN25
    [Obsolete('Replaced by procedure CheckProdOrderLine() in codeunit CheckProdOrderDocument', '25.0')]
    procedure CheckProdOrderLine(CurrentFieldNo: Integer; CheckFieldNo: Integer; CheckFieldCaption: Text)
    var
        CheckProdOrderDocument: Codeunit "Check Prod. Order Document";
    begin
        CheckProdOrderDocument.CheckProdOrderLines(Rec, CurrentFieldNo, CheckFieldNo, CheckFieldCaption);
    end;
#endif

#if not CLEAN25
    [Obsolete('Replaced by procedure CheckProdOrderComponent() in codeunit CheckProdOrderDocument', '25.0')]
    procedure CheckProdOrderCompLine(CurrentFieldNo: Integer; CheckFieldNo: Integer; CheckFieldCaption: Text)
    var
        CheckProdOrderDocument: Codeunit "Check Prod. Order Document";
    begin
        CheckProdOrderDocument.CheckProdOrderLines(Rec, CurrentFieldNo, CheckFieldNo, CheckFieldCaption);
    end;
#endif

#if not CLEAN25
    [Obsolete('Replaced by procedure CheckProdBOMLine() in codeunit CheckProdOrderDocument', '25.0')]
    procedure CheckProdBOMLine(CurrentFieldNo: Integer; CheckFieldNo: Integer; CheckFieldCaption: Text)
    var
        CheckProdOrderDocument: Codeunit "Check Prod. Order Document";
    begin
        CheckProdOrderDocument.CheckProdBOMLines(Rec, CurrentFieldNo, CheckFieldNo, CheckFieldCaption);
    end;
#endif

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateProductionBOMNo(var Item: Record Item; xItem: Record Item; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateProductionBOMNoOnAfterCodeunitRun(ProductionBOMHeader: Record "Production BOM Header"; var Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateProductionBOMNoOnAfterProcessStatusCertified(ProductionBOMHeader: Record "Production BOM Header"; var Item: Record Item)
    begin
    end;

    procedure SetHideNonInventoryValidateOnStdCost(NewHideNonInventoryValidateOnStdCost: Boolean)
    begin
        HideNonInventoryValidateOnStdCost := NewHideNonInventoryValidateOnStdCost;
    end;

    procedure CanHideNonInventoryValidateOnStdCost(): Boolean
    begin
        exit(HideNonInventoryValidateOnStdCost);
    end;

    internal procedure OpenActiveProdBOMForItem(ProdBOMNo: Code[20]; ItemNo: Code[20])
    var
        ProductionBOMHeader: Record "Production BOM Header";
        ProductionBOMVersion: Record "Production BOM Version";
        VersionManagement: Codeunit VersionManagement;
        ActiveVersionNo: Code[20];
    begin
        if ProdBOMNo = '' then
            Error(NoActiveBOMVersionFoundErr, ItemNo);

        ActiveVersionNo := VersionManagement.GetBOMVersion(ProdBOMNo, WorkDate(), true);

        if ActiveVersionNo <> '' then begin
            ProductionBOMVersion.SetRange("Production BOM No.", ProdBOMNo);
            ProductionBOMVersion.SetRange("Version Code", ActiveVersionNo);
            Page.RunModal(Page::"Production BOM Version", ProductionBOMVersion);
        end else begin
            ProductionBOMHeader.SetRange("No.", ProdBOMNo);
            ProductionBOMHeader.SetRange(Status, ProductionBOMHeader.Status::Certified);
            if ProductionBOMHeader.IsEmpty() then
                Error(NoActiveBOMVersionFoundErr, ItemNo);

            Page.RunModal(Page::"Production BOM", ProductionBOMHeader);
        end;
    end;

    internal procedure CheckItemAndVariantForProdBlocked(ItemNo: Code[20]; VariantCode: Code[20]; ItemProductionBlockedToCheck: Enum "Item Production Blocked")
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
    begin
        if ItemProductionBlockedToCheck = ItemProductionBlockedToCheck::" " then
            exit;

        if ItemNo <> '' then begin
            Item.SetLoadFields("Production Blocked");
            Item.Get(ItemNo);
            case Item."Production Blocked" of
                Item."Production Blocked"::Output:
                    if ItemProductionBlockedToCheck = ItemProductionBlockedToCheck::Output then
                        Error(ProductionBlockedOutputItemErr, Item.TableCaption(), Item."No.", Item.FieldCaption("Production Blocked"), Item."Production Blocked");
            end;
        end;

        if (ItemNo <> '') and (VariantCode <> '') then begin
            ItemVariant.SetLoadFields(Blocked, "Production Blocked");
            ItemVariant.Get(ItemNo, VariantCode);
            case ItemVariant."Production Blocked" of
                ItemVariant."Production Blocked"::Output:
                    if ItemProductionBlockedToCheck = ItemProductionBlockedToCheck::Output then
                        Error(ProductionBlockedOutputItemVariantErr, VariantCode, Item.TableCaption(), ItemNo);
            end;
        end;
    end;

    procedure ShouldTryCostFromSKU(): Boolean
    begin
        if Rec."Costing Method" <> Rec."Costing Method"::Standard then
            exit(false);

        ManufacturingSetup.GetRecordOnce();
        if not ManufacturingSetup."Load SKU Cost on Manufacturing" then
            exit(false);

        InventorySetup.GetRecordOnce();
        exit(InventorySetup."Average Cost Calc. Type" = InventorySetup."Average Cost Calc. Type"::"Item & Location & Variant");
    end;

    local procedure NeedUpdateLowLevelCode(): Boolean
    var
        Item: Record Item;
    begin
        if CurrFieldNo <> 0 then
            exit(true);

        Item.SetLoadFields("Base Unit of Measure", "Inventory Posting Group");
        Item.Get("No.");
        exit((Item."Base Unit of Measure" = Rec."Base Unit of Measure") or (Item."Inventory Posting Group" = Rec."Inventory Posting Group"));
    end;
}
