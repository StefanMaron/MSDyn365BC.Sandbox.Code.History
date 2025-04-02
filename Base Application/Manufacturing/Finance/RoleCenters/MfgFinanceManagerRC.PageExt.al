// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.RoleCenters;

using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.Reports;

pageextension 99000780 "Mfg. Finance Manager RC" extends "Finance Manager Role Center"
{
    actions
    {
        addafter("Adjust Cost - Item Entries")
        {
            action("Update Unit Cost...")
            {
                ApplicationArea = Manufacturing;
                Caption = 'Update Unit Costs...';
                RunObject = report "Update Unit Cost";
                Tooltip = 'Run the Update Unit Costs report.';
            }
        }
        addafter("Status")
        {
            action("Cost Shares Breakdown")
            {
                ApplicationArea = Manufacturing;
                Caption = 'Cost Shares Breakdown';
                RunObject = report "Cost Shares Breakdown";
                Tooltip = 'Run the Cost Shares Breakdown report.';
            }
        }
    }
}