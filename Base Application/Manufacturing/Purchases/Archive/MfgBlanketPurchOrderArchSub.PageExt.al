// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Archive;

pageextension 99000760 "Mfg. BlanketPurchOrderArchSub" extends "Blanket Purch. Order Arch.Sub."
{
    layout
    {
        addafter("Planning Flexibility")
        {
            field("Prod. Order Line No."; Rec."Prod. Order Line No.")
            {
                ApplicationArea = Manufacturing;
                ToolTip = 'Specifies the number of the related production order line.';
                Visible = false;
            }
            field("Prod. Order No."; Rec."Prod. Order No.")
            {
                ApplicationArea = Manufacturing;
                ToolTip = 'Specifies the number of the related production order.';
                Visible = false;
            }
            field("Operation No."; Rec."Operation No.")
            {
                ApplicationArea = Manufacturing;
                ToolTip = 'Specifies the number of the related production operation.';
                Visible = false;
            }
            field("Work Center No."; Rec."Work Center No.")
            {
                ApplicationArea = Manufacturing;
                ToolTip = 'Specifies the number of a related work center, for example for subcontracted production.';
                Visible = false;
            }
            field(Finished; Rec.Finished)
            {
                ApplicationArea = Manufacturing;
                Visible = false;
            }
        }
    }
}