// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Item;

page 32 "Item Lookup"
{
    Caption = 'Items';
    CardPageID = "Item Card";
    Editable = false;
    PageType = List;
    SourceTable = Item;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field("No. 2"; Rec."No. 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the alternative number of the item.';
                    Visible = false;
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field("Base Unit of Measure"; Rec."Base Unit of Measure")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unit in which the item is held in inventory. The base unit of measure also serves as the conversion basis for alternate units of measure.';
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the price for one unit of the item.';
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field(InventoryCtrl; Rec.Inventory)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity in stock for this item.';
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field("Created From Nonstock Item"; Rec."Created From Nonstock Item")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field("Stockkeeping Unit Exists"; Rec."Stockkeeping Unit Exists")
                {
                    ApplicationArea = Warehouse;
                    Visible = false;
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field("Shelf No."; Rec."Shelf No.")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field("Costing Method"; Rec."Costing Method")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field("Cost is Adjusted"; Rec."Cost is Adjusted")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field("Standard Cost"; Rec."Standard Cost")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the cost per unit of the item.';
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field("Last Direct Cost"; Rec."Last Direct Cost")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the most recent direct unit cost that was paid for the item.';
                    Visible = false;
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field("Price/Profit Calculation"; Rec."Price/Profit Calculation")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field("Profit %"; Rec."Profit %")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field("Inventory Posting Group"; Rec."Inventory Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                    ApplicationArea = Suite;
                    Visible = false;
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field("Item Disc. Group"; Rec."Item Disc. Group")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = Basic, Suite;
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field("Vendor Item No."; Rec."Vendor Item No.")
                {
                    ApplicationArea = Basic, Suite;
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field(GTIN; Rec.GTIN)
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field("Alternative Item No."; Rec."Alternative Item No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies an alternative number for the item.';
                    Visible = false;
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field("Common Item No."; Rec."Common Item No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a commonly used number for the item.';
                    Visible = false;
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field("Tariff No."; Rec."Tariff No.")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field("Search Description"; Rec."Search Description")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field("Overhead Rate"; Rec."Overhead Rate")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field("Indirect Cost %"; Rec."Indirect Cost %")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field("Item Category Code"; Rec."Item Category Code")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field(SalesBlocked; Rec."Sales Blocked")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field(PurchasingBlocked; Rec."Purchasing Blocked")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that transactions with the item cannot be purchased.';
                    Visible = false;
                }
                field("Last Date Modified"; Rec."Last Date Modified")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field("Sales Unit of Measure"; Rec."Sales Unit of Measure")
                {
                    ApplicationArea = Suite;
                    Visible = false;
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field("Replenishment System"; Rec."Replenishment System")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field("Purch. Unit of Measure"; Rec."Purch. Unit of Measure")
                {
                    ApplicationArea = Suite;
                    Visible = false;
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field("Lead Time Calculation"; Rec."Lead Time Calculation")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field("Manufacturing Policy"; Rec."Manufacturing Policy")
                {
                    ApplicationArea = Manufacturing;
                    Visible = false;
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field("Flushing Method"; Rec."Flushing Method")
                {
                    ApplicationArea = Manufacturing;
                    Visible = false;
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field("Assembly Policy"; Rec."Assembly Policy")
                {
                    ApplicationArea = Assembly;
                    Visible = false;
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field("Item Tracking Code"; Rec."Item Tracking Code")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies how items are tracked in the supply chain.';
                    Visible = false;
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
                field("Default Deferral Template Code"; Rec."Default Deferral Template Code")
                {
                    ApplicationArea = Suite;
                    Caption = 'Default Deferral Template';
                    Importance = Additional;
                    Visible = false;
                    Style = Subordinate;
                    StyleExpr = Rec.Blocked;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(ItemList)
            {
                ApplicationArea = All;
                Caption = 'Advanced View';
                Image = CustomerList;
                ToolTip = 'Open the Items page showing all possible columns.';

                trigger OnAction()
                var
                    ItemList: Page "Item List";
                begin
                    ItemList.SetTableView(Rec);
                    ItemList.SetRecord(Rec);
                    ItemList.LookupMode := true;

                    Commit();
                    if ItemList.RunModal() = ACTION::LookupOK then begin
                        ItemList.GetRecord(Rec);
                        CurrPage.Close();
                    end;
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(ItemList_Promoted; ItemList)
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        SetLoadFieldsForDropDown();
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        Found: Boolean;
        IsHandled: Boolean;
    begin
        SetLoadFieldsForDropDown();
        IsHandled := false;
        OnBeforeFindRecord(Rec, Which, CrossColumnSearchFilter, Found, IsHandled);
        if IsHandled then
            exit(Found);
        exit(Rec.Find(Which));
    end;

    local procedure SetLoadFieldsForDropDown()
    begin
        // initially only load the fields shown in field group 'dropdown'
        Rec.SetLoadFields("No.", Description, "Base Unit of Measure", "Unit Price", Inventory, Blocked, "Vendor Item No.", "No. 2", "Alternative Item No.", "Common Item No.", GTIN, "Shelf No.");
        Rec.SetAutoCalcFields(Inventory);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFindRecord(var Rec: Record Item; Which: Text; var CrossColumnSearchFilter: Text; var Found: Boolean; var IsHandled: Boolean)
    begin
    end;

    var
        CrossColumnSearchFilter: Text;
}

