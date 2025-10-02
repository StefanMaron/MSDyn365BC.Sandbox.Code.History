// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.History;

pageextension 99000784 "Mfg. PostedPurchRcptSubform" extends "Posted Purchase Rcpt. Subform"
{
    layout
    {
        addafter("Job Task No.")
        {
            field("Prod. Order No."; Rec."Prod. Order No.")
            {
                ApplicationArea = Manufacturing;
                ToolTip = 'Specifies the number of the related production order.';
                Visible = false;
            }
        }
    }
}